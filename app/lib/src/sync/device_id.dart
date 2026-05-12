// Phase 11 — Per-install device identity. The pairing protocol scopes
// payload rows by device id so two devices sharing a code can tell each
// other's rows apart. We generate a random v4 UUID on first launch and
// keep it in SharedPreferences.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../features/settings/settings_controller.dart';

const _kDeviceId = 'sync.device_id';

class DeviceIdService {
  DeviceIdService(this._prefs);
  final SharedPreferences _prefs;

  String get() {
    final existing = _prefs.getString(_kDeviceId);
    if (existing != null && existing.isNotEmpty) return existing;
    final fresh = const Uuid().v4();
    _prefs.setString(_kDeviceId, fresh);
    return fresh;
  }
}

final deviceIdServiceProvider = Provider<DeviceIdService>((ref) {
  return DeviceIdService(ref.read(sharedPreferencesProvider));
});

final deviceIdProvider = Provider<String>((ref) {
  return ref.read(deviceIdServiceProvider).get();
});
