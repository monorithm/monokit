import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Central haptic policy. Disabled by default and never fires when the host
/// application has not opted in.
@immutable
final class MonokitHaptics {
  const MonokitHaptics({this.enabled = false});

  final bool enabled;

  /// Discrete value changes: a segment, a tab, a stepper increment.
  Future<void> selection() async {
    if (enabled) await HapticFeedback.selectionClick();
  }

  /// A press landing.
  Future<void> impactLight() async {
    if (enabled) await HapticFeedback.lightImpact();
  }

  /// A rejected action or a failed validation.
  Future<void> error() async {
    if (enabled) await HapticFeedback.heavyImpact();
  }

  MonokitHaptics copyWith({bool? enabled}) =>
      MonokitHaptics(enabled: enabled ?? this.enabled);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitHaptics && enabled == other.enabled);

  @override
  int get hashCode => enabled.hashCode;
}
