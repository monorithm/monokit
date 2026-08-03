import 'package:monokit_ui/monokit_ui.dart';

import 'responsive/responsive_stage.dart';

/// The designed header every component page opens with: an eyebrow (the family),
/// a display title, a one-line intent, and a featured live example — so a page
/// leads with composition, not a wall of matrix rows.
class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.tagline,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String tagline;

  /// A featured, composed example of the family.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow.toUpperCase(),
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.primary,
          ),
        ),
        SizedBox(height: theme.spacing.xs),
        Text(title, style: theme.typography.displayMedium),
        SizedBox(height: theme.spacing.sm),
        SizedBox(
          width: 640,
          child: Text(
            tagline,
            style: theme.typography.bodyLarge.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.xl),
        MonoSurface(padding: EdgeInsets.all(theme.spacing.xl), child: child),
      ],
    );
  }
}

/// A titled block that drops a component onto the interactive [ResponsiveStage]
/// — the per-page "watch it reflow" section.
class StageBlock extends StatelessWidget {
  const StageBlock({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.stageHeight = 420,
    this.initialWidth = 1024,
  });

  final String title;
  final String? description;
  final Widget child;
  final double stageHeight;
  final double initialWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(title, style: theme.typography.titleLarge)),
            const MonoBadge(
              variant: MonoBadgeVariant.neutral,
              child: Text('Responsive'),
            ),
          ],
        ),
        if (description != null) ...<Widget>[
          SizedBox(height: theme.spacing.xs),
          Text(
            description!,
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ],
        SizedBox(height: theme.spacing.md),
        ResponsiveStage(
          height: stageHeight,
          initialWidth: initialWidth,
          child: child,
        ),
      ],
    );
  }
}

/// A slim divider used between a page's hero and its reference matrix.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xxl),
      child: const MonoSeparator(),
    );
  }
}
