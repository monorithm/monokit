import 'package:flutter/widgets.dart';

/// Rounded-corner tokens derived from Monokit's 10px base radius.
///
/// The scale mirrors the shadcn web reference's radius multipliers off the same
/// 10px base: `sm` 0.6×, `md` 0.8×, `lg` 1×, `xl` 1.4×, `xxl` 1.8×, `xxxl` 2.2×,
/// `xxxxl` 2.6×.
class MonokitRadii {
  const MonokitRadii({
    this.base = 10,
    this.sm = 6,
    this.md = 8,
    this.lg = 10,
    this.xl = 14,
    this.xxl = 18,
    this.xxxl = 22,
    this.xxxxl = 26,
    this.full = 999,
  });

  final double base;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double xxxxl;
  final double full;

  BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
  BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  BorderRadius get borderRadiusXxl => BorderRadius.circular(xxl);
  BorderRadius get borderRadiusXxxl => BorderRadius.circular(xxxl);
  BorderRadius get borderRadiusXxxxl => BorderRadius.circular(xxxxl);
  BorderRadius get borderRadiusFull => BorderRadius.circular(full);

  MonokitRadii copyWith({
    double? base,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? xxxxl,
    double? full,
  }) {
    return MonokitRadii(
      base: base ?? this.base,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      xxxxl: xxxxl ?? this.xxxxl,
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
      xxl == other.xxl &&
      xxxl == other.xxxl &&
      xxxxl == other.xxxxl &&
      full == other.full;

  @override
  int get hashCode => Object.hash(base, sm, md, lg, xl, xxl, xxxl, xxxxl, full);
}
