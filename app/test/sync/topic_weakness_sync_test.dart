// Phase 14.C — RemoteWeaknessStore + topic_weakness sync round-trip tests.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/sync/in_memory_sync_remote.dart';
import 'package:socdaily_app/src/sync/remote_weakness_store.dart';
import 'package:socdaily_app/src/sync/sync_engine.dart';
import 'package:socdaily_app/src/sync/sync_types.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('mergeFromRemote applies new entries + skips older ones', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = RemoteWeaknessStore(prefs);

    final applied1 = await store.mergeFromRemote([
      RemoteWeaknessEntry(
        topicCode: 't',
        score: 0.7,
        updatedAt: DateTime.utc(2026, 5, 14),
      ),
    ]);
    expect(applied1, 1);
    expect(store.readAll()['t']!.score, 0.7);

    // Older timestamp: skipped.
    final applied2 = await store.mergeFromRemote([
      RemoteWeaknessEntry(
        topicCode: 't',
        score: 0.1,
        updatedAt: DateTime.utc(2026, 5, 13),
      ),
    ]);
    expect(applied2, 0);
    expect(store.readAll()['t']!.score, 0.7);

    // Newer timestamp: replaces.
    final applied3 = await store.mergeFromRemote([
      RemoteWeaknessEntry(
        topicCode: 't',
        score: 0.4,
        updatedAt: DateTime.utc(2026, 5, 15),
      ),
    ]);
    expect(applied3, 1);
    expect(store.readAll()['t']!.score, 0.4);
  });

  test('topic_weakness envelope is applied via SyncEngine', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = RemoteWeaknessStore(prefs);
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    final remote = InMemorySyncRemote();
    final pair = await remote.createPair(deviceId: 'A');
    await remote.redeemPair(code: pair.code, deviceId: 'B');

    await remote.upsertPayload(SyncEnvelope(
      code: pair.code,
      deviceId: 'A',
      kind: SyncKinds.topicWeakness,
      itemKey: 'siem-core',
      payload: {
        'score': 0.8,
        'mcq_accuracy': 0.2,
        'avg_ease': 1.7,
        'due_ratio': 0.5,
        'attempts': 5,
        'cards_reviewed': 4,
      },
      updatedAt: DateTime.utc(2026, 5, 15, 10),
    ));

    final engine = SyncEngine(db, remote, remoteWeaknessStore: store);
    final result = await engine.sync(code: pair.code, myDeviceId: 'B');
    expect(result.applied, greaterThanOrEqualTo(1));

    final saved = store.readAll()['siem-core']!;
    expect(saved.score, 0.8);
    expect(saved.mcqAccuracy, 0.2);
    expect(saved.attempts, 5);
    await db.close();
  });

  test('topic_weakness envelope without store attached is a no-op', () async {
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    final remote = InMemorySyncRemote();
    final pair = await remote.createPair(deviceId: 'A');
    await remote.redeemPair(code: pair.code, deviceId: 'B');
    await remote.upsertPayload(SyncEnvelope(
      code: pair.code,
      deviceId: 'A',
      kind: SyncKinds.topicWeakness,
      itemKey: 'x',
      payload: {'score': 0.5},
      updatedAt: DateTime.utc(2026, 5, 15),
    ));
    // No store passed; engine should accept the row but not crash.
    final engine = SyncEngine(db, remote);
    final result = await engine.sync(code: pair.code, myDeviceId: 'B');
    expect(result.downloaded, 1);
    expect(result.applied, 0);
    await db.close();
  });
}
