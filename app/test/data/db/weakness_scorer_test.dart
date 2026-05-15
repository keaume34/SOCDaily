// Phase 14.C — WeaknessScorer tests.
//
// Builds an in-memory drift DB with two topics, exercises the user-state
// repo to seed MCQ accuracy + flashcard ease + due cards, then asserts
// the scorer surfaces the weaker topic first.

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/user_state_repository.dart';
import 'package:socdaily_app/src/data/db/weakness_scorer.dart';
import 'package:socdaily_app/src/features/study/study_session_controller.dart';

class _Fix {
  _Fix(this.db);
  final AppDatabase db;

  late int subjectId;
  late int chapterId;
  late int topicAId;
  late int topicBId;
  late int cardA1Id;
  late int cardA2Id;
  late int cardB1Id;
  late int cardB2Id;
  late int qAId;
  late int qBId;

  Future<void> seed() async {
    subjectId = await db.into(db.subjects).insert(
        SubjectsCompanion.insert(code: 'soc', title: 'SOC'));
    chapterId = await db.into(db.chapters).insert(
        ChaptersCompanion.insert(
            subjectId: subjectId, code: 'siem', title: 'SIEM'));

    topicAId = await db.into(db.topics).insert(TopicsCompanion.insert(
        chapterId: chapterId, code: 'topic-a', title: 'Topic A'));
    topicBId = await db.into(db.topics).insert(TopicsCompanion.insert(
        chapterId: chapterId, code: 'topic-b', title: 'Topic B'));

    cardA1Id = await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
        topicId: topicAId, front: 'a1', back: 'a1'));
    cardA2Id = await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
        topicId: topicAId, front: 'a2', back: 'a2'));
    cardB1Id = await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
        topicId: topicBId, front: 'b1', back: 'b1'));
    cardB2Id = await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
        topicId: topicBId, front: 'b2', back: 'b2'));

    qAId = await db.into(db.questions).insert(
        QuestionsCompanion.insert(topicId: topicAId, stem: 'qa'));
    qBId = await db.into(db.questions).insert(
        QuestionsCompanion.insert(topicId: topicBId, stem: 'qb'));
  }
}

void main() {
  late AppDatabase db;
  late UserStateRepository repo;
  late WeaknessScorer scorer;
  late _Fix fix;

  setUp(() async {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = UserStateRepository(db);
    scorer = WeaknessScorer(db);
    fix = _Fix(db);
    await fix.seed();
  });

  tearDown(() => db.close());

  test('top weak topics excludes untouched topics', () async {
    final entries = await scorer.topWeakTopics();
    expect(entries, isEmpty);
  });

  test('topic with lower MCQ accuracy outranks the better one', () async {
    // Topic A: 1/5 correct (worse).
    await db.into(db.userQuestionState).insert(
          UserQuestionStateCompanion.insert(
            questionId: d.Value(fix.qAId),
            attempts: const d.Value(5),
            correct: const d.Value(1),
          ),
          mode: d.InsertMode.insertOrReplace,
        );
    // Topic B: 4/5 correct (better).
    await db.into(db.userQuestionState).insert(
          UserQuestionStateCompanion.insert(
            questionId: d.Value(fix.qBId),
            attempts: const d.Value(5),
            correct: const d.Value(4),
          ),
          mode: d.InsertMode.insertOrReplace,
        );
    final entries = await scorer.topWeakTopics();
    expect(entries.length, 2);
    expect(entries.first.topic.code, 'topic-a');
    expect(entries.first.mcqAccuracy, closeTo(0.2, 0.001));
  });

  test('score ranges 0..1 and combines accuracy + ease + due', () async {
    // Topic A: rated "again" several times → ease drops → due immediately.
    final t = DateTime.utc(2026, 5, 15);
    await repo.recordFlashcardRating(fix.cardA1Id, CardRating.again, now: t);
    await repo.recordFlashcardRating(fix.cardA2Id, CardRating.again, now: t);
    // Topic B: rated "good" → ease holds → not due for 1 day.
    await repo.recordFlashcardRating(fix.cardB1Id, CardRating.good, now: t);
    await repo.recordFlashcardRating(fix.cardB2Id, CardRating.good, now: t);

    final entries = await scorer.topWeakTopics(now: t);
    expect(entries.first.topic.code, 'topic-a');
    for (final e in entries) {
      expect(e.score, inInclusiveRange(0.0, 1.0));
    }
  });

  test('topWeakTopics caps to limit', () async {
    // Touch both topics so neither is excluded.
    final t = DateTime.utc(2026, 5, 15);
    await repo.recordFlashcardRating(fix.cardA1Id, CardRating.again, now: t);
    await repo.recordFlashcardRating(fix.cardB1Id, CardRating.good, now: t);
    final entries = await scorer.topWeakTopics(limit: 1, now: t);
    expect(entries.length, 1);
    expect(entries.first.topic.code, 'topic-a');
  });

  test('allScores returns every topic regardless of activity', () async {
    final entries = await scorer.allScores(now: DateTime.utc(2026, 5, 15));
    expect(entries.length, 2);
  });
}
