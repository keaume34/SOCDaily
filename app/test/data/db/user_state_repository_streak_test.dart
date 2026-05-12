// Streak / heatmap / totals tests for UserStateRepository.

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
    final s = await db
        .into(db.subjects)
        .insert(SubjectsCompanion.insert(code: 's', title: 'S'));
    final c = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(subjectId: s, code: 'c', title: 'C'));
    final t = await db.into(db.topics).insert(
        TopicsCompanion.insert(chapterId: c, code: 't', title: 'T'));
    flashcardId = await db.into(db.flashcards).insert(
        FlashcardsCompanion.insert(topicId: t, front: 'f', back: 'b'));
    questionId = await db
        .into(db.questions)
        .insert(QuestionsCompanion.insert(topicId: t, stem: 'q'));
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

  test('recordActivity accumulates per-day buckets', () async {
    final now = DateTime.utc(2025, 1, 1, 9);
    await repo.recordActivity(cards: 3, now: now);
    await repo.recordActivity(cards: 2, questions: 1, now: now);
    final rows = await (db.select(db.userStreak)
          ..where((s) => s.day.equals(DateTime.utc(2025, 1, 1))))
        .get();
    expect(rows.length, 1);
    expect(rows.first.cardsReviewed, 5);
    expect(rows.first.questionsAnswered, 1);
  });

  test('streakStats counts consecutive days', () async {
    final base = DateTime.utc(2025, 1, 1);
    for (final d in [0, 1, 2, 4, 5]) {
      await repo.recordActivity(cards: 1, now: base.add(Duration(days: d)));
    }
    final s = await repo.streakStats(
        now: base.add(const Duration(days: 5, hours: 10)));
    expect(s.current, 2); // day 4 + day 5
    expect(s.longest, 3); // day 0,1,2
  });

  test('streakStats returns zero when no activity', () async {
    final s = await repo.streakStats();
    expect(s.current, 0);
    expect(s.longest, 0);
  });

  test('activityHeatmap returns full window with zero fills', () async {
    final today = DateTime.utc(2025, 3, 1);
    await repo.recordActivity(
        cards: 4, now: today.subtract(const Duration(days: 1)));
    final rows = await repo.activityHeatmap(days: 7, now: today);
    expect(rows.length, 7);
    expect(rows.last.day.year, today.year);
    expect(rows.last.day.month, today.month);
    expect(rows.last.day.day, today.day);
    expect(rows[5].count, 4);
    expect(rows.first.count, 0);
  });

  test('totals aggregates from card + question state', () async {
    await repo.recordFlashcardRating(flashcardId, CardRating.good);
    await repo.recordFlashcardRating(flashcardId, CardRating.again);
    await repo.recordQuestionAttempt(questionId,
        wasCorrect: true, choice: '1');
    await repo.recordQuestionAttempt(questionId,
        wasCorrect: false, choice: '2');
    final t = await repo.totals();
    expect(t.cardsKnown, 1);
    expect(t.cardsReviewed, 2);
    expect(t.mcqAttempts, 2);
    expect(t.mcqCorrect, 1);
    expect(t.accuracy, 0.5);
  });

  test('rateFlashcard and recordQuestionAttempt log activity', () async {
    await repo.recordFlashcardRating(flashcardId, CardRating.good);
    await repo.recordQuestionAttempt(questionId,
        wasCorrect: true, choice: '1');
    final rows = await db.select(db.userStreak).get();
    expect(rows, isNotEmpty);
    final total = rows.fold<int>(
        0, (a, r) => a + r.cardsReviewed + r.questionsAnswered);
    expect(total, 2);
  });
}
