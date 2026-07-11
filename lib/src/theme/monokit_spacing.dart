/// A compact four-point spacing scale.
class MonokitSpacing {
  const MonokitSpacing({
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.xxxl = 32,
    this.huge = 40,
    this.giant = 48,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double huge;
  final double giant;

  // Numeric aliases make spacing token intent clear in layout-heavy code.
  double get s4 => xs;
  double get s8 => sm;
  double get s12 => md;
  double get s16 => lg;
  double get s20 => xl;
  double get s24 => xxl;
  double get s32 => xxxl;
  double get s40 => huge;
  double get s48 => giant;

  MonokitSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
    double? huge,
    double? giant,
  }) {
    return MonokitSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
      huge: huge ?? this.huge,
      giant: giant ?? this.giant,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitSpacing &&
      xs == other.xs &&
      sm == other.sm &&
      md == other.md &&
      lg == other.lg &&
      xl == other.xl &&
      xxl == other.xxl &&
      xxxl == other.xxxl &&
      huge == other.huge &&
      giant == other.giant;

  @override
  int get hashCode => Object.hash(xs, sm, md, lg, xl, xxl, xxxl, huge, giant);
}
