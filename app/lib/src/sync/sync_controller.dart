// Phase 11 — Sync controller. Owns the active pairing code, the remote
// implementation, and the round-trip sync action. Persists the active
// pair to SharedPreferences so the same code is remembered between
// app launches.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/db/content_repository.dart';
import '../features/settings/settings_controller.dart';
import 'device_id.dart';
import 'sync_config.dart';
import 'sync_engine.dart';
import 'sync_remote.dart';
import 'sync_types.dart';
import 'supabase_sync_remote.dart';

const _kPairCode = 'sync.pair_code';
const _kLastSyncedAt = 'sync.last_synced_at';

enum SyncMode { unconfigured, idle, generating, redeeming, syncing, error }

@immutable
class SyncState {
  const SyncState({
    required this.mode,
    required this.pairCode,
    required this.lastSyncedAt,
    required this.lastUploaded,
    required this.lastDownloaded,
    required this.errorMessage,
  });

  factory SyncState.initial() => const SyncState(
        mode: SyncMode.idle,
        pairCode: null,
        lastSyncedAt: null,
        lastUploaded: 0,
        lastDownloaded: 0,
        errorMessage: null,
      );

  final SyncMode mode;
  final String? pairCode;
  final DateTime? lastSyncedAt;
  final int lastUploaded;
  final int lastDownloaded;
  final String? errorMessage;

  bool get isPaired => pairCode != null && pairCode!.isNotEmpty;

  SyncState copyWith({
    SyncMode? mode,
    String? pairCode,
    bool clearPair = false,
    DateTime? lastSyncedAt,
    int? lastUploaded,
    int? lastDownloaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SyncState(
      mode: mode ?? this.mode,
      pairCode: clearPair ? null : (pairCode ?? this.pairCode),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastUploaded: lastUploaded ?? this.lastUploaded,
      lastDownloaded: lastDownloaded ?? this.lastDownloaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SyncController extends Notifier<SyncState> {
  SyncRemote? _remote;
  String? _cachedDeviceId;

  @override
  SyncState build() {
    final config = ref.watch(syncConfigProvider);
    if (!config.isConfigured) {
      return SyncState.initial().copyWith(mode: SyncMode.unconfigured);
    }
    final prefs = ref.read(sharedPreferencesProvider);
    final code = prefs.getString(_kPairCode);
    final lastRaw = prefs.getString(_kLastSyncedAt);
    return SyncState.initial().copyWith(
      pairCode: code,
      lastSyncedAt: lastRaw == null ? null : DateTime.tryParse(lastRaw),
    );
  }

  String _deviceId() {
    final cached = _cachedDeviceId;
    if (cached != null) return cached;
    final fresh = ref.read(deviceIdProvider);
    _cachedDeviceId = fresh;
    return fresh;
  }

  SyncRemote _ensureRemote() {
    final existing = _remote;
    if (existing != null) return existing;
    final override = ref.read(syncRemoteOverrideProvider);
    if (override != null) {
      _remote = override;
      return override;
    }
    final config = ref.read(syncConfigProvider);
    if (!config.isConfigured) {
      throw SyncException('Cloud sync is not configured.');
    }
    final client = Supabase.instance.client;
    final remote = SupabaseSyncRemote(client);
    _remote = remote;
    return remote;
  }

  Future<void> _savePair(String? code) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (code == null || code.isEmpty) {
      await prefs.remove(_kPairCode);
    } else {
      await prefs.setString(_kPairCode, code);
    }
  }

  Future<void> _saveLastSync(DateTime ts) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kLastSyncedAt, ts.toUtc().toIso8601String());
  }

  /// Generates a fresh pairing code; the other device enters this to pair.
  Future<String?> generatePairCode() async {
    if (state.mode == SyncMode.unconfigured) return null;
    state = state.copyWith(mode: SyncMode.generating, clearError: true);
    try {
      final pair = await _ensureRemote().createPair(deviceId: _deviceId());
      await _savePair(pair.code);
      state = state.copyWith(mode: SyncMode.idle, pairCode: pair.code);
      return pair.code;
    } catch (e) {
      state = state.copyWith(mode: SyncMode.error, errorMessage: '$e');
      return null;
    }
  }

  /// Redeems a code generated on another device.
  Future<bool> redeemPairCode(String code) async {
    if (state.mode == SyncMode.unconfigured) return false;
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Pairing code is empty.');
      return false;
    }
    state = state.copyWith(mode: SyncMode.redeeming, clearError: true);
    try {
      final pair = await _ensureRemote()
          .redeemPair(code: trimmed, deviceId: _deviceId());
      if (pair == null) {
        state = state.copyWith(
          mode: SyncMode.error,
          errorMessage: 'Pairing code not found or expired.',
        );
        return false;
      }
      await _savePair(pair.code);
      state = state.copyWith(mode: SyncMode.idle, pairCode: pair.code);
      return true;
    } catch (e) {
      state = state.copyWith(mode: SyncMode.error, errorMessage: '$e');
      return false;
    }
  }

  /// Push local user state, then pull the partner device's deltas.
  Future<SyncRoundResult?> syncNow() async {
    if (state.mode == SyncMode.unconfigured) return null;
    final code = state.pairCode;
    if (code == null) {
      state = state.copyWith(
        mode: SyncMode.error,
        errorMessage: 'Not paired yet.',
      );
      return null;
    }
    state = state.copyWith(mode: SyncMode.syncing, clearError: true);
    try {
      final db = ref.read(appDatabaseProvider);
      final engine = SyncEngine(db, _ensureRemote());
      final result = await engine.sync(
        code: code,
        myDeviceId: _deviceId(),
        since: state.lastSyncedAt,
      );
      await _saveLastSync(result.lastSyncedAt);
      state = state.copyWith(
        mode: SyncMode.idle,
        lastSyncedAt: result.lastSyncedAt,
        lastUploaded: result.uploaded,
        lastDownloaded: result.applied,
      );
      return result;
    } catch (e) {
      state = state.copyWith(mode: SyncMode.error, errorMessage: '$e');
      return null;
    }
  }

  /// Forget the active pairing. Local data is untouched.
  Future<void> unpair() async {
    await _savePair(null);
    state = state.copyWith(mode: SyncMode.idle, clearPair: true);
  }

  /// Pushes a freshly-generated TopicSeed to the remote so the partner
  /// device receives it on its next [syncNow]. No-op when the user isn't
  /// paired or sync isn't configured — generation still works locally.
  Future<void> pushGeneratedSeed({
    required String topicCode,
    required Map<String, dynamic> seed,
  }) async {
    if (state.mode == SyncMode.unconfigured) return;
    final code = state.pairCode;
    if (code == null) return;
    try {
      await _ensureRemote().upsertPayload(
        SyncEnvelope(
          code: code,
          deviceId: _deviceId(),
          kind: SyncKinds.generatedSeed,
          itemKey: topicCode,
          payload: seed,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    } catch (_) {
      // Best-effort: a failed push doesn't surface as an error in the UI
      // because the seed already landed in the local DB. The next
      // [syncNow] will retry via the regular round-trip.
    }
  }
}

final syncConfigProvider = Provider<SyncConfig>((ref) {
  return SyncConfig.fromEnvironment();
});

/// Override this in tests to inject an in-memory remote.
final syncRemoteOverrideProvider = Provider<SyncRemote?>((ref) => null);

final syncControllerProvider =
    NotifierProvider<SyncController, SyncState>(SyncController.new);
