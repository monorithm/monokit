import 'package:flutter/widgets.dart';

/// Rounded-corner tokens derived from Monokit's 10px base radius.
class MonokitRadii {
  const MonokitRadii({
    this.base = 10,
    this.sm = 5,
    this.md = 7.5,
    this.lg = 10,
    this.xl = 15,
    this.full = 999,
  });

  final double base;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;

  BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  BorderRadius get borderRadiusFull => BorderRadius.circular(full);

  MonokitRadii copyWith({
    double? base,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? full,
  }) {
    return MonokitRadii(
      base: base ?? this.base,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      full: full ?? this.full,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitRadii &&
      base == other.base &&
      sm == other.sm &&
      md == other.md &&
      lg == other.lg &&
      xl == other.xl &&
      full == other.full;

  @override
  int get hashCode => Object.hash(base, sm, md, lg, xl, full);
}
