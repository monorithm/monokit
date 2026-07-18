import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Central haptic policy. It is disabled by default and never fires when the
/// host application has not opted in.
@immutable
class MonokitHaptics {
  const MonokitHaptics({this.enabled = false});

  final bool enabled;

  Future<void> selection() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  Future<void> impactLight() async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  Future<void> error() async {
    if (enabled) await HapticFeedback.heavyImpact();
  }
}
