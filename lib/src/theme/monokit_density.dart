import 'package:flutter/widgets.dart';

enum MonoDensity { touch, pointer }

@immutable
class MonokitDensityData {
  const MonokitDensityData({
    this.mode = MonoDensity.touch,
    this.touchTarget = 48,
    this.pointerTarget = 36,
  });

  final MonoDensity mode;
  final double touchTarget;
  final double pointerTarget;
  double get minimumTarget =>
      mode == MonoDensity.touch ? touchTarget : pointerTarget;
}

@immutable
class MonokitBreakpoints {
  // Canonical ladder shared with MonoScreenTheme (design 04-space-and-layout):
  // compact <600 · medium 600–960 · expanded 960–1280 · wide ≥1280.
  const MonokitBreakpoints({
    this.compact = 600,
    this.medium = 960,
    this.expanded = 1280,
  });

  final double compact;
  final double medium;
  final double expanded;
}
