// Pure SM-2 implementation. Inputs are the previous card state + the user's
// 0..5 quality grade; outputs are the updated state (ease / interval /
// reviewCount / nextReview). Kept free of Flutter / drift imports so it is
// trivial to unit-test.
//
// Quality mapping used by the study player:
//   Again → 0
//   Hard  → 2
//   Good  → 4
//   Easy  → 5

import 'package:drift/drift.dart';

import '../../data/db/app_database.dart';
import 'study_session_controller.dart';

class Sm2Update {
  const Sm2Update({
    required this.ease,
    required this.intervalDays,
    required this.reviewCount,
    required this.nextReview,
    required this.quality,
  });

  final double ease;
  final int intervalDays;
  final int reviewCount;
  final DateTime nextReview;
  final int quality;
}

int qualityFor(CardRating r) {
  switch (r) {
    case CardRating.again:
      return 0;
    case CardRating.hard:
      return 2;
    case CardRating.good:
      return 4;
    case CardRating.easy:
      return 5;
  }
}

/// Pure SM-2 step. [now] is injectable for deterministic tests.
Sm2Update applySm2({
  required CardRating rating,
  double prevEase = 2.5,
  int prevIntervalDays = 0,
  int prevReviewCount = 0,
  DateTime? now,
}) {
  final q = qualityFor(rating);
  final t = now ?? DateTime.now();

  // Ease factor update.
  final updatedEase = (prevEase + 0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
      .clamp(1.3, double.infinity)
      .toDouble();

  int newInterval;
  int newReviewCount;

  if (q < 3) {
    // Lapse: reset interval, do not reset count (we still track exposures).
    newInterval = 1;
    newReviewCount = prevReviewCount + 1;
  } else {
    newReviewCount = prevReviewCount + 1;
    if (newReviewCount == 1) {
      newInterval = 1;
    } else if (newReviewCount == 2) {
      newInterval = 6;
    } else {
      newInterval = (prevIntervalDays * updatedEase).round().clamp(1, 365);
    }
    // Hard penalty: trim the interval a bit so "Hard" doesn't grow as fast.
    if (rating == CardRating.hard) {
      newInterval = (newInterval * 0.6).round().clamp(1, 365);
    }
    if (rating == CardRating.easy) {
      newInterval = (newInterval * 1.3).round().clamp(1, 365);
    }
  }

  return Sm2Update(
    ease: updatedEase,
    intervalDays: newInterval,
    reviewCount: newReviewCount,
    nextReview: t.add(Duration(days: newInterval)),
    quality: q,
  );
}

/// Convenience to materialize an [Sm2Update] as a drift companion ready to
/// upsert into `user_card_state`.
UserCardStateCompanion toCompanion(int flashcardId, Sm2Update u,
    {required String lastResult, DateTime? now}) {
  return UserCardStateCompanion.insert(
    flashcardId: Value(flashcardId),
    ease: Value(u.ease),
    intervalDays: Value(u.intervalDays),
    reviewCount: Value(u.reviewCount),
    nextReview: Value(u.nextReview),
    lastResult: Value(lastResult),
    updatedAt: Value(now ?? DateTime.now()),
  );
}
