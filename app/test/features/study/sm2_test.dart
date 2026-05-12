// Pure SM-2 progression tests. Asserts ease/interval evolve correctly
// across Again / Hard / Good / Easy sequences.

import 'package:flutter_test/flutter_test.dart';

import 'package:socdaily_app/src/features/study/sm2.dart';
import 'package:socdaily_app/src/features/study/study_session_controller.dart';

void main() {
  final t0 = DateTime.utc(2025, 1, 1);

  test('first Good schedules 1 day later, sets reviewCount=1', () {
    final u = applySm2(rating: CardRating.good, now: t0);
    expect(u.intervalDays, 1);
    expect(u.reviewCount, 1);
    expect(u.nextReview, t0.add(const Duration(days: 1)));
    expect(u.ease, greaterThan(2.4)); // q=4 keeps ease about unchanged
  });

  test('second Good schedules 6 days later', () {
    final first = applySm2(rating: CardRating.good, now: t0);
    final second = applySm2(
      rating: CardRating.good,
      prevEase: first.ease,
      prevIntervalDays: first.intervalDays,
      prevReviewCount: first.reviewCount,
      now: t0.add(const Duration(days: 1)),
    );
    expect(second.intervalDays, 6);
    expect(second.reviewCount, 2);
  });

  test('third Good grows by ease factor', () {
    var u = applySm2(rating: CardRating.good, now: t0);
    u = applySm2(
      rating: CardRating.good,
      prevEase: u.ease,
      prevIntervalDays: u.intervalDays,
      prevReviewCount: u.reviewCount,
      now: t0,
    );
    final third = applySm2(
      rating: CardRating.good,
      prevEase: u.ease,
      prevIntervalDays: u.intervalDays,
      prevReviewCount: u.reviewCount,
      now: t0,
    );
    // 6 * ~2.5 ≈ 15
    expect(third.intervalDays, inInclusiveRange(13, 17));
  });

  test('Again resets interval to 1 and drops ease', () {
    var u = applySm2(rating: CardRating.good, now: t0);
    u = applySm2(
      rating: CardRating.good,
      prevEase: u.ease,
      prevIntervalDays: u.intervalDays,
      prevReviewCount: u.reviewCount,
      now: t0,
    );
    final lapse = applySm2(
      rating: CardRating.again,
      prevEase: u.ease,
      prevIntervalDays: u.intervalDays,
      prevReviewCount: u.reviewCount,
      now: t0,
    );
    expect(lapse.intervalDays, 1);
    expect(lapse.ease, lessThan(u.ease));
  });

  test('Ease never drops below 1.3', () {
    var u = applySm2(rating: CardRating.again, now: t0);
    for (var i = 0; i < 20; i++) {
      u = applySm2(
        rating: CardRating.again,
        prevEase: u.ease,
        prevIntervalDays: u.intervalDays,
        prevReviewCount: u.reviewCount,
        now: t0,
      );
    }
    expect(u.ease, greaterThanOrEqualTo(1.3));
  });

  test('Easy stretches interval further than Good', () {
    var good = applySm2(rating: CardRating.good, now: t0);
    good = applySm2(
      rating: CardRating.good,
      prevEase: good.ease,
      prevIntervalDays: good.intervalDays,
      prevReviewCount: good.reviewCount,
      now: t0,
    );
    final easyNext = applySm2(
      rating: CardRating.easy,
      prevEase: good.ease,
      prevIntervalDays: good.intervalDays,
      prevReviewCount: good.reviewCount,
      now: t0,
    );
    final goodNext = applySm2(
      rating: CardRating.good,
      prevEase: good.ease,
      prevIntervalDays: good.intervalDays,
      prevReviewCount: good.reviewCount,
      now: t0,
    );
    expect(easyNext.intervalDays, greaterThan(goodNext.intervalDays));
  });
}
