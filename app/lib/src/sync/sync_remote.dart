// Phase 11 — Remote abstraction. Defined as an interface so unit tests
// can swap in a fake while production wires up Supabase.

import 'sync_types.dart';

abstract class SyncRemote {
  /// Creates a fresh pairing code. Device A calls this.
  Future<SyncPair> createPair({
    required String deviceId,
    Duration ttl = const Duration(minutes: 10),
    String Function()? codeGen,
  });

  /// Reads a pair by code. Returns null if not found.
  Future<SyncPair?> readPair(String code);

  /// Device B "redeems" the pair by setting its own device id. Returns
  /// the updated pair, or null if not found / expired.
  Future<SyncPair?> redeemPair({
    required String code,
    required String deviceId,
  });

  /// Pushes (upserts) a single payload row.
  Future<void> upsertPayload(SyncEnvelope env);

  /// Pushes a batch of payload rows.
  Future<void> upsertPayloadBatch(List<SyncEnvelope> envs);

  /// Reads remote payloads belonging to *the other* device under this
  /// pairing code. If [since] is provided, only rows with
  /// `updated_at > since` are returned.
  Future<List<SyncEnvelope>> readRemotePayloads({
    required String code,
    required String myDeviceId,
    DateTime? since,
  });
}

class SyncException implements Exception {
  SyncException(this.message);
  final String message;
  @override
  String toString() => 'SyncException: $message';
}
