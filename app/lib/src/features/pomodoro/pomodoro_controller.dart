// Phase 9 — Pomodoro/study timer state. Lives at app scope so the timer
// keeps running while the user navigates between tabs.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/settings_controller.dart';

enum PomodoroPhase { focus, shortBreak, longBreak, idle }

@immutable
class PomodoroState {
  const PomodoroState({
    required this.phase,
    required this.remainingSeconds,
    required this.running,
    required this.completedFocus,
    required this.focusMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.cyclesUntilLongBreak,
  });

  factory PomodoroState.initial({
    int focus = 25,
    int short = 5,
    int long = 15,
    int cycles = 4,
  }) {
    return PomodoroState(
      phase: PomodoroPhase.idle,
      remainingSeconds: focus * 60,
      running: false,
      completedFocus: 0,
      focusMinutes: focus,
      shortBreakMinutes: short,
      longBreakMinutes: long,
      cyclesUntilLongBreak: cycles,
    );
  }

  final PomodoroPhase phase;
  final int remainingSeconds;
  final bool running;

  /// Number of focus phases finished in the current session.
  final int completedFocus;

  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int cyclesUntilLongBreak;

  int get totalSeconds {
    switch (phase) {
      case PomodoroPhase.shortBreak:
        return shortBreakMinutes * 60;
      case PomodoroPhase.longBreak:
        return longBreakMinutes * 60;
      case PomodoroPhase.focus:
      case PomodoroPhase.idle:
        return focusMinutes * 60;
    }
  }

  double get progress {
    final t = totalSeconds;
    if (t == 0) return 0;
    return (1 - (remainingSeconds / t)).clamp(0.0, 1.0);
  }

  PomodoroState copyWith({
    PomodoroPhase? phase,
    int? remainingSeconds,
    bool? running,
    int? completedFocus,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? cyclesUntilLongBreak,
  }) {
    return PomodoroState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      running: running ?? this.running,
      completedFocus: completedFocus ?? this.completedFocus,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      cyclesUntilLongBreak: cyclesUntilLongBreak ?? this.cyclesUntilLongBreak,
    );
  }
}

const _kPomFocus = 'pom.focus';
const _kPomShort = 'pom.short';
const _kPomLong = 'pom.long';
const _kPomCycles = 'pom.cycles';

class PomodoroController extends Notifier<PomodoroState> {
  Timer? _ticker;
  late SharedPreferences _prefs;

  @override
  PomodoroState build() {
    _prefs = ref.read(sharedPreferencesProvider);
    ref.onDispose(() => _ticker?.cancel());
    return PomodoroState.initial(
      focus: _prefs.getInt(_kPomFocus) ?? 25,
      short: _prefs.getInt(_kPomShort) ?? 5,
      long: _prefs.getInt(_kPomLong) ?? 15,
      cycles: _prefs.getInt(_kPomCycles) ?? 4,
    );
  }

  void start() {
    if (state.running) return;
    final next = state.phase == PomodoroPhase.idle
        ? state.copyWith(
            phase: PomodoroPhase.focus,
            remainingSeconds: state.focusMinutes * 60,
          )
        : state;
    state = next.copyWith(running: true);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(running: false);
  }

  void reset() {
    _ticker?.cancel();
    state = PomodoroState.initial(
      focus: state.focusMinutes,
      short: state.shortBreakMinutes,
      long: state.longBreakMinutes,
      cycles: state.cyclesUntilLongBreak,
    );
  }

  void skip() {
    _ticker?.cancel();
    _advancePhase();
  }

  Future<void> updateDurations({
    int? focus,
    int? short,
    int? long,
    int? cycles,
  }) async {
    state = state.copyWith(
      focusMinutes: focus ?? state.focusMinutes,
      shortBreakMinutes: short ?? state.shortBreakMinutes,
      longBreakMinutes: long ?? state.longBreakMinutes,
      cyclesUntilLongBreak: cycles ?? state.cyclesUntilLongBreak,
      remainingSeconds: state.phase == PomodoroPhase.idle && focus != null
          ? focus * 60
          : state.remainingSeconds,
    );
    if (focus != null) await _prefs.setInt(_kPomFocus, focus);
    if (short != null) await _prefs.setInt(_kPomShort, short);
    if (long != null) await _prefs.setInt(_kPomLong, long);
    if (cycles != null) await _prefs.setInt(_kPomCycles, cycles);
  }

  void _tick() {
    final r = state.remainingSeconds;
    if (r <= 1) {
      _advancePhase();
    } else {
      state = state.copyWith(remainingSeconds: r - 1);
    }
  }

  void _advancePhase() {
    _ticker?.cancel();
    PomodoroPhase next;
    int dur;
    var completed = state.completedFocus;
    switch (state.phase) {
      case PomodoroPhase.focus:
        completed = state.completedFocus + 1;
        if (completed % state.cyclesUntilLongBreak == 0) {
          next = PomodoroPhase.longBreak;
          dur = state.longBreakMinutes * 60;
        } else {
          next = PomodoroPhase.shortBreak;
          dur = state.shortBreakMinutes * 60;
        }
        break;
      case PomodoroPhase.shortBreak:
      case PomodoroPhase.longBreak:
      case PomodoroPhase.idle:
        next = PomodoroPhase.focus;
        dur = state.focusMinutes * 60;
        break;
    }
    state = state.copyWith(
      phase: next,
      remainingSeconds: dur,
      running: true,
      completedFocus: completed,
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }
}

final pomodoroControllerProvider =
    NotifierProvider<PomodoroController, PomodoroState>(
        PomodoroController.new);
