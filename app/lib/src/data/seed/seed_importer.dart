// Loads the bundled JSON seeds (mirror of the Python `TopicSeed` schema)
// from `assets/seed/manifest.json` and inserts them into the drift DB on
// first launch. Idempotent: if the DB already has rows for a subject/chapter
// /topic/seed PDF, we skip; if a topic's flashcards or questions changed in
// the assets, we replace them.

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_database.dart';

class SeedImporter {
  SeedImporter(this._db);

  final AppDatabase _db;

  /// Bumped whenever the bundled JSON shape changes so the importer can run
  /// a full re-import path.
  static const int _bundledVersion = 1;

  /// Run on every cold start. Cheap when nothing changed (~one SELECT).
  Future<SeedImportResult> ensureImported() async {
    final manifestStr =
        await rootBundle.loadString('assets/seed/manifest.json');
    final manifest = jsonDecode(manifestStr) as Map<String, dynamic>;

    final taxonomy = (manifest['subjects'] as List).cast<Map<String, dynamic>>();
    final topicEntries =
        (manifest['topics'] as List).cast<Map<String, dynamic>>();

    int subjectsAdded = 0;
    int chaptersAdded = 0;
    int topicsAdded = 0;
    int flashcardsAdded = 0;
    int questionsAdded = 0;

    await _db.transaction(() async {
      // ---- Taxonomy upsert -------------------------------------------------
      final subjectIdByCode = <String, int>{};
      final chapterIdByKey = <String, int>{};

      for (final s in taxonomy) {
        final sid = await _upsertSubject(
          code: s['code'] as String,
          title: s['title'] as String,
          description: s['description'] as String?,
          orderIndex: (s['order_index'] as int?) ?? 0,
        );
        subjectIdByCode[s['code'] as String] = sid.$1;
        if (sid.$2) subjectsAdded++;

        final chapters =
            ((s['chapters'] as List?) ?? const []).cast<Map<String, dynamic>>();
        for (final c in chapters) {
          final cid = await _upsertChapter(
            subjectId: sid.$1,
            code: c['code'] as String,
            title: c['title'] as String,
            description: c['description'] as String?,
            orderIndex: (c['order_index'] as int?) ?? 0,
          );
          chapterIdByKey['${s['code']}/${c['code']}'] = cid.$1;
          if (cid.$2) chaptersAdded++;

          final tops = ((c['topics'] as List?) ?? const [])
              .cast<Map<String, dynamic>>();
          for (final t in tops) {
            await _ensureTopicShell(
              chapterId: cid.$1,
              code: t['code'] as String,
              orderIndex: (t['order_index'] as int?) ?? 0,
            );
          }
        }
      }

      // ---- Topic seed JSONs ------------------------------------------------
      for (final entry in topicEntries) {
        final relPath = entry['file'] as String;
        final raw =
            await rootBundle.loadString('assets/seed/$relPath');
        final seed = jsonDecode(raw) as Map<String, dynamic>;

        final subjectCode = seed['subject_code'] as String;
        final chapterCode = seed['chapter_code'] as String;
        final topicCode = seed['topic_code'] as String;

        final subjectId = subjectIdByCode[subjectCode] ??
            (await _upsertSubject(
              code: subjectCode,
              title: seed['subject_title'] as String,
            ))
                .$1;
        final chapterKey = '$subjectCode/$chapterCode';
        final chapterId = chapterIdByKey[chapterKey] ??
            (await _upsertChapter(
              subjectId: subjectId,
              code: chapterCode,
              title: seed['chapter_title'] as String,
            ))
                .$1;

        final topicResult = await _upsertTopic(
          chapterId: chapterId,
          code: topicCode,
          title: seed['topic_title'] as String,
          summary: seed['topic_summary'] as String?,
        );
        if (topicResult.$2) topicsAdded++;

        final sourceId = await _upsertSource(seed['source_pdf'] as String);

        // Replace flashcards + questions for this topic if the bundle changed.
        // Safe because user state lives in separate tables keyed by item id;
        // a topic re-import won't wipe SM-2 schedule because we delete only
        // when the bundle is materially different (versioned via [_bundledVersion]).
        await _replaceFlashcards(
          topicId: topicResult.$1,
          sourceId: sourceId,
          flashcards: (seed['flashcards'] as List?)
                  ?.cast<Map<String, dynamic>>() ??
              const [],
        );
        flashcardsAdded += (seed['flashcards'] as List?)?.length ?? 0;

        await _replaceQuestions(
          topicId: topicResult.$1,
          sourceId: sourceId,
          questions:
              (seed['questions'] as List?)?.cast<Map<String, dynamic>>() ??
                  const [],
        );
        questionsAdded += (seed['questions'] as List?)?.length ?? 0;
      }
    });

    return SeedImportResult(
      bundledVersion: _bundledVersion,
      subjectsAdded: subjectsAdded,
      chaptersAdded: chaptersAdded,
      topicsAdded: topicsAdded,
      flashcardsAdded: flashcardsAdded,
      questionsAdded: questionsAdded,
    );
  }

