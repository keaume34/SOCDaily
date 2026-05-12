// User state repository: drift-backed persistence tests for SM-2 and MCQ.

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/user_state_repository.dart';
import 'package:socdaily_app/src/features/study/study_session_controller.dart';

void main() {
  late AppDatabase db;
  late UserStateRepository repo;
  late int flashcardId;
  late int questionId;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = UserStateRepository(db);
    final s =
        await db.into(db.subjects).insert(SubjectsCompanion.insert(code: 's', title: 'S'));
    final c = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(subjectId: s, code: 'c', title: 'C'));
    final t = await db.into(db.topics).insert(
        TopicsCompanion.insert(chapterId: c, code: 't', title: 'T'));
    flashcardId = await db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(topicId: t, front: 'f', back: 'b'),
        );
    await db.into(db.flashcards).insert(
          FlashcardsCompanion.insert(topicId: t, front: 'f2', back: 'b2'),
        );
    questionId = await db.into(db.questions).insert(
          QuestionsCompanion.insert(topicId: t, stem: 'q'),
        );
    await db.into(db.questionOptions).insert(
          QuestionOptionsCompanion.insert(
            questionId: questionId,
            label: 'A',
            content: 'a',
            isCorrect: const Value(true),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  test('first rating creates user_card_state row', () async {
    final now = DateTime.utc(2025, 1, 1);
    final u = await repo.recordFlashcardRating(flashcardId, CardRating.good,
        now: now);
    expect(u.intervalDays, 1);
    final row = await (db.select(db.userCardState)
          ..where((s) => s.flashcardId.equals(flashcardId)))
        .getSingle();
    expect(row.intervalDays, 1);
    expect(row.lastResult, 'good');
  });

  test('subsequent rating updates existing row, not duplicates', () async {
    final now = DateTime.utc(2025, 1, 1);
    await repo.recordFlashcardRating(flashcardId, CardRating.good, now: now);
    await repo.recordFlashcardRating(flashcardId, CardRating.good,
        now: now.add(const Duration(days: 1)));
    final rows = await db.select(db.userCardState).get();
    expect(rows.length, 1);
    expect(rows.first.reviewCount, 2);
    expect(rows.first.intervalDays, 6);
  });

  test('dueFlashcards returns new (never-reviewed) cards', () async {
    final due = await repo.dueFlashcards();
    expect(due.length, 2);
  });

  test('dueFlashcards excludes cards scheduled in the future', () async {
    final now = DateTime.utc(2025, 1, 1);
    await repo.recordFlashcardRating(flashcardId, CardRating.good, now: now);
    final dueLater = await repo.dueFlashcards(asOf: now);
    expect(dueLater.length, 1); // only the other card (never reviewed)
    final dueAfterInterval =
        await repo.dueFlashcards(asOf: now.add(const Duration(days: 5)));
    expect(dueAfterInterval.length, 2); // both cards due again
  });

  test('dueCounts reports new + due totals', () async {
    var c = await repo.dueCounts();
    expect(c.total, 2);
    expect(c.newCount, 2);
    expect(c.due, 2);

    final now = DateTime.utc(2025, 1, 1);
    await repo.recordFlashcardRating(flashcardId, CardRating.good, now: now);
    c = await repo.dueCounts(asOf: now);
    expect(c.total, 2);
    expect(c.newCount, 1);
    expect(c.due, 1); // only the still-new card
  });

  test('recordQuestionAttempt increments counters', () async {
    await repo.recordQuestionAttempt(questionId,
        wasCorrect: true, choice: '1');
    await repo.recordQuestionAttempt(questionId,
        wasCorrect: false, choice: '2');
    final row = await (db.select(db.userQuestionState)
          ..where((q) => q.questionId.equals(questionId)))
        .getSingle();
    expect(row.attempts, 2);
    expect(row.correct, 1);
    expect(row.lastChoice, '2');
  });
}
