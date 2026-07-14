import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

/// Drives a [MonoCommandPhase] through a realistic lifecycle on real timers,
/// with a configurable terminal outcome — so honest-state demos actually
/// transition instead of faking a frozen "pending".
class PhaseTicker extends ChangeNotifier {
  PhaseTicker({this.outcome = MonoCommandPhase.completed});

  /// completed | rejected | exhausted
  final MonoCommandPhase outcome;

  MonoCommandPhase phase = MonoCommandPhase.created;
  final List<Timer> _timers = <Timer>[];

  void start() {
    _reset(MonoCommandPhase.queued);
    _schedule(400, MonoCommandPhase.sent);
    _schedule(1100, MonoCommandPhase.accepted);
    _schedule(2000, outcome);
  }

  void retry() => start();

  void _schedule(int ms, MonoCommandPhase next) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        phase = next;
        notifyListeners();
      }),
    );
  }

  void _reset(MonoCommandPhase next) {
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
