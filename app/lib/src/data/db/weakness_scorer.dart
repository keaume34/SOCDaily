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

import 'package:drift/drift.dart';
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
    // Load taxonomy once — these are small tables.
    final topicsFuture = _db.select(_db.topics).get();
    final chaptersFuture = _db.select(_db.chapters).get();
    final subjectsFuture = _db.select(_db.subjects).get();
    final taxonomy = await Future.wait([topicsFuture, chaptersFuture, subjectsFuture]);
    final topics = taxonomy[0] as List<Topic>;
    final chapters = {for (final c in taxonomy[1] as List<Chapter>) c.id: c};
    final subjects = {for (final s in taxonomy[2] as List<Subject>) s.id: s};

    // Fire all three aggregate queries in parallel — they're independent.
    final mcqFuture = (_db.selectOnly(_db.questions).join([
      innerJoin(_db.userQuestionState,
          _db.userQuestionState.questionId.equalsExp(_db.questions.id)),
    ])
          ..addColumns([
            _db.questions.topicId,
            _db.userQuestionState.attempts.sum(),
            _db.userQuestionState.correct.sum(),
          ])
          ..groupBy([_db.questions.topicId]))
        .get();

    final cardFuture = (_db.selectOnly(_db.flashcards).join([
      leftOuterJoin(_db.userCardState,
          _db.userCardState.flashcardId.equalsExp(_db.flashcards.id)),
    ])
          ..addColumns([
            _db.flashcards.topicId,
            _db.flashcards.id.count(),
            _db.userCardState.flashcardId.count(),
            _db.userCardState.ease.sum(),
          ])
          ..groupBy([_db.flashcards.topicId]))
        .get();

    final dueFuture = (_db.selectOnly(_db.flashcards).join([
      leftOuterJoin(_db.userCardState,
          _db.userCardState.flashcardId.equalsExp(_db.flashcards.id)),
    ])
          ..addColumns([
            _db.flashcards.topicId,
            _db.flashcards.id.count(),
          ])
          ..where(_db.userCardState.flashcardId.isNotNull() &
              (_db.userCardState.nextReview.isNull() |
                  _db.userCardState.nextReview.isSmallerOrEqualValue(now)))
          ..groupBy([_db.flashcards.topicId]))
        .get();

    final aggResults = await Future.wait([mcqFuture, cardFuture, dueFuture]);
    final mcqRows = aggResults[0];
    final cardRows = aggResults[1];
    final dueRows = aggResults[2];

    final mcqByTopic = <int, ({int attempts, int correct})>{};
    for (final r in mcqRows) {
      final tid = r.read(_db.questions.topicId)!;
      mcqByTopic[tid] = (
        attempts: r.read(_db.userQuestionState.attempts.sum()) ?? 0,
        correct: r.read(_db.userQuestionState.correct.sum()) ?? 0,
      );
    }

    final cardStatsByTopic = <int, ({int total, int reviewed, double easeSum})>{};
    for (final r in cardRows) {
      final tid = r.read(_db.flashcards.topicId)!;
      cardStatsByTopic[tid] = (
        total: r.read(_db.flashcards.id.count()) ?? 0,
        reviewed: r.read(_db.userCardState.flashcardId.count()) ?? 0,
        easeSum: (r.read(_db.userCardState.ease.sum()) ?? 0).toDouble(),
      );
    }

    final dueByTopic = <int, int>{};
    for (final r in dueRows) {
      dueByTopic[r.read(_db.flashcards.topicId)!] =
          r.read(_db.flashcards.id.count()) ?? 0;
    }

    final out = <WeaknessEntry>[];
    for (final topic in topics) {
      final chapter = chapters[topic.chapterId];
      if (chapter == null) continue;
      final subject = subjects[chapter.subjectId];
      if (subject == null) continue;

      final mcq = mcqByTopic[topic.id];
      final attempts = mcq?.attempts ?? 0;
      final correct = mcq?.correct ?? 0;

      final cs = cardStatsByTopic[topic.id];
      final cardsReviewed = cs?.reviewed ?? 0;
      final easeSum = cs?.easeSum ?? 0.0;
      final totalCards = cs?.total ?? 0;
      final dueCards = dueByTopic[topic.id] ?? 0;

      final accuracy = attempts == 0 ? null : (correct / attempts);
      final accuracyFactor = accuracy == null ? 0.0 : (1 - accuracy);

      final avgEase = cardsReviewed == 0 ? null : (easeSum / cardsReviewed);
      final easeFactor = avgEase == null
          ? 0.0
          : ((2.5 - avgEase) / 1.5).clamp(0.0, 1.0).toDouble();

      final dueRatio = totalCards == 0
          ? 0.0
          : (dueCards / totalCards).clamp(0.0, 1.0).toDouble();

      // Re-normalise weights based on which signals exist. Without this,
      // a topic with no MCQs would always score lower than one with MCQs
      // even if the user is struggling badly with its flashcards.
      final wA = accuracy == null ? 0.0 : _wAccuracy;
      final wE = avgEase == null ? 0.0 : _wEase;
      final wD = totalCards == 0 ? 0.0 : _wDue;
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
