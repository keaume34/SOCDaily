// Riverpod providers exposing the drift [AppDatabase] + a content repository
// that the UI layer talks to. Browse / Study / Stats screens never touch the
// raw DAOs directly — they consume these `*Provider`s instead.

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

class ContentRepository {
  ContentRepository(this._db);

  final AppDatabase _db;

  Future<List<Subject>> listSubjects() {
    return (_db.select(_db.subjects)
          ..orderBy([
            (s) => OrderingTerm(expression: s.orderIndex),
            (s) => OrderingTerm(expression: s.title),
          ]))
        .get();
  }

  Future<List<Chapter>> listChapters(int subjectId) {
    return (_db.select(_db.chapters)
          ..where((c) => c.subjectId.equals(subjectId))
          ..orderBy([
            (c) => OrderingTerm(expression: c.orderIndex),
            (c) => OrderingTerm(expression: c.title),
          ]))
        .get();
  }

  Future<List<Topic>> listTopics(int chapterId) {
    return (_db.select(_db.topics)
          ..where((t) => t.chapterId.equals(chapterId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.orderIndex),
            (t) => OrderingTerm(expression: t.title),
          ]))
        .get();
  }

  Future<List<Flashcard>> listFlashcardsForTopic(int topicId) {
    return (_db.select(_db.flashcards)
          ..where((f) => f.topicId.equals(topicId))
          ..orderBy([(f) => OrderingTerm(expression: f.id)]))
        .get();
  }

  Future<List<Question>> listQuestionsForTopic(int topicId) {
    return (_db.select(_db.questions)
          ..where((q) => q.topicId.equals(topicId))
          ..orderBy([(q) => OrderingTerm(expression: q.id)]))
        .get();
  }

  Future<List<QuestionOption>> listOptionsForQuestion(int questionId) {
    return (_db.select(_db.questionOptions)
          ..where((o) => o.questionId.equals(questionId))
          ..orderBy([(o) => OrderingTerm(expression: o.orderIndex)]))
        .get();
  }

  /// Batch-load options for multiple questions in a single query.
  /// Returns a map of questionId → sorted options list.
  Future<Map<int, List<QuestionOption>>> listOptionsForQuestions(
      List<int> questionIds) async {
    if (questionIds.isEmpty) return const {};
    final rows = await (_db.select(_db.questionOptions)
          ..where((o) => o.questionId.isIn(questionIds))
          ..orderBy([(o) => OrderingTerm(expression: o.orderIndex)]))
        .get();
    final map = <int, List<QuestionOption>>{};
    for (final o in rows) {
      (map[o.questionId] ??= []).add(o);
    }
    return map;
  }

  Future<List<Flashcard>> allFlashcards() {
    return (_db.select(_db.flashcards)
          ..orderBy([(f) => OrderingTerm(expression: f.id)]))
        .get();
  }

  Future<List<Question>> allQuestions() {
    return (_db.select(_db.questions)
          ..orderBy([(q) => OrderingTerm(expression: q.id)]))
        .get();
  }

  /// Deterministic daily picks: same set on every device for a given UTC
  /// calendar date. Returns `(flashcards, questions)`.
  Future<({List<Flashcard> flashcards, List<Question> questions})>
      dailyChallenge({
    DateTime? day,
    int flashcardCount = 5,
    int questionCount = 5,
  }) async {
    final d = day ?? DateTime.now().toUtc();
    final seed = d.year * 10000 + d.month * 100 + d.day;
    final allF = await allFlashcards();
    final allQ = await allQuestions();
    return (
      flashcards: _deterministicPick(allF, flashcardCount, seed),
      questions: _deterministicPick(allQ, questionCount, seed + 1),
    );
  }

  static List<T> _deterministicPick<T>(List<T> items, int n, int seed) {
    if (items.isEmpty || n <= 0) return const [];
    final rng = _LcgRng(seed);
    final indices = List<int>.generate(items.length, (i) => i);
    // Fisher-Yates with seeded RNG.
    for (var i = indices.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = indices[i];
      indices[i] = indices[j];
      indices[j] = tmp;
    }
    final take = n > items.length ? items.length : n;
    return [for (var k = 0; k < take; k++) items[indices[k]]];
  }

  Future<List<Question>> randomQuestions(int count, {int? seed}) async {
    final all = await allQuestions();
    if (all.isEmpty) return const [];
    final actualSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    return _deterministicPick(all, count, actualSeed);
  }

  Future<List<({Topic topic, List<Flashcard> flashcards})>>
      cheatsheetForSubject(int subjectId) async {
    // Single join query: chapters → topics → flashcards for this subject.
    final chapterIds = await (_db.select(_db.chapters)
          ..where((c) => c.subjectId.equals(subjectId)))
        .get()
        .then((list) => list.map((c) => c.id).toList());
    if (chapterIds.isEmpty) return const [];

    final topics = await (_db.select(_db.topics)
          ..where((t) => t.chapterId.isIn(chapterIds))
          ..orderBy([
            (t) => OrderingTerm(expression: t.orderIndex),
            (t) => OrderingTerm(expression: t.title),
          ]))
        .get();
    if (topics.isEmpty) return const [];

    final topicIds = topics.map((t) => t.id).toList();
    final allCards = await (_db.select(_db.flashcards)
          ..where((f) => f.topicId.isIn(topicIds))
          ..orderBy([(f) => OrderingTerm(expression: f.id)]))
        .get();

    final cardsByTopic = <int, List<Flashcard>>{};
    for (final c in allCards) {
      (cardsByTopic[c.topicId] ??= []).add(c);
    }

    return [
      for (final t in topics)
        if (cardsByTopic.containsKey(t.id))
          (topic: t, flashcards: cardsByTopic[t.id]!),
    ];
  }

  Future<ContentCounts> globalCounts() async {
    final results = await Future.wait([
      _db.subjects.count().getSingle(),
      _db.chapters.count().getSingle(),
      _db.topics.count().getSingle(),
      _db.flashcards.count().getSingle(),
      _db.questions.count().getSingle(),
    ]);
    return ContentCounts(
      subjects: results[0],
      chapters: results[1],
      topics: results[2],
      flashcards: results[3],
      questions: results[4],
    );
  }
}

class ContentCounts {
  const ContentCounts({
    required this.subjects,
    required this.chapters,
    required this.topics,
    required this.flashcards,
    required this.questions,
  });

  final int subjects;
  final int chapters;
  final int topics;
  final int flashcards;
  final int questions;
}

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(ref.watch(appDatabaseProvider));
});

final subjectsProvider = FutureProvider<List<Subject>>((ref) {
  return ref.watch(contentRepositoryProvider).listSubjects();
});

final chaptersProvider =
    FutureProvider.family<List<Chapter>, int>((ref, subjectId) {
  return ref.watch(contentRepositoryProvider).listChapters(subjectId);
});

final topicsProvider =
    FutureProvider.family<List<Topic>, int>((ref, chapterId) {
  return ref.watch(contentRepositoryProvider).listTopics(chapterId);
});

final contentCountsProvider = FutureProvider<ContentCounts>((ref) {
  return ref.watch(contentRepositoryProvider).globalCounts();
});

/// Tiny seeded linear-congruential RNG — keep daily challenge deterministic
/// across devices and time zones without dragging in `dart:math.Random`'s
/// platform variance for `nextInt(n)`.
class _LcgRng {
  _LcgRng(int seed) : _state = (seed == 0 ? 1 : seed) & 0x7fffffff;
  int _state;
  int nextInt(int bound) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % bound;
  }
}
