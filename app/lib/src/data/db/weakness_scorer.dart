// Phase 14.C — Weakness scorer.
//
// For each topic the user has touched, compute a 0..1 weakness score from
// three signals:
//   - MCQ accuracy        : 1 - correct/attempts            (more wrong = weaker)
//   - avg flashcard ease  : (2.5 - avg_ease) / 1.5 clamped   (lower SM-2 ease = weaker)
//   - due-card ratio      : due_cards / topic_total_cards    (more overdue = weaker)
//
// Combined = 0.5 * accuracy + 0.3 * ease + 0.2 * due. Higher = more weak.
// Topics with no reviewed items are excluded — a never-touched topic is
// "untouched", not "weak", and would otherwise dominate the ranking.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'content_repository.dart';

class WeaknessEntry {
  const WeaknessEntry({
    required this.topic,
    required this.subject,
    required this.chapter,
    required this.score,
    required this.mcqAccuracy,
    required this.avgEase,
    required this.dueRatio,
    required this.attempts,
    required this.cardsReviewed,
  });

  final Topic topic;
  final Subject subject;
  final Chapter chapter;

  /// 0..1, higher = weaker. Always in this range because each component is
  /// clamped before combining.
  final double score;

  /// MCQ accuracy 0..1. `null` when the user has never answered an MCQ in
  /// this topic — surfaced separately so the UI can say "not enough data".
  final double? mcqAccuracy;

  /// Average ease across reviewed flashcards. `null` when the user has
  /// never reviewed a flashcard in this topic.
  final double? avgEase;

  /// `due_cards / total_cards` in this topic, in 0..1.
  final double dueRatio;

  /// Number of MCQ attempts for this topic (sum of `attempts` across all
  /// questions). Used to gate "not enough data" UI copy.
  final int attempts;

  /// Number of flashcards the user has rated at least once in this topic.
  final int cardsReviewed;
}

class WeaknessScorer {
  WeaknessScorer(this._db);

  final AppDatabase _db;

  static const _wAccuracy = 0.5;
  static const _wEase = 0.3;
  static const _wDue = 0.2;

  /// Returns the [limit] weakest topics (by combined score, descending).
  /// Topics that the user hasn't touched at all (no MCQ attempts AND no
  /// reviewed flashcards) are excluded.
  Future<List<WeaknessEntry>> topWeakTopics({
    int limit = 3,
    DateTime? now,
  }) async {
    final ts = now ?? DateTime.now().toUtc();
    final entries = await allScores(now: ts);
    entries.removeWhere((e) => e.attempts == 0 && e.cardsReviewed == 0);
    entries.sort((a, b) => b.score.compareTo(a.score));
    if (entries.length <= limit) return entries;
    return entries.sublist(0, limit);
  }

  /// All topics with their score (including untouched ones — caller
  /// decides whether to filter). Used by the sync layer that mirrors
  /// scores across devices.
  Future<List<WeaknessEntry>> allScores({DateTime? now}) async {
    final ts = now ?? DateTime.now().toUtc();
    return _scoreAll(now: ts);
  }

  Future<List<WeaknessEntry>> _scoreAll({required DateTime now}) async {
    final topics = await _db.select(_db.topics).get();
    final chapters = {
      for (final c in await _db.select(_db.chapters).get()) c.id: c,
    };
    final subjects = {
      for (final s in await _db.select(_db.subjects).get()) s.id: s,
    };

    final allCards = await _db.select(_db.flashcards).get();
    final allQuestions = await _db.select(_db.questions).get();
    final cardStates = {
      for (final s in await _db.select(_db.userCardState).get())
        s.flashcardId: s,
    };
    final questionStates = {
      for (final s in await _db.select(_db.userQuestionState).get())
        s.questionId: s,
    };

    final out = <WeaknessEntry>[];
    for (final topic in topics) {
      final chapter = chapters[topic.chapterId];
      if (chapter == null) continue;
      final subject = subjects[chapter.subjectId];
      if (subject == null) continue;

      final topicCards = allCards.where((c) => c.topicId == topic.id).toList();
      final topicQuestions =
          allQuestions.where((q) => q.topicId == topic.id).toList();

      var attempts = 0;
      var correct = 0;
      for (final q in topicQuestions) {
        final s = questionStates[q.id];
        if (s == null) continue;
        attempts += s.attempts;
        correct += s.correct;
      }

      var easeSum = 0.0;
      var cardsReviewed = 0;
      var dueCards = 0;
      for (final c in topicCards) {
        final s = cardStates[c.id];
        if (s == null) {
          // Never reviewed. Not "due" by SM-2 definition; counts as new.
          continue;
        }
        cardsReviewed++;
        easeSum += s.ease;
        final next = s.nextReview;
        if (next == null || !next.isAfter(now)) {
          dueCards++;
        }
      }

      final accuracy = attempts == 0 ? null : (correct / attempts);
      final accuracyFactor = accuracy == null ? 0.0 : (1 - accuracy);

      final avgEase = cardsReviewed == 0 ? null : (easeSum / cardsReviewed);
      final easeFactor = avgEase == null
          ? 0.0
          : ((2.5 - avgEase) / 1.5).clamp(0.0, 1.0).toDouble();

      final dueRatio = topicCards.isEmpty
          ? 0.0
          : (dueCards / topicCards.length).clamp(0.0, 1.0).toDouble();

      // Re-normalise weights based on which signals exist. Without this,
      // a topic with no MCQs would always score lower than one with MCQs
      // even if the user is struggling badly with its flashcards.
      final wA = accuracy == null ? 0.0 : _wAccuracy;
      final wE = avgEase == null ? 0.0 : _wEase;
      final wD = topicCards.isEmpty ? 0.0 : _wDue;
      final totalW = wA + wE + wD;
      final score = totalW == 0
          ? 0.0
          : (wA * accuracyFactor + wE * easeFactor + wD * dueRatio) / totalW;

      out.add(
        WeaknessEntry(
          topic: topic,
          subject: subject,
          chapter: chapter,
          score: score,
          mcqAccuracy: accuracy,
          avgEase: avgEase,
          dueRatio: dueRatio,
          attempts: attempts,
          cardsReviewed: cardsReviewed,
        ),
      );
    }
    return out;
  }
}

final weaknessScorerProvider = Provider<WeaknessScorer>((ref) {
  return WeaknessScorer(ref.watch(appDatabaseProvider));
});

final topWeakTopicsProvider =
    FutureProvider.autoDispose<List<WeaknessEntry>>((ref) {
  return ref.watch(weaknessScorerProvider).topWeakTopics(limit: 3);
});
