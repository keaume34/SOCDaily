// Phase-2 drift schema tests: open an in-memory DB, insert taxonomy +
// content rows, then exercise [ContentRepository] to make sure the wiring
// is correct.

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/content_repository.dart';

Future<int> _insertSubject(AppDatabase db, String code, String title,
    {int order = 0}) {
  return db.into(db.subjects).insert(
        SubjectsCompanion.insert(
          code: code,
          title: title,
          orderIndex: Value(order),
        ),
      );
}

Future<int> _insertChapter(AppDatabase db, int subjectId, String code,
    String title,
    {int order = 0}) {
  return db.into(db.chapters).insert(
        ChaptersCompanion.insert(
          subjectId: subjectId,
          code: code,
          title: title,
          orderIndex: Value(order),
        ),
      );
}

Future<int> _insertTopic(AppDatabase db, int chapterId, String code,
    String title,
    {int order = 0}) {
  return db.into(db.topics).insert(
        TopicsCompanion.insert(
          chapterId: chapterId,
          code: code,
          title: title,
          orderIndex: Value(order),
        ),
      );
}

void main() {
  late AppDatabase db;
  late ContentRepository repo;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    repo = ContentRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('subjects sorted by orderIndex then title', () async {
    await _insertSubject(db, 's2', 'Beta', order: 1);
    await _insertSubject(db, 's1', 'Alpha', order: 0);
    final rows = await repo.listSubjects();
    expect(rows.map((s) => s.code).toList(), ['s1', 's2']);
  });

  test('chapters scoped to subject', () async {
    final sA = await _insertSubject(db, 'sA', 'A');
    final sB = await _insertSubject(db, 'sB', 'B');
    await _insertChapter(db, sA, 'c1', 'C1');
    await _insertChapter(db, sB, 'c1', 'C1');
    expect((await repo.listChapters(sA)).length, 1);
    expect((await repo.listChapters(sB)).length, 1);
  });

  test('topic counts roll up', () async {
    final s = await _insertSubject(db, 's', 'S');
    final c = await _insertChapter(db, s, 'c', 'C');
    final t = await _insertTopic(db, c, 't', 'T');

    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          topicId: t,
          front: 'q',
          back: 'a',
        ));
    await db.into(db.flashcards).insert(FlashcardsCompanion.insert(
          topicId: t,
          front: 'q2',
          back: 'a2',
        ));
    final qid = await db.into(db.questions).insert(QuestionsCompanion.insert(
          topicId: t,
          stem: 'why?',
        ));
    await db.into(db.questionOptions).insert(QuestionOptionsCompanion.insert(
          questionId: qid,
          label: 'A',
          content: 'yes',
          isCorrect: const Value(true),
        ));

    final counts = await repo.globalCounts();
    expect(counts.subjects, 1);
    expect(counts.chapters, 1);
    expect(counts.topics, 1);
    expect(counts.flashcards, 2);
    expect(counts.questions, 1);
  });

  test('questionOptions returned in orderIndex order', () async {
    final s = await _insertSubject(db, 's', 'S');
    final c = await _insertChapter(db, s, 'c', 'C');
    final t = await _insertTopic(db, c, 't', 'T');
    final qid = await db.into(db.questions).insert(QuestionsCompanion.insert(
          topicId: t,
          stem: 'q',
        ));
    await db.into(db.questionOptions).insert(QuestionOptionsCompanion.insert(
          questionId: qid,
          label: 'B',
          content: 'b',
          orderIndex: const Value(1),
        ));
    await db.into(db.questionOptions).insert(QuestionOptionsCompanion.insert(
          questionId: qid,
          label: 'A',
          content: 'a',
          orderIndex: const Value(0),
        ));
    final opts = await repo.listOptionsForQuestion(qid);
    expect(opts.map((o) => o.label).toList(), ['A', 'B']);
  });
}
