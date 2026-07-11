import 'package:flutter/widgets.dart';

/// Shared motion tokens. Components should use these rather than ad-hoc timing.
class MonokitMotion {
  const MonokitMotion({
    this.duration = const Duration(milliseconds: 150),
    this.fast = const Duration(milliseconds: 100),
    this.slow = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
    this.emphasizedCurve = Curves.easeInOutCubic,
  });

  final Duration duration;
  final Duration fast;
  final Duration slow;
  final Curve curve;
  final Curve emphasizedCurve;

  MonokitMotion copyWith({
    Duration? duration,
    Duration? fast,
    Duration? slow,
    Curve? curve,
    Curve? emphasizedCurve,
  }) {
    return MonokitMotion(
      duration: duration ?? this.duration,
      fast: fast ?? this.fast,
      slow: slow ?? this.slow,
      curve: curve ?? this.curve,
      emphasizedCurve: emphasizedCurve ?? this.emphasizedCurve,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitMotion &&
      duration == other.duration &&
      fast == other.fast &&
      slow == other.slow &&
      curve == other.curve &&
      emphasizedCurve == other.emphasizedCurve;

  @override
  int get hashCode => Object.hash(duration, fast, slow, curve, emphasizedCurve);
}
