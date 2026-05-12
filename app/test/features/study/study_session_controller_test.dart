// Tests for the Phase-3 study session state machine. We mount the
// controller against an in-memory drift DB pre-populated with one
// flashcard + one MCQ, then drive it through select → submit → next.

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/content_repository.dart';
import 'package:socdaily_app/src/features/study/study_session_controller.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int topicId;
  late int correctOptionId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());

    final s = await db.into(db.subjects).insert(
          SubjectsCompanion.insert(code: 'soc', title: 'SOC'),
        );
    final c = await db.into(db.chapters).insert(
          ChaptersCompanion.insert(
              subjectId: s, code: 'intro', title: 'Intro'),
        );
    topicId = await db.into(db.topics).insert(
          TopicsCompanion.insert(chapterId: c, code: 't', title: 'T'),
        );
    await db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(
            topicId: topicId,
            front: 'Q?',
            back: 'A.',
          ),
        );
    final qid = await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            topicId: topicId,
            stem: 'Pick A',
          ),
        );
    correctOptionId = await db.into(db.questionOptions).insert(
          QuestionOptionsCompanion.insert(
            questionId: qid,
            label: 'A',
            content: 'right',
            isCorrect: const Value(true),
          ),
        );
    await db.into(db.questionOptions).insert(
          QuestionOptionsCompanion.insert(
            questionId: qid,
            label: 'B',
            content: 'wrong',
            orderIndex: const Value(1),
          ),
        );

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('initial state: load flashcard + question into items', () async {
    final state =
        await container.read(studySessionControllerProvider(topicId).future);
    expect(state.items.length, 2);
    expect(state.items.first, isA<FlashcardItem>());
    expect(state.items.last, isA<QuestionItem>());
  });

  test('rate flashcard advances index and records rating', () async {
    final notifier =
        container.read(studySessionControllerProvider(topicId).notifier);
    await container.read(studySessionControllerProvider(topicId).future);
    notifier.rateFlashcard(CardRating.good);
    final state = container
        .read(studySessionControllerProvider(topicId))
        .requireValue;
    expect(state.index, 1);
    expect(state.flashcardRatings.length, 1);
    expect(state.flashcardRatings.values.first, CardRating.good);
  });

  test('answer correctly + submit + next', () async {
    final notifier =
        container.read(studySessionControllerProvider(topicId).notifier);
    await container.read(studySessionControllerProvider(topicId).future);

    notifier.rateFlashcard(CardRating.good); // jump to question
    notifier.toggleOption(correctOptionId, multiple: false);
    notifier.submitQuestion();

    var s = container
        .read(studySessionControllerProvider(topicId))
        .requireValue;
    expect(s.submitted, isTrue);
    expect(s.questionResults.values.single, isTrue);

    notifier.next();
    s = container
        .read(studySessionControllerProvider(topicId))
        .requireValue;
    expect(s.isDone, isTrue);
    expect(s.accuracy, 1.0);
  });

  test('answer incorrectly marks question wrong', () async {
    final notifier =
        container.read(studySessionControllerProvider(topicId).notifier);
    final state =
        await container.read(studySessionControllerProvider(topicId).future);
    final q = state.items.last as QuestionItem;
    final wrongOptionId =
        q.options.firstWhere((o) => !o.isCorrect).id;

    notifier.rateFlashcard(CardRating.again);
    notifier.toggleOption(wrongOptionId, multiple: false);
    notifier.submitQuestion();

    final s = container
        .read(studySessionControllerProvider(topicId))
        .requireValue;
    expect(s.questionResults.values.single, isFalse);
    expect(s.accuracy, 0.0);
  });
}
