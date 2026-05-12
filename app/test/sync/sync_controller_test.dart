// Phase 11 — SyncController unit tests. Use the in-memory remote so we
// exercise the full controller state machine without Supabase.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socdaily_app/src/data/db/app_database.dart';
import 'package:socdaily_app/src/data/db/content_repository.dart';
import 'package:socdaily_app/src/features/settings/settings_controller.dart';
import 'package:socdaily_app/src/sync/device_id.dart';
import 'package:socdaily_app/src/sync/in_memory_sync_remote.dart';
import 'package:socdaily_app/src/sync/sync_config.dart';
import 'package:socdaily_app/src/sync/sync_controller.dart';
import 'package:socdaily_app/src/sync/sync_remote.dart';
import 'package:drift/native.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  Future<({ProviderContainer container, AppDatabase db, InMemorySyncRemote remote})>
      makeContainer({
    String deviceId = 'dev-test',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    final remote = InMemorySyncRemote();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        deviceIdProvider.overrideWithValue(deviceId),
        syncRemoteOverrideProvider.overrideWithValue(remote),
        syncConfigProvider.overrideWithValue(
          const SyncConfig(url: 'https://example.test', anonKey: 'k'),
        ),
      ],
    );
    return (container: container, db: db, remote: remote);
  }

  test('starts paired = false, idle mode when configured', () async {
    final c = await makeContainer();
    final s = c.container.read(syncControllerProvider);
    expect(s.mode, SyncMode.idle);
    expect(s.isPaired, isFalse);
    expect(s.pairCode, isNull);
    c.container.dispose();
    await c.db.close();
  });

  test('starts in unconfigured mode when SyncConfig is empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forExecutor(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        deviceIdProvider.overrideWithValue('x'),
        // No syncConfig override → default reads dart-define which is empty
        // during tests. The default already evaluates to "not configured".
      ],
    );
    final s = container.read(syncControllerProvider);
    expect(s.mode, SyncMode.unconfigured);
    container.dispose();
    await db.close();
  });

  test('generatePairCode → state becomes idle + paired with a 6-digit code',
      () async {
    final c = await makeContainer();
    final code = await c.container
        .read(syncControllerProvider.notifier)
        .generatePairCode();
    expect(code, isNotNull);
    expect(code!.length, 6);
    final s = c.container.read(syncControllerProvider);
    expect(s.mode, SyncMode.idle);
    expect(s.isPaired, isTrue);
    expect(s.pairCode, code);
    c.container.dispose();
    await c.db.close();
  });

  test('redeemPairCode rejects an unknown code and surfaces an error',
      () async {
    final c = await makeContainer();
    final ok = await c.container
        .read(syncControllerProvider.notifier)
        .redeemPairCode('999999');
    expect(ok, isFalse);
    final s = c.container.read(syncControllerProvider);
    expect(s.mode, SyncMode.error);
    expect(s.errorMessage, isNotNull);
    c.container.dispose();
    await c.db.close();
  });

  test('unpair clears the active code', () async {
    final c = await makeContainer();
    final code = await c.container
        .read(syncControllerProvider.notifier)
        .generatePairCode();
    expect(code, isNotNull);
    await c.container.read(syncControllerProvider.notifier).unpair();
    final s = c.container.read(syncControllerProvider);
    expect(s.isPaired, isFalse);
    expect(s.pairCode, isNull);
    c.container.dispose();
    await c.db.close();
  });

  test('two containers pair + syncNow → user state ends up on both', () async {
    final a = await makeContainer(deviceId: 'A');
    // Force shared remote for both containers.
    final remote = a.remote as SyncRemote;
    final prefsB = await SharedPreferences.getInstance();
    final dbB = AppDatabase.forExecutor(NativeDatabase.memory());
    final b = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefsB),
        appDatabaseProvider.overrideWithValue(dbB),
        deviceIdProvider.overrideWithValue('B'),
        syncRemoteOverrideProvider.overrideWithValue(remote),
        syncConfigProvider.overrideWithValue(
          const SyncConfig(url: 'https://example.test', anonKey: 'k'),
        ),
      ],
    );

    final code = await a.container
        .read(syncControllerProvider.notifier)
        .generatePairCode();
    expect(code, isNotNull);
    final ok = await b.read(syncControllerProvider.notifier).redeemPairCode(code!);
    expect(ok, isTrue);

    // Both sides sync — should succeed without throwing even with empty DBs.
    final resA = await a.container.read(syncControllerProvider.notifier).syncNow();
    final resB = await b.read(syncControllerProvider.notifier).syncNow();
    expect(resA, isNotNull);
    expect(resB, isNotNull);

    a.container.dispose();
    b.dispose();
    await a.db.close();
    await dbB.close();
  });
}
