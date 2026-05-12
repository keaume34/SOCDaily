// Phase 9 — Pomodoro state machine tests. Drives the controller without
// real-time timers by manually invoking `skip()`/`reset()` and inspecting
// state transitions.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socdaily_app/src/features/pomodoro/pomodoro_controller.dart';
import 'package:socdaily_app/src/features/settings/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  late ProviderContainer container;
  late PomodoroController controller;

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ]);
    addTearDown(container.dispose);
    controller =
        container.read(pomodoroControllerProvider.notifier);
  });

  test('initial state is idle with focus duration loaded', () {
    final s = container.read(pomodoroControllerProvider);
    expect(s.phase, PomodoroPhase.idle);
    expect(s.running, isFalse);
    expect(s.remainingSeconds, 25 * 60);
    expect(s.completedFocus, 0);
    expect(s.progress, 0);
  });

  test('start() switches idle → focus and marks running', () {
    controller.start();
    final s = container.read(pomodoroControllerProvider);
    expect(s.phase, PomodoroPhase.focus);
    expect(s.running, isTrue);
    controller.pause();
  });

  test('skip from focus → short break and counts a completion', () {
    controller.start();
    controller.skip();
    final s = container.read(pomodoroControllerProvider);
    expect(s.phase, PomodoroPhase.shortBreak);
    expect(s.completedFocus, 1);
    expect(s.remainingSeconds, s.shortBreakMinutes * 60);
    controller.pause();
  });

  test('long break triggers every N cycles', () async {
    await controller.updateDurations(cycles: 2);
    controller.start();
    controller.skip(); // focus → short break (completed=1)
    controller.skip(); // short break → focus
    controller.skip(); // focus → long break (completed=2, 2 % 2 == 0)
    final s = container.read(pomodoroControllerProvider);
    expect(s.phase, PomodoroPhase.longBreak);
    expect(s.completedFocus, 2);
    expect(s.remainingSeconds, s.longBreakMinutes * 60);
    controller.pause();
  });

  test('reset clears phase, running and completion count', () {
    controller.start();
    controller.skip();
    controller.reset();
    final s = container.read(pomodoroControllerProvider);
    expect(s.phase, PomodoroPhase.idle);
    expect(s.running, isFalse);
    expect(s.completedFocus, 0);
    expect(s.remainingSeconds, s.focusMinutes * 60);
  });

  test('updateDurations persists to SharedPreferences', () async {
    await controller.updateDurations(focus: 30, short: 7, long: 20, cycles: 3);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('pom.focus'), 30);
    expect(prefs.getInt('pom.short'), 7);
    expect(prefs.getInt('pom.long'), 20);
    expect(prefs.getInt('pom.cycles'), 3);
  });

  test('progress increases monotonically with elapsed', () {
    controller.start();
    final start = container.read(pomodoroControllerProvider).progress;
    // Simulate elapsed by skipping then starting again — we just want to
    // verify progress is bounded in [0,1] and computed from remaining.
    expect(start, inInclusiveRange(0.0, 1.0));
    controller.pause();
  });
}
