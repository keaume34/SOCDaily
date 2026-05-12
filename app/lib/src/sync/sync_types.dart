// Phase 11 — Sync data model. The same envelope is used for every kind
// of per-user record we want to mirror across devices (card state,
// question state, bookmarks, notes, streaks, …). Each kind picks its
// own `itemKey` convention and serializes its own `payload` map.

import 'package:flutter/foundation.dart';

@immutable
class SyncPair {
  const SyncPair({
    required this.code,
    required this.deviceAId,
    required this.deviceBId,
    required this.createdAt,
    required this.redeemedAt,
    required this.expiresAt,
  });

  factory SyncPair.fromMap(Map<String, dynamic> m) {
    return SyncPair(
      code: m['code'] as String,
      deviceAId: m['device_a_id'] as String,
      deviceBId: m['device_b_id'] as String?,
      createdAt: DateTime.parse(m['created_at'] as String).toUtc(),
      redeemedAt: m['redeemed_at'] == null
          ? null
          : DateTime.parse(m['redeemed_at'] as String).toUtc(),
      expiresAt: DateTime.parse(m['expires_at'] as String).toUtc(),
    );
  }

  final String code;
  final String deviceAId;
  final String? deviceBId;
  final DateTime createdAt;
  final DateTime? redeemedAt;
  final DateTime expiresAt;

  bool get isRedeemed => deviceBId != null && deviceBId!.isNotEmpty;
  bool isExpired({DateTime? now}) =>
      (now ?? DateTime.now().toUtc()).isAfter(expiresAt);
}

@immutable
class SyncEnvelope {
  const SyncEnvelope({
    required this.code,
    required this.deviceId,
    required this.kind,
    required this.itemKey,
    required this.payload,
    required this.updatedAt,
  });

  factory SyncEnvelope.fromMap(Map<String, dynamic> m) {
    return SyncEnvelope(
      code: m['code'] as String,
      deviceId: m['device_id'] as String,
      kind: m['kind'] as String,
      itemKey: m['item_key'] as String,
      payload: Map<String, dynamic>.from(m['payload'] as Map),
      updatedAt: DateTime.parse(m['updated_at'] as String).toUtc(),
    );
  }

  final String code;
  final String deviceId;
  final String kind;
  final String itemKey;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'code': code,
        'device_id': deviceId,
        'kind': kind,
        'item_key': itemKey,
        'payload': payload,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };
}

/// Recognised payload kinds. Kept stable so different app versions can
/// safely talk to the same Supabase project.
class SyncKinds {
  static const cardState = 'card_state';
  static const questionState = 'question_state';
  static const bookmark = 'bookmark';
  static const note = 'note';
  static const streak = 'streak';
}
