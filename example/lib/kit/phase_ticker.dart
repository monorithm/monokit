import 'dart:async';

import 'package:flutter/widgets.dart';

/// A demo-only lifecycle phase for the gallery's async-action examples.
///
/// This used to reuse the library's `MonoCommandPhase`, but that command/honest
/// vocabulary was removed from Monokit. The example keeps its own tiny enum so
/// the sign-in and post demos still animate through a realistic lifecycle.
enum DemoPhase {
  created,
  queued,
  sent,
  accepted,
  completed,
  rejected,
  exhausted,
}

extension DemoPhaseX on DemoPhase {
  /// In-flight: work has started but no terminal outcome yet.
  bool get isPending =>
      this == DemoPhase.queued ||
      this == DemoPhase.sent ||
      this == DemoPhase.accepted;

  /// Reached a successful terminal state.
  bool get isTerminalSuccess => this == DemoPhase.completed;

  /// Reached a failed terminal state.
  bool get isTerminalFailure =>
      this == DemoPhase.rejected || this == DemoPhase.exhausted;
}

/// Drives a [DemoPhase] through a realistic lifecycle on real timers, with a
/// configurable terminal outcome — so the demos actually transition instead of
/// faking a frozen "pending".
class PhaseTicker extends ChangeNotifier {
  PhaseTicker({this.outcome = DemoPhase.completed});

  /// completed | rejected | exhausted
  final DemoPhase outcome;

  DemoPhase phase = DemoPhase.created;
  final List<Timer> _timers = <Timer>[];

  void start() {
    _reset(DemoPhase.queued);
    _schedule(400, DemoPhase.sent);
    _schedule(1100, DemoPhase.accepted);
    _schedule(2000, outcome);
  }

  void retry() => start();

  void _schedule(int ms, DemoPhase next) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        phase = next;
        notifyListeners();
      }),
    );
  }

  void _reset(DemoPhase next) {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    phase = next;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }
}
