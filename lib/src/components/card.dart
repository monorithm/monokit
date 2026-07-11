import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Spacing densities shared by [MonoCard] and its slot widgets.
enum MonoCardSize { sm, md, lg }

/// A bordered surface intended to be composed with the card slot widgets.
///
/// The root does not impose padding: [MonoCardHeader], [MonoCardContent], and
/// [MonoCardFooter] own their respective spacing just as their web counterparts
/// do. This also makes a card useful for custom edge-to-edge content.
class MonoCard extends StatelessWidget {
  const MonoCard({
    super.key,
    required this.child,
    this.size = MonoCardSize.md,
    this.background,
    this.borderColor,
    this.showBorder = true,
    this.elevation,
    this.semanticLabel,
  });

  final Widget child;
  final MonoCardSize size;
  final Color? background;
  final Color? borderColor;
  final bool showBorder;

  /// A multiplier applied to the token-derived subtle shadow. Set to zero to
  /// render a flat card.
  final double? elevation;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedElevation = elevation ?? theme.components.card.elevation;
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: background ?? theme.colors.card,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        border: showBorder
            ? Border.all(
                color: borderColor ?? theme.colors.border,
                width: theme.components.card.borderWidth,
              )
            : null,
        boxShadow: resolvedElevation > 0
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.colors.foreground.withValues(
                    alpha: (0.06 * resolvedElevation.clamp(0, 1)).toDouble(),
                  ),
                  blurRadius: theme.spacing.sm * resolvedElevation,
                  offset: Offset(0, theme.spacing.xs / 2 * resolvedElevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: DefaultTextStyle.merge(
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.cardForeground,
          ),
          child: _MonoCardScope(size: size, child: child),
        ),
      ),
    );

    return Semantics(container: true, label: semanticLabel, child: card);
  }
}

/// A padded top slot for card headings and actions.
class MonoCardHeader extends StatelessWidget {
  const MonoCardHeader({
    super.key,
    this.child,
    this.title,
    this.description,
    this.action,
    this.size,
    this.padding,
  }) : assert(
         child != null ||
             title != null ||
             description != null ||
             action != null,
         'Provide child, title, description, or action.',
       );

  /// Custom header content. It takes precedence over the convenience slots.
  final Widget? child;
  final Widget? title;
  final Widget? description;
  final Widget? action;
  final MonoCardSize? size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedSize = _resolveCardSize(context, size);
    final metrics = _MonoCardSlotMetrics.fromTheme(theme, resolvedSize);
    final contents = child ?? _buildConvenienceContents(context);

    return Padding(padding: padding ?? metrics.headerPadding, child: contents);
  }

  Widget _buildConvenienceContents(BuildContext context) {
    final headingChildren = <Widget>[
      if (title != null) MonoCardTitle(child: title!),
      if (description != null) ...[
        SizedBox(height: MonokitTheme.of(context).spacing.sm),
        MonoCardDescription(child: description!),
      ],
    ];
    final heading = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: headingChildren,
    );
    if (action == null) {
      return heading;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: heading),
        SizedBox(width: MonokitTheme.of(context).spacing.md),
        MonoCardAction(child: action!),
      ],
    );
  }
}

/// A semantic title style for a [MonoCardHeader].
class MonoCardTitle extends StatelessWidget {
  const MonoCardTitle({
    super.key,
    required this.child,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final Widget child;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.titleLarge.copyWith(
        color: theme.colors.cardForeground,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      child: child,
    );
  }
}

/// A muted supporting text style for a [MonoCardHeader].
class MonoCardDescription extends StatelessWidget {
  const MonoCardDescription({
    super.key,
    required this.child,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final Widget child;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.bodyMedium.copyWith(
        color: theme.colors.mutedForeground,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      child: child,
    );
  }
}

/// An alignment slot for controls placed in a card header.
class MonoCardAction extends StatelessWidget {
  const MonoCardAction({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.topEnd,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(alignment: alignment, child: child);
  }
}

/// A padded main-content slot for a [MonoCard].
class MonoCardContent extends StatelessWidget {
  const MonoCardContent({
    super.key,
    required this.child,
    this.size,
    this.padding,
  });

  final Widget child;
  final MonoCardSize? size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final metrics = _MonoCardSlotMetrics.fromTheme(
      theme,
      _resolveCardSize(context, size),
    );
    return Padding(padding: padding ?? metrics.contentPadding, child: child);
  }
}

/// A padded bottom slot for actions or supporting card content.
class MonoCardFooter extends StatelessWidget {
  const MonoCardFooter({
    super.key,
    required this.child,
    this.size,
    this.padding,
  });

  final Widget child;
  final MonoCardSize? size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final metrics = _MonoCardSlotMetrics.fromTheme(
      theme,
      _resolveCardSize(context, size),
    );
    return Padding(padding: padding ?? metrics.footerPadding, child: child);
  }
}

class _MonoCardScope extends InheritedWidget {
  const _MonoCardScope({required this.size, required super.child});

  final MonoCardSize size;

  static MonoCardSize? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MonoCardScope>()?.size;
  }

  @override
  bool updateShouldNotify(covariant _MonoCardScope oldWidget) {
    return size != oldWidget.size;
  }
}

MonoCardSize _resolveCardSize(BuildContext context, MonoCardSize? override) {
  return override ?? _MonoCardScope.maybeOf(context) ?? MonoCardSize.md;
}

class _MonoCardSlotMetrics {
  const _MonoCardSlotMetrics({
    required this.headerPadding,
    required this.contentPadding,
    required this.footerPadding,
  });

  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;
  final EdgeInsets footerPadding;

  factory _MonoCardSlotMetrics.fromTheme(
    MonokitThemeData theme,
    MonoCardSize size,
  ) {
    final spacing = theme.spacing;
    switch (size) {
      case MonoCardSize.sm:
        return _MonoCardSlotMetrics(
          headerPadding: EdgeInsets.fromLTRB(
            spacing.md,
            spacing.md,
            spacing.md,
            spacing.sm,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          footerPadding: EdgeInsets.fromLTRB(
            spacing.md,
            spacing.sm,
            spacing.md,
            spacing.md,
          ),
        );
      case MonoCardSize.md:
        return _MonoCardSlotMetrics(
          headerPadding: EdgeInsets.fromLTRB(
            spacing.xxl,
            spacing.xxl,
            spacing.xxl,
            spacing.md,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.xxl,
            vertical: spacing.md,
          ),
          footerPadding: EdgeInsets.fromLTRB(
            spacing.xxl,
            spacing.md,
            spacing.xxl,
            spacing.xxl,
          ),
        );
      case MonoCardSize.lg:
        return _MonoCardSlotMetrics(
          headerPadding: EdgeInsets.fromLTRB(
            spacing.xxxl,
            spacing.xxxl,
            spacing.xxxl,
            spacing.lg,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spacing.xxxl,
            vertical: spacing.lg,
          ),
          footerPadding: EdgeInsets.fromLTRB(
            spacing.xxxl,
            spacing.lg,
            spacing.xxxl,
            spacing.xxxl,
          ),
        );
    }
  }
}