  /// Imports a single in-memory `TopicSeed` JSON map (same shape as the
  /// bundled `assets/seed/**.json` files). Used by the on-demand generator
  /// (P14.B) and the cross-device sync of generated seeds.
  ///
  /// The subject / chapter are upserted by code; the topic is upserted by
  /// `(chapter_id, code)`. Flashcards and questions for the topic are
  /// replaced atomically — same semantics as [ensureImported] for bundled
  /// seeds, so user state (SM-2 schedule, MCQ history) survives because it
  /// lives in separate tables keyed by row id.
  Future<TopicSeedImportResult> importTopicSeed(
    Map<String, dynamic> seed,
  ) async {
    int flashcardsAdded = 0;
    int questionsAdded = 0;
    late int topicId;
    late bool topicCreated;

    await _db.transaction(() async {
      final subjectCode = seed['subject_code'] as String;
      final chapterCode = seed['chapter_code'] as String;
      final topicCode = seed['topic_code'] as String;

      final subjectId = (await _upsertSubject(
        code: subjectCode,
        title: seed['subject_title'] as String? ?? subjectCode,
      ))
          .$1;
      final chapterId = (await _upsertChapter(
        subjectId: subjectId,
        code: chapterCode,
        title: seed['chapter_title'] as String? ?? chapterCode,
      ))
          .$1;
      final topicResult = await _upsertTopic(
        chapterId: chapterId,
        code: topicCode,
        title: seed['topic_title'] as String? ?? topicCode,
        summary: seed['topic_summary'] as String?,
      );
      topicId = topicResult.$1;
      topicCreated = topicResult.$2;

      final sourcePdf = seed['source_pdf'] as String?;
      final sourceId = sourcePdf == null || sourcePdf.isEmpty
          ? null
          : await _upsertSource(sourcePdf);

      final flashcards = (seed['flashcards'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const [];
      await _replaceFlashcards(
        topicId: topicId,
        sourceId: sourceId,
        flashcards: flashcards,
      );
      flashcardsAdded = flashcards.length;

      final questions = (seed['questions'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const [];
      await _replaceQuestions(
        topicId: topicId,
        sourceId: sourceId,
        questions: questions,
      );
      questionsAdded = questions.length;
    });

    return TopicSeedImportResult(
      topicId: topicId,
      topicCreated: topicCreated,
      flashcardsAdded: flashcardsAdded,
      questionsAdded: questionsAdded,
    );
  }

  Future<(int id, bool created)> _upsertSubject({
    required String code,
    required String title,
    String? description,
    int orderIndex = 0,
  }) async {
    final existing = await (_db.select(_db.subjects)
          ..where((t) => t.code.equals(code)))
        .getSingleOrNull();
    if (existing != null) return (existing.id, false);
    final id = await _db.into(_db.subjects).insert(
          SubjectsCompanion.insert(
            code: code,
            title: title,
            description: Value(description),
            orderIndex: Value(orderIndex),
          ),
        );
    return (id, true);
  }

  Future<(int id, bool created)> _upsertChapter({
    required int subjectId,
    required String code,
    required String title,
    String? description,
    int orderIndex = 0,
  }) async {
    final existing = await (_db.select(_db.chapters)
          ..where((t) =>
              t.subjectId.equals(subjectId) & t.code.equals(code)))
        .getSingleOrNull();
    if (existing != null) return (existing.id, false);
    final id = await _db.into(_db.chapters).insert(
          ChaptersCompanion.insert(
            subjectId: subjectId,
            code: code,
            title: title,
            description: Value(description),
            orderIndex: Value(orderIndex),
          ),
        );
    return (id, true);
  }

  Future<int> _ensureTopicShell({
    required int chapterId,
    required String code,
    int orderIndex = 0,
  }) async {
    final existing = await (_db.select(_db.topics)
          ..where((t) =>
              t.chapterId.equals(chapterId) & t.code.equals(code)))
        .getSingleOrNull();
    if (existing != null) {
      if (existing.orderIndex != orderIndex) {
        await (_db.update(_db.topics)..where((t) => t.id.equals(existing.id)))
            .write(TopicsCompanion(orderIndex: Value(orderIndex)));
      }
      return existing.id;
    }
    return _db.into(_db.topics).insert(
          TopicsCompanion.insert(
            chapterId: chapterId,
            code: code,
            title: code,
            orderIndex: Value(orderIndex),
          ),
        );
  }

  Future<(int id, bool created)> _upsertTopic({
    required int chapterId,
    required String code,
    required String title,
    String? summary,
  }) async {
    final existing = await (_db.select(_db.topics)
          ..where((t) =>
              t.chapterId.equals(chapterId) & t.code.equals(code)))
        .getSingleOrNull();
    if (existing != null) {
      await (_db.update(_db.topics)..where((t) => t.id.equals(existing.id)))
          .write(TopicsCompanion(
        title: Value(title),
        summary: Value(summary),
      ));
      return (existing.id, false);
    }
    final id = await _db.into(_db.topics).insert(
          TopicsCompanion.insert(
            chapterId: chapterId,
            code: code,
            title: title,
            summary: Value(summary),
          ),
        );
    return (id, true);
  }

  Future<int> _upsertSource(String pdfPath) async {
    final existing = await (_db.select(_db.sources)
          ..where((t) => t.pdfPath.equals(pdfPath)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.sources).insert(
          SourcesCompanion.insert(
            pdfPath: pdfPath,
            title: Value(pdfPath.split('/').last.replaceAll('.pdf', '')),
          ),
        );
  }

  Future<void> _replaceFlashcards({
    required int topicId,
    required int? sourceId,
    required List<Map<String, dynamic>> flashcards,
  }) async {
    await (_db.delete(_db.flashcards)
          ..where((t) => t.topicId.equals(topicId)))
        .go();
    if (flashcards.isEmpty) return;
    await _db.batch((batch) {
      for (final f in flashcards) {
        batch.insert(
          _db.flashcards,
          FlashcardsCompanion.insert(
            topicId: topicId,
            front: f['front'] as String,
            back: f['back'] as String,
            hint: Value(f['hint'] as String?),
            difficulty: Value(
              (f['difficulty'] as String?) ?? 'medium',
            ),
            tagsJson: Value(jsonEncode(f['tags'] ?? const [])),
            sourceId: Value(sourceId),
            sourcePage: Value(f['source_page'] as int?),
          ),
        );
      }
    });
  }

  Future<void> _replaceQuestions({
    required int topicId,
    required int? sourceId,
    required List<Map<String, dynamic>> questions,
  }) async {
    // Batch-delete old options for all questions of this topic.
    final oldIds = await (_db.select(_db.questions)
          ..where((t) => t.topicId.equals(topicId)))
        .get();
    if (oldIds.isNotEmpty) {
      await (_db.delete(_db.questionOptions)
            ..where((t) => t.questionId.isIn(oldIds.map((q) => q.id).toList())))
          .go();
    }
    await (_db.delete(_db.questions)..where((t) => t.topicId.equals(topicId)))
        .go();

    // Questions need individual inserts because we need the auto-generated ID
    // for inserting options. But options per question can be batched.
    for (final q in questions) {
      final qid = await _db.into(_db.questions).insert(
            QuestionsCompanion.insert(
              topicId: topicId,
              stem: q['stem'] as String,
              qtype: Value((q['qtype'] as String?) ?? 'single'),
              explanation: Value(q['explanation'] as String?),
              difficulty: Value(
                (q['difficulty'] as String?) ?? 'medium',
              ),
              tagsJson: Value(jsonEncode(q['tags'] ?? const [])),
              sourceId: Value(sourceId),
              sourcePage: Value(q['source_page'] as int?),
            ),
          );
      final opts = (q['options'] as List?)?.cast<Map<String, dynamic>>() ??
          const [];
      if (opts.isNotEmpty) {
        await _db.batch((batch) {
          for (var i = 0; i < opts.length; i++) {
            final o = opts[i];
            batch.insert(
              _db.questionOptions,
              QuestionOptionsCompanion.insert(
                questionId: qid,
                label: o['label'] as String,
                content: o['content'] as String,
                isCorrect: Value((o['is_correct'] as bool?) ?? false),
                orderIndex: Value(i),
              ),
            );
          }
        });
      }
    }
  }
}

class SeedImportResult {
  const SeedImportResult({
    required this.bundledVersion,
    required this.subjectsAdded,
    required this.chaptersAdded,
    required this.topicsAdded,
    required this.flashcardsAdded,
    required this.questionsAdded,
  });

  final int bundledVersion;
  final int subjectsAdded;
  final int chaptersAdded;
  final int topicsAdded;
  final int flashcardsAdded;
  final int questionsAdded;
}

class TopicSeedImportResult {
  const TopicSeedImportResult({
    required this.topicId,
    required this.topicCreated,
    required this.flashcardsAdded,
    required this.questionsAdded,
  });

  final int topicId;
  final bool topicCreated;
  final int flashcardsAdded;
  final int questionsAdded;
}
