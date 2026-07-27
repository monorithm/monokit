import 'package:flutter/widgets.dart';

import '../primitives/mono_text_scale.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Semantic treatments for a compact [MonoBadge].
///
/// A badge reports *state*, so the ladder is the state vocabulary and nothing
/// else. 2.0 still carried `primary`, `secondary` and `outline` from the
/// shadcn era: three ways to say "no particular status", one of which drew a
/// hairline border that the grouped surface model had already abolished. They
/// collapse into [neutral].
enum MonoBadgeVariant { neutral, success, warning, danger, info, live }

/// Density options for a [MonoBadge].
enum MonoBadgeSize { sm, md, lg }

/// The immutable result of resolving a badge's semantic token treatment.
@immutable
class MonoResolvedBadgeStyle {
  const MonoResolvedBadgeStyle({
    required this.background,
    required this.foreground,
    required this.padding,
    required this.minimumHeight,
    required this.textStyle,
  });

  final Color background;
  final Color foreground;
  final EdgeInsets padding;
  final double minimumHeight;
  final TextStyle textStyle;
}

/// Resolves [MonoBadge] variants without tying the badge to Material styles.
class MonoBadgeStyleResolver {
  const MonoBadgeStyleResolver();

  MonoResolvedBadgeStyle resolve({
    required MonokitThemeData theme,
    required MonoBadgeVariant variant,
    required MonoBadgeSize size,
  }) {
    final colors = theme.colors;
    final spacing = theme.spacing;
    final (
      EdgeInsets padding,
      double minimumHeight,
      TextStyle textStyle,
    ) = switch (size) {
      MonoBadgeSize.sm => (
        EdgeInsets.symmetric(horizontal: spacing.sm),
        spacing.xxl,
        theme.typography.labelMedium,
      ),
      MonoBadgeSize.md => (
        EdgeInsets.symmetric(horizontal: spacing.md),
        spacing.xxxl,
        theme.typography.labelMedium,
      ),
      MonoBadgeSize.lg => (
        EdgeInsets.symmetric(horizontal: spacing.lg),
        spacing.lg + spacing.xl,
        theme.typography.labelLarge,
      ),
    };

    // Every semantic status is a soft fill with its contrast-safe text, the
    // same pairing MonoAlert and the destructive button already use. Through
    // 2.1 this switch had `danger` soft while its three siblings were solid,
    // so a row of status badges was half saturated fills and half tinted
    // whispers, with the quiet one being the alarming one.
    //
    // `live` stays solid on purpose. It is not a status in the same sense; it
    // is an attention signal, and the loudness is the point. `neutral` was
    // already a soft fill.
    final (Color background, Color foreground) = switch (variant) {
      MonoBadgeVariant.neutral => (colors.fill, colors.foreground),
      MonoBadgeVariant.success => (colors.successSoft, colors.successText),
      MonoBadgeVariant.warning => (colors.warningSoft, colors.warningText),
      MonoBadgeVariant.danger => (colors.dangerSoft, colors.dangerText),
      MonoBadgeVariant.info => (colors.infoSoft, colors.infoText),
      MonoBadgeVariant.live => (colors.live, colors.onLive),
    };

    return MonoResolvedBadgeStyle(
      background: background,
      foreground: foreground,
      padding: padding,
      minimumHeight: minimumHeight,
      textStyle: textStyle.copyWith(color: foreground),
    );
  }
}

/// A small semantic label, optionally preceded by a status dot.
class MonoBadge extends StatelessWidget {
  const MonoBadge({
    super.key,
    required this.child,
    this.variant = MonoBadgeVariant.neutral,
    this.size = MonoBadgeSize.md,
    this.dot = false,
    this.dotColor,
    this.semanticLabel,
  });

  /// Creates a badge with a status dot. [child] may be omitted for a dot-only
  /// indicator, though a [semanticLabel] is recommended in that case.
  const MonoBadge.dot({
    super.key,
    this.child,
    this.variant = MonoBadgeVariant.neutral,
    this.size = MonoBadgeSize.md,
    this.dotColor,
    this.semanticLabel,
  }) : dot = true;

  final Widget? child;
  final MonoBadgeVariant variant;
  final MonoBadgeSize size;
  final bool dot;
  final Color? dotColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final style = const MonoBadgeStyleResolver().resolve(
      theme: theme,
      variant: variant,
      size: size,
    );
    final dotSize = theme.spacing.xs + theme.spacing.xs / 2;
    final children = <Widget>[
      if (dot) ...[
        SizedBox(
          width: dotSize,
          height: dotSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: dotColor ?? style.foreground,
              shape: BoxShape.circle,
            ),
          ),
        ),
        if (child != null) SizedBox(width: theme.spacing.xs),
      ],
      ?child,
    ];

    final badge = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: monoScaledExtent(context, style.minimumHeight),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(theme.radii.full),
        ),
        child: Padding(
          padding: style.padding,
          child: DefaultTextStyle.merge(
            style: style.textStyle,
            child: Row(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );

    return Semantics(container: true, label: semanticLabel, child: badge);
  }
}
