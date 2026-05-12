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

  Future<ContentCounts> globalCounts() async {
    final s = await _db.subjects.count().getSingle();
    final c = await _db.chapters.count().getSingle();
    final t = await _db.topics.count().getSingle();
    final f = await _db.flashcards.count().getSingle();
    final q = await _db.questions.count().getSingle();
    return ContentCounts(
      subjects: s,
      chapters: c,
      topics: t,
      flashcards: f,
      questions: q,
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
