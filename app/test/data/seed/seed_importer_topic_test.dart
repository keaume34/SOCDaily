// Phase 14.B — SeedImporter.importTopicSeed tests.
//
// Builds a TopicSeed JSON in memory (matching the bundled
// `assets/seed/**.json` schema), feeds it to the importer, and asserts
// that subjects/chapters/topics/flashcards/questions land in the local
// drift DB. Re-import on the same topic should be idempotent (replace,
// not duplicate).

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/seed/seed_importer.dart';

Map<String, dynamic> _seed({
  String topicCode = 'siem-core',
  int flashcards = 2,
  int questions = 1,
}) {
  return {
    'subject_code': 'soc-fundamentals',
    'subject_title': 'SOC Fundamentals',
    'chapter_code': 'siem',
    'chapter_title': 'SIEM',
    'topic_code': topicCode,
    'topic_title': 'SIEM Core Concepts',
    'topic_summary': 'Quick intro',
    'source_pdf': 'guide.pdf',
    'flashcards': [
      for (var i = 0; i < flashcards; i++)
        {
          'front': 'Q$i',
          'back': 'A$i',
          'difficulty': 'medium',
          'source_page': 12,
        },
    ],
    'questions': [
      for (var i = 0; i < questions; i++)
        {
          'stem': 'Stem $i',
          'qtype': 'single',
          'difficulty': 'medium',
          'options': [
            {'label': 'A', 'content': 'first', 'is_correct': true},
            {'label': 'B', 'content': 'second', 'is_correct': false},
          ],
        },
    ],
  };
}

void main() {
  late AppDatabase db;
  late SeedImporter importer;

  setUp(() {
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    importer = SeedImporter(db);
  });

  tearDown(() => db.close());

  test('imports a fresh topic with subject, chapter, flashcards, questions',
      () async {
    final res = await importer.importTopicSeed(_seed());
    expect(res.topicCreated, isTrue);
    expect(res.flashcardsAdded, 2);
    expect(res.questionsAdded, 1);

    final subjects = await db.select(db.subjects).get();
    expect(subjects.single.code, 'soc-fundamentals');

    final chapters = await db.select(db.chapters).get();
    expect(chapters.single.code, 'siem');

    final topic = (await db.select(db.topics).get()).single;
    expect(topic.code, 'siem-core');

    final cards = await (db.select(db.flashcards)
          ..where((t) => t.topicId.equals(topic.id)))
        .get();
    expect(cards.length, 2);
    expect(cards.first.sourcePage, 12);

    final questions = await (db.select(db.questions)
          ..where((t) => t.topicId.equals(topic.id)))
        .get();
    expect(questions.length, 1);

    final options = await db.select(db.questionOptions).get();
    expect(options.length, 2);
    expect(options.where((o) => o.isCorrect).length, 1);
  });

  test('re-import on same topic replaces flashcards/questions, no duplicates',
      () async {
    await importer.importTopicSeed(_seed(flashcards: 2, questions: 1));
    final res2 = await importer.importTopicSeed(
      _seed(flashcards: 4, questions: 2),
    );
    expect(res2.topicCreated, isFalse);

    final cards = await db.select(db.flashcards).get();
    expect(cards.length, 4);
    final questions = await db.select(db.questions).get();
    expect(questions.length, 2);
    final topics = await db.select(db.topics).get();
    expect(topics.length, 1, reason: 'no duplicate topic');
  });

  test('two distinct topic codes share the same chapter row', () async {
    await importer.importTopicSeed(_seed(topicCode: 'siem-core'));
    await importer.importTopicSeed(_seed(topicCode: 'siem-rules'));
    final chapters = await db.select(db.chapters).get();
    expect(chapters.length, 1);
    final topics = await db.select(db.topics).get();
    expect(topics.length, 2);
  });

  test('import without source_pdf leaves source_id null on cards', () async {
    final seed = _seed();
    seed.remove('source_pdf');
    await importer.importTopicSeed(seed);
    final cards = await db.select(db.flashcards).get();
    expect(cards.first.sourceId, isNull);
    final sources = await db.select(db.sources).get();
    expect(sources, isEmpty);
  });
}
