// Phase 14.C — Remote weakness store.
//
// SyncEngine pulls topic_weakness envelopes from the partner device into
// this in-memory + SharedPreferences-backed map. The Home weak-areas
// section can later fold these into the local scorer's output (e.g. show
// a "weak on the other device too" hint), but for now we just persist
// them so they survive app restarts.
//
// Stored as a JSON blob keyed by topic_code → score+metadata+updated_at.
// Last-write-wins on the timestamp.

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/settings/settings_controller.dart';

const _kRemoteWeaknessKey = 'sync.remote_weakness';

class RemoteWeaknessEntry {
  const RemoteWeaknessEntry({
    required this.topicCode,
    required this.score,
    required this.updatedAt,
    this.mcqAccuracy,
    this.avgEase,
    this.dueRatio,
    this.attempts = 0,
    this.cardsReviewed = 0,
  });

  final String topicCode;
  final double score;
  final DateTime updatedAt;
  final double? mcqAccuracy;
  final double? avgEase;
  final double? dueRatio;
  final int attempts;
  final int cardsReviewed;

  Map<String, dynamic> toJson() => {
        'score': score,
        'updated_at': updatedAt.toUtc().toIso8601String(),
        if (mcqAccuracy != null) 'mcq_accuracy': mcqAccuracy,
        if (avgEase != null) 'avg_ease': avgEase,
        if (dueRatio != null) 'due_ratio': dueRatio,
        'attempts': attempts,
        'cards_reviewed': cardsReviewed,
      };

  static RemoteWeaknessEntry? fromJson(
    String topicCode,
    Map<String, dynamic> m,
  ) {
    final score = (m['score'] as num?)?.toDouble();
    final ts = m['updated_at'] as String?;
    if (score == null || ts == null) return null;
    return RemoteWeaknessEntry(
      topicCode: topicCode,
      score: score,
      updatedAt: DateTime.tryParse(ts)?.toUtc() ?? DateTime.now().toUtc(),
      mcqAccuracy: (m['mcq_accuracy'] as num?)?.toDouble(),
      avgEase: (m['avg_ease'] as num?)?.toDouble(),
      dueRatio: (m['due_ratio'] as num?)?.toDouble(),
      attempts: (m['attempts'] as num?)?.toInt() ?? 0,
      cardsReviewed: (m['cards_reviewed'] as num?)?.toInt() ?? 0,
    );
  }
}

class RemoteWeaknessStore {
  RemoteWeaknessStore(this._prefs);

  final SharedPreferences _prefs;

  Map<String, RemoteWeaknessEntry> readAll() {
    final raw = _prefs.getString(_kRemoteWeaknessKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final out = <String, RemoteWeaknessEntry>{};
      decoded.forEach((topicCode, value) {
        if (value is Map) {
          final entry = RemoteWeaknessEntry.fromJson(
              topicCode, value.cast<String, dynamic>());
          if (entry != null) out[topicCode] = entry;
        }
      });
      return out;
    } catch (_) {
      return {};
    }
  }

  Future<void> writeAll(Map<String, RemoteWeaknessEntry> entries) async {
    final m = <String, dynamic>{};
    entries.forEach((k, v) => m[k] = v.toJson());
    await _prefs.setString(_kRemoteWeaknessKey, jsonEncode(m));
  }

  /// Merges [incoming] into the persisted map using last-write-wins on
  /// `updated_at`. Returns the count of entries that were applied (newer
  /// than what was previously stored, or net-new).
  Future<int> mergeFromRemote(List<RemoteWeaknessEntry> incoming) async {
    final current = readAll();
    var applied = 0;
    for (final e in incoming) {
      final prev = current[e.topicCode];
      if (prev == null || e.updatedAt.isAfter(prev.updatedAt)) {
        current[e.topicCode] = e;
        applied++;
      }
    }
    if (applied > 0) await writeAll(current);
    return applied;
  }
}

final remoteWeaknessStoreProvider = Provider<RemoteWeaknessStore>(
  (ref) => RemoteWeaknessStore(ref.watch(sharedPreferencesProvider)),
);
