// Phase 11 — Sync engine. Turns local drift rows into envelopes and back.
//
// Conflict resolution is last-write-wins per `(kind, item_key)`, keyed
// on each row's `updatedAt`. This is simple and deterministic: if you
// review a card on phone A at 10:00 and on phone B at 10:01, the 10:01
// state wins regardless of which device pushes first.

import 'package:drift/drift.dart';

import '../data/db/app_database.dart';
import '../data/db/weakness_scorer.dart';
import '../data/seed/seed_importer.dart';
import 'remote_weakness_store.dart';
import 'sync_remote.dart';
import 'sync_types.dart';

class SyncEngine {
  SyncEngine(
    this._db,
    this._remote, {
    SeedImporter? seedImporter,
    WeaknessScorer? weaknessScorer,
    RemoteWeaknessStore? remoteWeaknessStore,
  })  : _seedImporter = seedImporter ?? SeedImporter(_db),
        _weaknessScorer = weaknessScorer ?? WeaknessScorer(_db),
        _remoteWeaknessStore = remoteWeaknessStore;

  final AppDatabase _db;
  final SyncRemote _remote;
  final SeedImporter _seedImporter;
  final WeaknessScorer _weaknessScorer;

  /// Optional: when present, inbound `topic_weakness` envelopes are merged
  /// into this store. When absent (e.g. unit tests for the older P11 flow),
  /// the envelopes are applied as no-ops.
  final RemoteWeaknessStore? _remoteWeaknessStore;

  /// Snapshots all syncable local rows for a given pairing.
  Future<List<SyncEnvelope>> collectLocalEnvelopes({
    required String code,
    required String deviceId,
  }) async {
    // Fire all four data queries in parallel.
    final futures = await Future.wait([
      _db.select(_db.userCardState).get(),
      _db.select(_db.userQuestionState).get(),
      _db.select(_db.userBookmarks).get(),
      _weaknessScorer.allScores(),
    ]);
    final cards = futures[0] as List<UserCardStateData>;
    final questions = futures[1] as List<UserQuestionStateData>;
    final bookmarks = futures[2] as List<UserBookmark>;
    final weakness = futures[3] as List<WeaknessEntry>;

    final envs = <SyncEnvelope>[];

    for (final c in cards) {
      envs.add(
        SyncEnvelope(
          code: code,
          deviceId: deviceId,
          kind: SyncKinds.cardState,
          itemKey: c.flashcardId.toString(),
          payload: <String, dynamic>{
            'ease': c.ease,
            'interval_days': c.intervalDays,
            'next_review': c.nextReview?.toUtc().toIso8601String(),
            'last_result': c.lastResult,
            'review_count': c.reviewCount,
          },
          updatedAt: c.updatedAt.toUtc(),
        ),
      );
    }

    for (final q in questions) {
      envs.add(
        SyncEnvelope(
          code: code,
          deviceId: deviceId,
          kind: SyncKinds.questionState,
          itemKey: q.questionId.toString(),
          payload: <String, dynamic>{
            'attempts': q.attempts,
            'correct': q.correct,
            'last_attempt': q.lastAttempt?.toUtc().toIso8601String(),
            'last_choice': q.lastChoice,
          },
          updatedAt: q.updatedAt.toUtc(),
        ),
      );
    }

    for (final b in bookmarks) {
      envs.add(
        SyncEnvelope(
          code: code,
          deviceId: deviceId,
          kind: SyncKinds.bookmark,
          itemKey: '${b.itemKind}/${b.itemId}',
          payload: <String, dynamic>{
            'kind': b.itemKind,
            'item_id': b.itemId,
            'created_at': b.createdAt.toUtc().toIso8601String(),
          },
          updatedAt: b.createdAt.toUtc(),
        ),
      );
    }

    final now = DateTime.now().toUtc();
    for (final w in weakness) {
      envs.add(
        SyncEnvelope(
          code: code,
          deviceId: deviceId,
          kind: SyncKinds.topicWeakness,
          itemKey: w.topic.code,
          payload: <String, dynamic>{
            'score': w.score,
            if (w.mcqAccuracy != null) 'mcq_accuracy': w.mcqAccuracy,
            if (w.avgEase != null) 'avg_ease': w.avgEase,
            'due_ratio': w.dueRatio,
            'attempts': w.attempts,
            'cards_reviewed': w.cardsReviewed,
          },
          updatedAt: now,
        ),
      );
    }

    return envs;
  }

