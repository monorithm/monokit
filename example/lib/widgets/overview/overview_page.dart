import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../../navigation/navigation.dart';
import '../shared/doc_widgets.dart';

/// Entry route for the self-documenting Monokit showcase.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Monokit for Flutter',
          description:
              'A live documentation app for the widgets-first design system. '
              'Choose any route in the sidebar; every component card is runnable.',
        ),
        DocSection(
          name: 'MonokitApp · MonokitTheme · MonokitThemeData',
          description:
              'MonokitApp wraps WidgetsApp, installs MonokitTheme, and applies the current light, dark, or system token bundle.',
          code: '''MonokitApp.router(
  theme: MonokitThemeData.light(),
  darkTheme: MonokitThemeData.dark(),
  routerConfig: router,
)''',
          child: MonoAlert(
            variant: MonoAlertVariant.info,
            title: const Text('Theme-aware route shell'),
            description: Text(
              'Current canvas: ${theme.colors.background.toARGB32().toRadixString(16).toUpperCase()} · '
              'motion: ${theme.motion.duration.inMilliseconds}ms',
            ),
          ),
        ),
        const DocGroupTitle('Semantic tokens'),
        DocSection(
          name: 'MonokitColors',
          description:
              'Use semantic colors rather than component-local hex values. The swatches below update with the theme toggle.',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: <Widget>[
              _ColorToken(
                'background',
                theme.colors.background,
                theme.colors.foreground,
              ),
              _ColorToken(
                'foreground',
                theme.colors.foreground,
                theme.colors.background,
              ),
              _ColorToken(
                'primary',
                theme.colors.primary,
                theme.colors.primaryForeground,
              ),
              _ColorToken(
                'secondary',
                theme.colors.secondary,
                theme.colors.secondaryForeground,
              ),
              _ColorToken(
                'muted',
                theme.colors.muted,
                theme.colors.mutedForeground,
              ),
              _ColorToken(
                'destructive',
                theme.colors.destructive,
                theme.colors.primaryForeground,
              ),
              _ColorToken(
                'border',
                theme.colors.border,
                theme.colors.foreground,
              ),
              _ColorToken('ring', theme.colors.ring, theme.colors.background),
            ],
          ),
        ),
        DocSection(
          name:
              'MonokitTypography · MonokitSpacing · MonokitRadii · MonokitMotion',
          description:
              'Typography, spacing, rounded geometry, and motion are token objects exposed by MonokitTheme.of(context).',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Display / headline / body / label',
                style: theme.typography.displayMedium,
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                'Body medium is the default reading style.',
                style: theme.typography.bodyMedium,
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                'Label medium documents compact metadata.',
                style: theme.typography.labelMedium,
              ),
              SizedBox(height: theme.spacing.lg),
              Wrap(
                spacing: theme.spacing.sm,
                runSpacing: theme.spacing.sm,
                children: <Widget>[
                  _RadiusToken('sm', theme.radii.sm),
                  _RadiusToken('md', theme.radii.md),
                  _RadiusToken('lg', theme.radii.lg),
                  _RadiusToken('xl', theme.radii.xl),
                ],
              ),
              SizedBox(height: theme.spacing.lg),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: theme.spacing.sm,
                children: <Widget>[
                  _SpacingToken('4', theme.spacing.s4),
                  _SpacingToken('8', theme.spacing.s8),
                  _SpacingToken('16', theme.spacing.s16),
                  _SpacingToken('32', theme.spacing.s32),
                  _SpacingToken('48', theme.spacing.s48),
                ],
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonokitComponentThemes',
          description:
              'Component geometry and interaction knobs remain grouped under theme.components, while all colors remain semantic.',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: <Widget>[
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text(
                  'Button ring ${theme.components.button.focusRingWidth}',
                ),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text(
                  'Card elevation ${theme.components.card.elevation}',
                ),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text(
                  'Sidebar ${theme.components.screen.sidebarWidth.round()}px',
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'Documentation map',
          description:
              'The remaining routes organize every interactive component, its slots, variants, and stateful behavior.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: navSections
                .skip(1) // the overview section itself
                .map(
                  (section) => Padding(
                    padding: EdgeInsets.only(bottom: theme.spacing.sm),
                    child: MonoBreadcrumbLink(
                      onPressed: () => context.navigate(section.route),
                      child: Text('${section.title} — ${section.description}'),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _ColorToken extends StatelessWidget {
  const _ColorToken(this.name, this.color, this.foreground);

  final String name;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(MonokitTheme.of(context).radii.md),
        border: Border.all(color: MonokitTheme.of(context).colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground, fontSize: 12),
          child: Text(name),
        ),
      ),
    );
  }
}

class _RadiusToken extends StatelessWidget {
  const _RadiusToken(this.name, this.radius);

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(
        width: 64,
        height: 48,
        child: Center(child: Text('$name\n${radius.toStringAsFixed(1)}')),
      ),
    );
  }
}

class _SpacingToken extends StatelessWidget {
  const _SpacingToken(this.name, this.size);

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(width: size, height: size, color: theme.colors.primary),
        SizedBox(height: theme.spacing.xs),
        Text(name, style: theme.typography.labelMedium),
      ],
    );
  }
}
