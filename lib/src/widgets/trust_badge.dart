import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// A tiered credential: an ordered run of dots plus the tier's name.
///
/// From the proposal register (TrustBadge): the tier must be distinguishable
/// by a non-colour signal — the filled-dot count — and the tier's name is
/// always present as text; dots-only is not permitted. On app surfaces the
/// ink is the brand-as-ink [MonokitColors.tint] on the soft brand fill; over
/// media it composes as translucent chrome using the mode-invariant on-media
/// inks. The lowest tier renders with the same neutral treatment as every
/// other tier — a low tier is a starting point, never a warning — and a
/// lapsed credential greys down in place without changing geometry.
class MonoTrustBadge extends StatelessWidget {
  const MonoTrustBadge({
    super.key,
    required this.tier,
    required this.tierCount,
    required this.label,
    this.lapsed = false,
    this.onMedia = false,
    this.semanticLabel,
  }) : assert(tier >= 1, 'tier is 1-based.'),
       assert(tierCount >= tier, 'tier cannot exceed tierCount.');

  /// The attained tier, 1-based; renders as this many filled dots.
  final int tier;

  /// Total tiers in the ladder; renders as the total dot count.
  final int tierCount;

  /// The tier's name in the user's language (e.g. "City ring"). Required —
  /// the badge never renders dots alone.
  final String label;

  /// Mutes the badge in place. Geometry is unchanged so the state change is
  /// legible where the badge already is; treatment stays neutral, never
  /// destructive.
  final bool lapsed;

  /// Whether the badge sits over media. Over media it uses the translucent
  /// mist chrome and the mode-invariant on-media inks.
  final bool onMedia;

  final String? semanticLabel;

  static const double _dotSize = 5;
  static const double _dotGap = 3;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final colors = theme.colors;

    final (Color background, Color? border, Color ink) = onMedia
        ? (
            colors.mistFill,
            colors.mistLine,
            lapsed ? colors.onMediaMuted : colors.onMedia,
          )
        : lapsed
        ? (colors.fill, null, colors.foregroundMuted)
        : (colors.primarySoft, null, colors.tint);

    return Semantics(
      label:
          semanticLabel ??
          '$label, tier $tier of $tierCount${lapsed ? ', lapsed' : ''}',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          border: border == null ? null : Border.all(color: border),
          borderRadius: BorderRadius.circular(theme.radii.full),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.xs / 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var i = 0; i < tierCount; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: _dotGap),
              _Dot(color: ink, filled: i < tier),
            ],
            SizedBox(width: theme.spacing.xs + 1),
            Text(
              label,
              style: theme.typography.labelMedium.copyWith(
                color: ink,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MonoTrustBadge._dotSize,
      height: MonoTrustBadge._dotSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Unfilled dots stay in the same ink at reduced opacity, so the count
        // reads at a glance without introducing a second colour.
        color: filled ? color : color.withValues(alpha: 0.3),
      ),
    );
  }
}
