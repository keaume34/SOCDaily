// Phase 11 — In-memory fake remote, used by tests and (optionally) by a
// "demo mode" so the app is fully functional without a real Supabase.

import 'dart:math';

import 'sync_remote.dart';
import 'sync_types.dart';

class InMemorySyncRemote implements SyncRemote {
  InMemorySyncRemote({Random? rng}) : _rng = rng ?? Random();

  final Random _rng;
  final Map<String, SyncPair> _pairs = {};
  final Map<String, SyncEnvelope> _payloads = {}; // key = code|device|kind|item

  String _generateCode() {
    final n = _rng.nextInt(1000000);
    return n.toString().padLeft(6, '0');
  }

  String _key(SyncEnvelope e) =>
      '${e.code}|${e.deviceId}|${e.kind}|${e.itemKey}';

  @override
  Future<SyncPair> createPair({
    required String deviceId,
    Duration ttl = const Duration(minutes: 10),
    String Function()? codeGen,
  }) async {
    final now = DateTime.now().toUtc();
    var code = (codeGen ?? _generateCode)();
    while (_pairs.containsKey(code)) {
      code = _generateCode();
    }
    final p = SyncPair(
      code: code,
      deviceAId: deviceId,
      deviceBId: null,
      createdAt: now,
      redeemedAt: null,
      expiresAt: now.add(ttl),
    );
    _pairs[code] = p;
    return p;
  }

  @override
  Future<SyncPair?> readPair(String code) async => _pairs[code];

  @override
  Future<SyncPair?> redeemPair({
    required String code,
    required String deviceId,
  }) async {
    final p = _pairs[code];
    if (p == null) return null;
    if (p.isExpired()) return null;
    if (p.isRedeemed && p.deviceBId != deviceId) {
      throw SyncException('Pair already redeemed by another device.');
    }
    final updated = SyncPair(
      code: p.code,
      deviceAId: p.deviceAId,
      deviceBId: deviceId,
      createdAt: p.createdAt,
      redeemedAt: DateTime.now().toUtc(),
      expiresAt: p.expiresAt,
    );
    _pairs[code] = updated;
    return updated;
  }

  @override
  Future<void> upsertPayload(SyncEnvelope env) async {
    final existing = _payloads[_key(env)];
    if (existing != null && existing.updatedAt.isAfter(env.updatedAt)) {
      return; // last-write-wins
    }
    _payloads[_key(env)] = env;
  }

  @override
  Future<void> upsertPayloadBatch(List<SyncEnvelope> envs) async {
    for (final e in envs) {
      await upsertPayload(e);
    }
  }

  @override
  Future<List<SyncEnvelope>> readRemotePayloads({
    required String code,
    required String myDeviceId,
    DateTime? since,
  }) async {
    return _payloads.values.where((e) {
      if (e.code != code) return false;
      if (e.deviceId == myDeviceId) return false;
      if (since != null && !e.updatedAt.isAfter(since)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  }
}
