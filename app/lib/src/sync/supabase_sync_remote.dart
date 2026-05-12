// Phase 11 — Supabase-backed implementation of [SyncRemote].
//
// All calls go through the supabase_flutter client. The client is
// initialised once in `main.dart` from [SyncConfig.fromEnvironment].

import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'sync_remote.dart';
import 'sync_types.dart';

class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this._client, {Random? rng}) : _rng = rng ?? Random();

  final SupabaseClient _client;
  final Random _rng;

  static const _pairs = 'device_sync_pair';
  static const _payloads = 'user_sync_payload';

  String _generateCode() {
    final n = _rng.nextInt(1000000);
    return n.toString().padLeft(6, '0');
  }

  @override
  Future<SyncPair> createPair({
    required String deviceId,
    Duration ttl = const Duration(minutes: 10),
    String Function()? codeGen,
  }) async {
    final now = DateTime.now().toUtc();
    final expires = now.add(ttl);
    // Try a few codes in case of collision.
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = (codeGen ?? _generateCode)();
      final row = {
        'code': code,
        'device_a_id': deviceId,
        'created_at': now.toIso8601String(),
        'expires_at': expires.toIso8601String(),
      };
      try {
        final inserted = await _client
            .from(_pairs)
            .insert(row)
            .select()
            .single();
        return SyncPair.fromMap(Map<String, dynamic>.from(inserted));
      } on PostgrestException catch (e) {
        // 23505 = unique violation. Retry with a fresh code.
        if (e.code == '23505') continue;
        rethrow;
      }
    }
    throw SyncException('Could not allocate a unique pairing code.');
  }

  @override
  Future<SyncPair?> readPair(String code) async {
    final rows = await _client
        .from(_pairs)
        .select()
        .eq('code', code)
        .limit(1);
    if (rows.isEmpty) return null;
    return SyncPair.fromMap(Map<String, dynamic>.from(rows.first));
  }

  @override
  Future<SyncPair?> redeemPair({
    required String code,
    required String deviceId,
  }) async {
    final existing = await readPair(code);
    if (existing == null) return null;
    if (existing.isExpired()) return null;
    if (existing.isRedeemed && existing.deviceBId != deviceId) {
      throw SyncException('Pair already redeemed by another device.');
    }
    final updated = await _client
        .from(_pairs)
        .update({
          'device_b_id': deviceId,
          'redeemed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('code', code)
        .select()
        .single();
    return SyncPair.fromMap(Map<String, dynamic>.from(updated));
  }

  @override
  Future<void> upsertPayload(SyncEnvelope env) async {
    await _client
        .from(_payloads)
        .upsert(env.toMap(), onConflict: 'code,device_id,kind,item_key');
  }

  @override
  Future<void> upsertPayloadBatch(List<SyncEnvelope> envs) async {
    if (envs.isEmpty) return;
    await _client
        .from(_payloads)
        .upsert(
          envs.map((e) => e.toMap()).toList(),
          onConflict: 'code,device_id,kind,item_key',
        );
  }

  @override
  Future<List<SyncEnvelope>> readRemotePayloads({
    required String code,
    required String myDeviceId,
    DateTime? since,
  }) async {
    var q = _client
        .from(_payloads)
        .select()
        .eq('code', code)
        .neq('device_id', myDeviceId);
    if (since != null) {
      q = q.gt('updated_at', since.toUtc().toIso8601String());
    }
    final rows = await q.order('updated_at', ascending: true);
    return rows
        .map((r) => SyncEnvelope.fromMap(Map<String, dynamic>.from(r)))
        .toList();
  }
}
