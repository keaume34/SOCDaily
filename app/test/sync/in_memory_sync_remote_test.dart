// Phase 11 — In-memory sync round-trip tests. These cover the
// pairing-code protocol and conflict resolution without touching
// Supabase, so they run in plain `flutter test`.

import 'package:flutter_test/flutter_test.dart';
import 'package:socdaily_app/src/sync/in_memory_sync_remote.dart';
import 'package:socdaily_app/src/sync/sync_remote.dart';
import 'package:socdaily_app/src/sync/sync_types.dart';

void main() {
  group('InMemorySyncRemote pairing', () {
    test('createPair returns a 6-digit code and stores the pair', () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'devA');
      expect(pair.code.length, 6);
      expect(int.tryParse(pair.code), isNotNull);
      expect(pair.deviceAId, 'devA');
      expect(pair.deviceBId, isNull);
      expect(pair.isRedeemed, isFalse);
      expect(await remote.readPair(pair.code), isNotNull);
    });

    test('redeemPair sets device B and marks redeemed', () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'devA');
      final redeemed =
          await remote.redeemPair(code: pair.code, deviceId: 'devB');
      expect(redeemed, isNotNull);
      expect(redeemed!.deviceBId, 'devB');
      expect(redeemed.isRedeemed, isTrue);
      expect(redeemed.redeemedAt, isNotNull);
    });

    test('redeemPair returns null for unknown code', () async {
      final remote = InMemorySyncRemote();
      final r = await remote.redeemPair(code: '999999', deviceId: 'x');
      expect(r, isNull);
    });

    test('redeemPair rejects a third device on an already-redeemed pair',
        () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'devA');
      await remote.redeemPair(code: pair.code, deviceId: 'devB');
      expect(
        () => remote.redeemPair(code: pair.code, deviceId: 'devC'),
        throwsA(isA<SyncException>()),
      );
    });

    test('redeemPair refuses an expired pair', () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(
        deviceId: 'devA',
        ttl: const Duration(milliseconds: -1),
      );
      final r = await remote.redeemPair(code: pair.code, deviceId: 'devB');
      expect(r, isNull);
    });
  });

  group('InMemorySyncRemote payloads', () {
    SyncEnvelope env({
      required String code,
      required String device,
      required String item,
      required int updatedSecAgo,
      Map<String, dynamic>? payload,
    }) =>
        SyncEnvelope(
          code: code,
          deviceId: device,
          kind: SyncKinds.cardState,
          itemKey: item,
          payload: payload ?? {'ease': 2.5},
          updatedAt: DateTime.now()
              .toUtc()
              .subtract(Duration(seconds: updatedSecAgo)),
        );

    test('upsertPayload + readRemotePayloads filters by other device',
        () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'A');
      await remote.upsertPayload(
        env(code: pair.code, device: 'A', item: '1', updatedSecAgo: 30),
      );
      await remote.upsertPayload(
        env(code: pair.code, device: 'B', item: '1', updatedSecAgo: 10),
      );
      final fromAForB = await remote.readRemotePayloads(
        code: pair.code,
        myDeviceId: 'B',
      );
      final fromBForA = await remote.readRemotePayloads(
        code: pair.code,
        myDeviceId: 'A',
      );
      expect(fromAForB, hasLength(1));
      expect(fromAForB.single.deviceId, 'A');
      expect(fromBForA, hasLength(1));
      expect(fromBForA.single.deviceId, 'B');
    });

    test('upsertPayload is last-write-wins on updated_at', () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'A');
      final older = env(
        code: pair.code,
        device: 'A',
        item: '1',
        updatedSecAgo: 60,
        payload: {'ease': 1.5},
      );
      final newer = env(
        code: pair.code,
        device: 'A',
        item: '1',
        updatedSecAgo: 10,
        payload: {'ease': 2.7},
      );
      // Push newer first, then older — older should be ignored.
      await remote.upsertPayload(newer);
      await remote.upsertPayload(older);
      final all = await remote.readRemotePayloads(
        code: pair.code,
        myDeviceId: 'B',
      );
      expect(all, hasLength(1));
      expect(all.single.payload['ease'], 2.7);
    });

    test('readRemotePayloads honors the since filter', () async {
      final remote = InMemorySyncRemote();
      final pair = await remote.createPair(deviceId: 'A');
      await remote.upsertPayload(
        env(code: pair.code, device: 'A', item: '1', updatedSecAgo: 120),
      );
      await remote.upsertPayload(
        env(code: pair.code, device: 'A', item: '2', updatedSecAgo: 10),
      );
      final since = DateTime.now().toUtc().subtract(const Duration(seconds: 60));
      final recent = await remote.readRemotePayloads(
        code: pair.code,
        myDeviceId: 'B',
        since: since,
      );
      expect(recent, hasLength(1));
      expect(recent.single.itemKey, '2');
    });
  });
}