  /// Apply a single inbound envelope into the local DB. Returns true if
  /// the row was applied, false if it was older than what's already
  /// stored locally.
  Future<bool> applyEnvelope(SyncEnvelope env) async {
    switch (env.kind) {
      case SyncKinds.cardState:
        final id = int.tryParse(env.itemKey);
        if (id == null) return false;
        final prev = await (_db.select(_db.userCardState)
              ..where((s) => s.flashcardId.equals(id)))
            .getSingleOrNull();
        if (prev != null && prev.updatedAt.toUtc().isAfter(env.updatedAt)) {
          return false;
        }
        await _db.into(_db.userCardState).insert(
              UserCardStateCompanion.insert(
                flashcardId: Value(id),
                ease: Value((env.payload['ease'] as num?)?.toDouble() ?? 2.5),
                intervalDays:
                    Value((env.payload['interval_days'] as num?)?.toInt() ?? 1),
                nextReview: Value(_parseDate(env.payload['next_review'])),
                lastResult: Value(env.payload['last_result'] as String?),
                reviewCount:
                    Value((env.payload['review_count'] as num?)?.toInt() ?? 0),
                updatedAt: Value(env.updatedAt),
              ),
              mode: InsertMode.insertOrReplace,
            );
        return true;
      case SyncKinds.questionState:
        final id = int.tryParse(env.itemKey);
        if (id == null) return false;
        final prev = await (_db.select(_db.userQuestionState)
              ..where((q) => q.questionId.equals(id)))
            .getSingleOrNull();
        if (prev != null && prev.updatedAt.toUtc().isAfter(env.updatedAt)) {
          return false;
        }
        await _db.into(_db.userQuestionState).insert(
              UserQuestionStateCompanion.insert(
                questionId: Value(id),
                attempts:
                    Value((env.payload['attempts'] as num?)?.toInt() ?? 0),
                correct: Value((env.payload['correct'] as num?)?.toInt() ?? 0),
                lastAttempt: Value(_parseDate(env.payload['last_attempt'])),
                lastChoice: Value(env.payload['last_choice'] as String?),
                updatedAt: Value(env.updatedAt),
              ),
              mode: InsertMode.insertOrReplace,
            );
        return true;
      case SyncKinds.bookmark:
        final kind = env.payload['kind'] as String?;
        final itemId = (env.payload['item_id'] as num?)?.toInt();
        if (kind == null || itemId == null) return false;
        final exists = await (_db.select(_db.userBookmarks)
              ..where((b) =>
                  b.itemKind.equals(kind) & b.itemId.equals(itemId)))
            .getSingleOrNull();
        if (exists != null) return false;
        await _db.into(_db.userBookmarks).insert(
              UserBookmarksCompanion.insert(
                itemKind: kind,
                itemId: itemId,
                createdAt: Value(env.updatedAt),
              ),
            );
        return true;
      case SyncKinds.generatedSeed:
        // Idempotent: re-importing an already-imported seed is a no-op
        // because `importTopicSeed` upserts the topic row and replaces
        // its flashcards / questions atomically. User state lives in
        // separate tables keyed by row id, so it survives re-import.
        await _seedImporter.importTopicSeed(env.payload);
        return true;
      case SyncKinds.topicWeakness:
        final store = _remoteWeaknessStore;
        if (store == null) return false;
        final entry = RemoteWeaknessEntry(
          topicCode: env.itemKey,
          score: (env.payload['score'] as num?)?.toDouble() ?? 0.0,
          updatedAt: env.updatedAt,
          mcqAccuracy: (env.payload['mcq_accuracy'] as num?)?.toDouble(),
          avgEase: (env.payload['avg_ease'] as num?)?.toDouble(),
          dueRatio: (env.payload['due_ratio'] as num?)?.toDouble(),
          attempts: (env.payload['attempts'] as num?)?.toInt() ?? 0,
          cardsReviewed:
              (env.payload['cards_reviewed'] as num?)?.toInt() ?? 0,
        );
        final applied = await store.mergeFromRemote([entry]);
        return applied > 0;
      default:
        return false;
    }
  }

  /// Performs a single push + pull round-trip. Returns counts of what
  /// was uploaded vs downloaded vs applied.
  Future<SyncRoundResult> sync({
    required String code,
    required String myDeviceId,
    DateTime? since,
  }) async {
    final local = await collectLocalEnvelopes(
      code: code,
      deviceId: myDeviceId,
    );
    await _remote.upsertPayloadBatch(local);
    final remote = await _remote.readRemotePayloads(
      code: code,
      myDeviceId: myDeviceId,
      since: since,
    );
    // Wrap all applies in a single transaction to reduce WAL overhead.
    var applied = 0;
    if (remote.isNotEmpty) {
      await _db.transaction(() async {
        for (final env in remote) {
          if (await applyEnvelope(env)) applied++;
        }
      });
    }
    return SyncRoundResult(
      uploaded: local.length,
      downloaded: remote.length,
      applied: applied,
      lastSyncedAt: DateTime.now().toUtc(),
    );
  }
}

DateTime? _parseDate(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String && v.isNotEmpty) {
    return DateTime.tryParse(v)?.toUtc();
  }
  return null;
}

class SyncRoundResult {
  const SyncRoundResult({
    required this.uploaded,
    required this.downloaded,
    required this.applied,
    required this.lastSyncedAt,
  });
  final int uploaded;
  final int downloaded;
  final int applied;
  final DateTime lastSyncedAt;
}

// `SyncController` wires the engine to a concrete remote at runtime.
