// Phase 8 tests — deterministic daily challenge, random questions, and
// cheatsheet roll-up.

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/content_repository.dart';

Future<({AppDatabase db, ContentRepository repo, int subjectId})>
    _seed() async {
  final db = AppDatabase.forExecutor(NativeDatabase.memory());
  final subjectId = await db.into(db.subjects).insert(
      SubjectsCompanion.insert(code: 'soc', title: 'SOC Fundamentals'));
  final chapterId = await db.into(db.chapters).insert(
      ChaptersCompanion.insert(
          subjectId: subjectId, code: 'intro', title: 'Intro'));
  for (var i = 0; i < 3; i++) {
    final topicId = await db.into(db.topics).insert(TopicsCompanion.insert(
        chapterId: chapterId, code: 't$i', title: 'Topic $i'));
    for (var j = 0; j < 4; j++) {
      await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          topicId: topicId, front: 'q$i-$j', back: 'a$i-$j'));
      final qId =
          await db.into(db.questions).insert(QuestionsCompanion.insert(
                topicId: topicId,
                qtype: const Value('single'),
                stem: 's$i-$j',
              ));
      await db.into(db.questionOptions).insert(QuestionOptionsCompanion
          .insert(questionId: qId, label: 'A', content: 'A'));
    }
  }
  return (db: db, repo: ContentRepository(db), subjectId: subjectId);
}

void main() {
  test('dailyChallenge returns the same set for the same day', () async {
    final s = await _seed();
    final day = DateTime.utc(2025, 6, 1);
    final a = await s.repo.dailyChallenge(day: day);
    final b = await s.repo.dailyChallenge(day: day);
    expect(a.flashcards.map((f) => f.id).toList(),
        b.flashcards.map((f) => f.id).toList());
    expect(a.questions.map((q) => q.id).toList(),
        b.questions.map((q) => q.id).toList());
    await s.db.close();
  });

  test('dailyChallenge changes day-over-day', () async {
    final s = await _seed();
    final d1 = await s.repo.dailyChallenge(day: DateTime.utc(2025, 6, 1));
    final d2 = await s.repo.dailyChallenge(day: DateTime.utc(2025, 6, 2));
    expect(d1.flashcards.map((f) => f.id).toList(),
        isNot(equals(d2.flashcards.map((f) => f.id).toList())));
    await s.db.close();
  });

  test('dailyChallenge clamps counts to corpus size', () async {
    final s = await _seed();
    final picked = await s.repo.dailyChallenge(
        day: DateTime.utc(2025, 6, 1),
        flashcardCount: 999,
        questionCount: 999);
    expect(picked.flashcards.length, 12); // 3 topics × 4 cards
    expect(picked.questions.length, 12);
    await s.db.close();
  });

  test('randomQuestions returns up to count items', () async {
    final s = await _seed();
    final got = await s.repo.randomQuestions(5, seed: 42);
    expect(got.length, 5);
    final got2 = await s.repo.randomQuestions(5, seed: 42);
    expect(got2.map((q) => q.id).toList(),
        got.map((q) => q.id).toList(),
        reason: 'same seed → same picks');
    await s.db.close();
  });

  test('cheatsheetForSubject groups flashcards by topic, only non-empty',
      () async {
    final s = await _seed();
    final rows = await s.repo.cheatsheetForSubject(s.subjectId);
    expect(rows.length, 3);
    for (final r in rows) {
      expect(r.flashcards, isNotEmpty);
    }
    await s.db.close();
  });
}
