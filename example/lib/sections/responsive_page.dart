import 'package:monokit/monokit.dart';

import '../kit/responsive/responsive_stage.dart';
import '../kit/responsive/viewport_row.dart';

/// Teaches the breakpoint system and proves the three demonstration mechanisms:
/// a live [ResponsiveStage] you can drag, a glanceable [ViewportRow], and a note
/// pointing at the global device switcher in the header.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        Text('Responsive by design', style: theme.typography.displayMedium),
        SizedBox(height: theme.spacing.sm),
        SizedBox(
          width: 640,
          child: Text(
            'Monokit widgets read the viewport, not the platform. Every '
            'breakpoint below drives real reflow — drag the stage, scan the '
            'panes, or pin the whole app with the device switcher up top.',
            style: theme.typography.bodyLarge.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.xxl),
        const _BreakpointLadder(),
        SizedBox(height: theme.spacing.xxl),
        _SectionTitle(
          title: 'Drag the stage',
          subtitle:
              'Snap to a preset or drag the handle — the framed subtree gets an '
              'overridden MediaQuery, so it reflows exactly as it would on device.',
        ),
        SizedBox(height: theme.spacing.md),
        const ResponsiveStage(child: ResponsiveShowpiece()),
        SizedBox(height: theme.spacing.xxl),
        _SectionTitle(
          title: 'Compare viewports side by side',
          subtitle:
              'The same component at three breakpoints at once — reflow '
              'differences without touching anything.',
        ),
        SizedBox(height: theme.spacing.md),
        ViewportRow(builder: (_) => const ResponsiveShowpiece()),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: theme.typography.titleLarge),
        SizedBox(height: theme.spacing.xs),
        SizedBox(
          width: 620,
          child: Text(
            subtitle,
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// A visual of the four-tier ladder, with the pane's *current* real breakpoint
/// highlighted live via [LayoutBuilder].
class _BreakpointLadder extends StatelessWidget {
  const _BreakpointLadder();

  static const List<(String, String)> _tiers = <(String, String)>[
    ('compact', '< 600'),
    ('medium', '600 – 960'),
    ('expanded', '960 – 1280'),
    ('wide', '≥ 1280'),
  ];

  int _activeIndex(MonokitBreakpoints bp, double w) {
    if (w < bp.compact) return 0;
    if (w < bp.medium) return 1;
    if (w < bp.expanded) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final active = _activeIndex(theme.breakpoints, constraints.maxWidth);
        return Wrap(
          spacing: theme.spacing.md,
          runSpacing: theme.spacing.md,
          children: <Widget>[
            for (var i = 0; i < _tiers.length; i++)
              _TierChip(
                name: _tiers[i].$1,
                range: _tiers[i].$2,
                active: i == active,
              ),
          ],
        );
      },
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.name,
    required this.range,
    required this.active,
  });
  final String name;
  final String range;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? theme.colors.primarySoft : theme.colors.card,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        border: Border.all(
          color: active ? theme.colors.primary : theme.colors.separator,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (active) ...<Widget>[
                  MonoBadge(
                    variant: MonoBadgeVariant.neutral,
                    size: MonoBadgeSize.sm,
                    child: const Text('now'),
                  ),
                  SizedBox(width: theme.spacing.sm),
                ],
                Text(name, style: theme.typography.titleMedium),
              ],
            ),
            SizedBox(height: theme.spacing.xs),
            Text(
              '$range pt',
              style: theme.typography.mono.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A component whose layout genuinely reflows with width — the subject of the
/// stage and viewport-row demos. Column count and the summary rail respond to
/// the breakpoint ladder read from [MediaQuery]/constraints.
class ResponsiveShowpiece extends StatelessWidget {
  const ResponsiveShowpiece({super.key});

  static const List<(MonoIconData, String, String)> _items =
      <(MonoIconData, String, String)>[
        (MonoIcons.bag, 'Orders', '128'),
        (MonoIcons.message, 'Threads', '24'),
        (MonoIcons.video, 'Live', '3'),
        (MonoIcons.star, 'Saved', '61'),
        (MonoIcons.receipt, 'Invoices', '12'),
        (MonoIcons.user, 'Team', '8'),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bp = theme.breakpoints;
        final columns = w < bp.compact
            ? 1
            : w < bp.medium
            ? 2
            : w < bp.expanded
            ? 3
            : 4;
        final railBeside = w >= bp.medium;

        final grid = _Grid(columns: columns, items: _items);
        final rail = _SummaryRail(vertical: !railBeside);

        return SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Flex(
            direction: railBeside ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (railBeside) ...<Widget>[
                SizedBox(width: 200, child: rail),
                SizedBox(width: theme.spacing.lg),
                Expanded(child: grid),
              ] else ...<Widget>[
                rail,
                SizedBox(height: theme.spacing.lg),
                grid,
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.items});
  final int columns;
  final List<(MonoIconData, String, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = theme.spacing.md;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final (icon, label, value) in items)
              SizedBox(
                width: tileWidth > 0 ? tileWidth : constraints.maxWidth,
                child: MonoCard(
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MonoIcon(icon, size: 20, color: theme.colors.primary),
                        SizedBox(height: theme.spacing.sm),
                        Text(
                          value,
                          style: theme.typography.tabular(
                            theme.typography.titleLarge,
                          ),
                        ),
                        Text(
                          label,
                          style: theme.typography.labelMedium.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryRail extends StatelessWidget {
  const _SummaryRail({required this.vertical});
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoSurface(
      elevation: MonoElevation.flat,
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('This week', style: theme.typography.titleMedium),
          SizedBox(height: theme.spacing.xs),
          Text(
            vertical
                ? 'Rail stacks above the grid on compact.'
                : 'Rail sits beside the grid from medium up.',
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
          SizedBox(height: theme.spacing.md),
          MonoButton(
            variant: MonoButtonVariant.filled,
            size: MonoButtonSize.sm,
            onPressed: () {},
            leading: const MonoIcon(MonoIcons.add, size: 16),
            child: const Text('New'),
          ),
        ],
      ),
    );
  }
}
