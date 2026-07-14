import 'package:flutter/widgets.dart';

import '../primitives/mono_surfaces.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import 'badge.dart';
import 'button.dart';
import 'card.dart';
import '../state/mono_command.dart';
import 'progress.dart';

class MonoPriceTag extends StatelessWidget {
  const MonoPriceTag({
    super.key,
    required this.price,
    this.compareAt,
    this.currency,
    this.semanticLabel,
  });
  final String price;
  final String? compareAt, currency, semanticLabel;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Semantics(
      label: semanticLabel ?? [currency, price].whereType<String>().join(' '),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          if (currency != null)
            Text(
              currency!,
              style: t.typography.labelMedium.copyWith(
                color: t.colors.mutedForeground,
              ),
            ),
          Text(
            price,
            style: t.typography.titleLarge.copyWith(color: t.colors.foreground),
          ),
          if (compareAt != null) ...[
            SizedBox(width: t.spacing.sm),
            Text(
              compareAt!,
              style: t.typography.bodyMedium.copyWith(
                color: t.colors.mutedForeground,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MonoProductCard extends StatelessWidget {
  const MonoProductCard({
    super.key,
    required this.media,
    required this.title,
    required this.price,
    this.description,
    this.badge,
    this.action,
    this.onPressed,
    this.onMedia = false,
  });
  final Widget media, title, price;
  final Widget? description, badge, action;
  final VoidCallback? onPressed;
  final bool onMedia;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    final content = MonoCard(
      tier: onMedia ? MonoElevationTier.e2 : MonoElevationTier.e1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: <Widget>[
              media,
              if (badge != null)
                PositionedDirectional(
                  top: t.spacing.sm,
                  start: t.spacing.sm,
                  child: badge!,
                ),
            ],
          ),
          MonoCardHeader(
            title: title,
            description: description,
            action: action,
          ),
          MonoCardFooter(child: price),
        ],
      ),
    );
    return onPressed == null
        ? content
        : MonoButton(
            variant: MonoButtonVariant.ghost,
            onPressed: onPressed,
            child: content,
          );
  }
}

class MonoQuantityStepper extends StatelessWidget {
  const MonoQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minimum = 0,
    this.maximum = 99,
    this.semanticLabel = 'Quantity',
  });
  final int value, minimum, maximum;
  final ValueChanged<int> onChanged;
  final String semanticLabel;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Semantics(
      container: true,
      label: semanticLabel,
      value: '$value',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MonoButton(
            semanticLabel: 'Decrease quantity',
            variant: MonoButtonVariant.outline,
            size: MonoButtonSize.iconSm,
            onPressed: value > minimum ? () => onChanged(value - 1) : null,
            child: const Text('−'),
          ),
          SizedBox(width: t.spacing.md),
          Text('$value', style: t.typography.labelLarge),
          SizedBox(width: t.spacing.md),
          MonoButton(
            semanticLabel: 'Increase quantity',
            variant: MonoButtonVariant.outline,
            size: MonoButtonSize.iconSm,
            onPressed: value < maximum ? () => onChanged(value + 1) : null,
            child: const Text('+'),
          ),
        ],
      ),
    );
  }
}

class MonoCartBar extends StatelessWidget {
  const MonoCartBar({
    super.key,
    required this.summary,
    required this.action,
    this.leading,
  });
  final Widget summary, action;
  final Widget? leading;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return MonoSurface(
      tier: MonoElevationTier.e4,
      padding: EdgeInsets.all(t.spacing.md),
      child: Row(
        children: <Widget>[
          ?leading,
          if (leading != null) SizedBox(width: t.spacing.md),
          Expanded(child: summary),
          SizedBox(width: t.spacing.md),
          action,
        ],
      ),
    );
  }
}

class MonoOrderStatus extends StatelessWidget {
  const MonoOrderStatus({
    super.key,
    required this.phase,
    this.label,
    this.progress,
    this.onRetry,
  });
  final MonoCommandPhase phase;
  final Widget? label;
  final double? progress;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    final (text, variant) = switch (phase) {
      MonoCommandPhase.created => ('Created', MonoBadgeVariant.secondary),
      MonoCommandPhase.queued => ('Pending', MonoBadgeVariant.warning),
      MonoCommandPhase.sent => ('Sent', MonoBadgeVariant.info),
      MonoCommandPhase.accepted => ('Processing', MonoBadgeVariant.info),
      MonoCommandPhase.completed => ('Completed', MonoBadgeVariant.success),
      MonoCommandPhase.rejected => ('Rejected', MonoBadgeVariant.destructive),
      MonoCommandPhase.exhausted => (
        'Needs attention',
        MonoBadgeVariant.destructive,
      ),
    };
    final failed =
        phase == MonoCommandPhase.rejected ||
        phase == MonoCommandPhase.exhausted;
    return Semantics(
      container: true,
      liveRegion: true,
      label: text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              MonoBadge(variant: variant, child: Text(text)),
              if (label != null) ...[
                SizedBox(width: t.spacing.sm),
                Expanded(child: label!),
              ],
              if (failed && onRetry != null)
                MonoButton(
                  variant: MonoButtonVariant.ghost,
                  size: MonoButtonSize.sm,
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
            ],
          ),
          if (progress != null) ...[
            SizedBox(height: t.spacing.sm),
            MonoProgress(value: progress),
          ],
        ],
      ),
    );
  }
}
