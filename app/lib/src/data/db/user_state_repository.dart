// User-state repository: persists per-card SM-2 state and per-question
// attempt history, and exposes the "Today" review queue.

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/content_repository.dart';
import '../../features/study/sm2.dart';
import '../../features/study/study_session_controller.dart';

class UserStateRepository {
  UserStateRepository(this._db);
  final AppDatabase _db;

  /// Upsert SM-2 state for a flashcard given a user rating.
  Future<Sm2Update> recordFlashcardRating(
    int flashcardId,
    CardRating rating, {
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final prev = await (_db.select(_db.userCardState)
          ..where((s) => s.flashcardId.equals(flashcardId)))
        .getSingleOrNull();
    final update = applySm2(
      rating: rating,
      prevEase: prev?.ease ?? 2.5,
      prevIntervalDays: prev?.intervalDays ?? 0,
      prevReviewCount: prev?.reviewCount ?? 0,
      now: t,
    );
    final companion = toCompanion(
      flashcardId,
      update,
      lastResult: rating.name,
      now: t,
    );
    await _db
        .into(_db.userCardState)
        .insert(companion, mode: InsertMode.insertOrReplace);
    return update;
  }

  /// Upsert MCQ attempt: increments `attempts` and `correct` (if right).
  Future<void> recordQuestionAttempt(
    int questionId, {
    required bool wasCorrect,
    required String choice,
    DateTime? now,
  }) async {
    final t = now ?? DateTime.now();
    final prev = await (_db.select(_db.userQuestionState)
          ..where((q) => q.questionId.equals(questionId)))
        .getSingleOrNull();
    final attempts = (prev?.attempts ?? 0) + 1;
    final correct = (prev?.correct ?? 0) + (wasCorrect ? 1 : 0);
    await _db.into(_db.userQuestionState).insert(
          UserQuestionStateCompanion.insert(
            questionId: Value(questionId),
            attempts: Value(attempts),
            correct: Value(correct),
            lastAttempt: Value(t),
            lastChoice: Value(choice),
            updatedAt: Value(t),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// All flashcards whose [nextReview] is on/before [asOf]. New cards
  /// (no row in `user_card_state`) are also included so the user has
  /// something to study on day one.
  Future<List<Flashcard>> dueFlashcards({DateTime? asOf, int limit = 50}) async {
    final t = asOf ?? DateTime.now();
    final query = _db.select(_db.flashcards).join([
      leftOuterJoin(
        _db.userCardState,
        _db.userCardState.flashcardId.equalsExp(_db.flashcards.id),
      ),
    ])
      ..where(
        _db.userCardState.flashcardId.isNull() |
            _db.userCardState.nextReview.isSmallerOrEqualValue(t),
      )
      ..limit(limit);
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.flashcards)).toList();
  }

  /// Counts for the Home dashboard.
  Future<DueCounts> dueCounts({DateTime? asOf}) async {
    final t = asOf ?? DateTime.now();
    final dueExp = _db.userCardState.flashcardId.isNull() |
        _db.userCardState.nextReview.isSmallerOrEqualValue(t);
    final dueQuery = _db.selectOnly(_db.flashcards).join([
      leftOuterJoin(
        _db.userCardState,
        _db.userCardState.flashcardId.equalsExp(_db.flashcards.id),
      ),
    ])
      ..addColumns([_db.flashcards.id.count()])
      ..where(dueExp);
    final dueRow = await dueQuery.getSingle();
    final due = dueRow.read(_db.flashcards.id.count()) ?? 0;

    final newQuery = _db.selectOnly(_db.flashcards).join([
      leftOuterJoin(
        _db.userCardState,
        _db.userCardState.flashcardId.equalsExp(_db.flashcards.id),
      ),
    ])
      ..addColumns([_db.flashcards.id.count()])
      ..where(_db.userCardState.flashcardId.isNull());
    final newRow = await newQuery.getSingle();
    final newCount = newRow.read(_db.flashcards.id.count()) ?? 0;

    final total = await (_db.selectOnly(_db.flashcards)
          ..addColumns([_db.flashcards.id.count()]))
        .getSingle();
    return DueCounts(
      due: due,
      newCount: newCount,
      total: total.read(_db.flashcards.id.count()) ?? 0,
    );
  }
}

class DueCounts {
  const DueCounts({
    required this.due,
    required this.newCount,
    required this.total,
  });
  final int due;
  final int newCount;
  final int total;
}

final userStateRepositoryProvider = Provider<UserStateRepository>((ref) {
  return UserStateRepository(ref.watch(appDatabaseProvider));
});

final dueCountsProvider = FutureProvider.autoDispose<DueCounts>((ref) async {
  return ref.watch(userStateRepositoryProvider).dueCounts();
});

final dueFlashcardsProvider =
    FutureProvider.autoDispose<List<Flashcard>>((ref) async {
  return ref.watch(userStateRepositoryProvider).dueFlashcards();
});
