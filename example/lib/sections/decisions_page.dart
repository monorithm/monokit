import 'package:monokit_ui/monokit_ui.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

/// The four decisions monokit 2.0 is built on, each shown rather than asserted.
///
/// Every other section demonstrates a component. This one demonstrates the
/// *system*: it exists because the four axes are cross-cutting, so no single
/// component shows any of them on its own.
class DecisionsPage extends StatelessWidget {
  const DecisionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Decisions',
          title: 'Four axes, shown not asserted',
          tagline:
              'Springs for anything spatial. Density that adapts to the input. '
              'Grouped surfaces — one thing in focus. Emerald on mist, lifted '
              'in the dark.',
          child: Row(
            children: <Widget>[
              Expanded(child: _TintCard(colors: MonokitColors.light())),
              SizedBox(width: theme.spacing.lg),
              Expanded(child: _TintCard(colors: MonokitColors.dark())),
            ],
          ),
        ),
        const SectionDivider(),

        ComponentSection(
          title: 'Motion — if it moves in space, it springs',
          widgetName: 'MonoSpringController',
          description:
              'Drag the sheet halfway and let go. The release velocity is '
              'projected forward to decide dismiss-versus-return, so a hard '
              'flick from past the midpoint still closes. Grab it mid-flight '
              'and it catches at its current speed instead of restarting.',
          child: Row(
            children: <Widget>[
              MonoSheet(
                trigger: const MonoSheetTrigger(
                  child: MonoButton(child: Text('Open a draggable sheet')),
                ),
                child: MonoSheetContent(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const MonoSheetHeader(
                        title: Text('Drag me down'),
                        description: Text(
                          'Release gently and I spring back; flick and I go.',
                        ),
                      ),
                      SizedBox(height: theme.spacing.lg),
                      const _SpringFacts(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        ComponentSection(
          title: 'Density — one component set, two metrics',
          widgetName: 'MonokitDensity',
          description:
              'Resolved once at the root from the platform, promoted by width, '
              'and overridable by the host. It drives the whole ramp — row '
              'height, control height, margin and type — not just a tap '
              'target. Both columns below are the same widgets.',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _DensityColumn(mode: MonoDensity.touch, label: 'Touch'),
              ),
              SizedBox(width: theme.spacing.xxl),
              Expanded(
                child: _DensityColumn(
                  mode: MonoDensity.pointer,
                  label: 'Pointer',
                ),
              ),
            ],
          ),
        ),

        ComponentSection(
          title: 'Surface — separation by value, not hairline',
          widgetName: 'MonoSurface',
          description:
              'page → card → elevated. Each step is a luminance change, which '
              'is why cards carry no border by default and why dark lifts to a '
              'charcoal rather than bottoming out at black — pure black leaves '
              'nothing for the card to step up from.',
          child: MonoSurface(
            role: MonoSurfaceRole.page,
            padding: EdgeInsets.all(theme.spacing.xxl),
            child: MonoSurface(
              padding: EdgeInsets.all(theme.spacing.xxl),
              child: MonoSurface(
                role: MonoSurfaceRole.elevated,
                elevation: MonoElevation.floating,
                padding: EdgeInsets.all(theme.spacing.xxl),
                child: Text(
                  'elevated, inside card, inside page',
                  style: theme.typography.labelLarge.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ),
          ),
        ),

        ComponentSection(
          title: 'Theme — emerald on mist, both modes',
          widgetName: 'MonokitColors',
          description:
              'tint colours interactive text and icons; primary fills solids. '
              'They are the same value in light and diverge in dark, where the '
              'text must lighten and the fill must darken to hold contrast '
              'against their own grounds.',
          child: Row(
            children: <Widget>[
              Expanded(child: _TintCard(colors: MonokitColors.light())),
              SizedBox(width: theme.spacing.lg),
              Expanded(child: _TintCard(colors: MonokitColors.dark())),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpringFacts extends StatelessWidget {
  const _SpringFacts();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final springs = <(String, String)>[
      ('spatial', 'stiffness 700 · ratio 0.9 — sheets, drawers, pushes'),
      ('effect', 'stiffness 1600 · ratio 1.0 — toggles, dots'),
      ('celebrate', 'stiffness 550 · ratio 0.75 — the only overshoot'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (name, detail) in springs)
          Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 84,
                  child: Text(name, style: theme.typography.mono),
                ),
                Expanded(
                  child: Text(
                    detail,
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The same widgets under a forced density, so the two columns are directly
/// comparable.
class _DensityColumn extends StatelessWidget {
  const _DensityColumn({required this.mode, required this.label});

  final MonoDensity mode;
  final String label;

  @override
  Widget build(BuildContext context) {
    final outer = MonokitTheme.of(context);
    final scoped = outer.withDensityMode(mode);
    return MonokitTheme(
      data: scoped,
      child: Builder(
        builder: (context) {
          final theme = MonokitTheme.of(context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$label · row ${theme.rowHeight.toInt()} · '
                'body ${theme.bodyText.fontSize?.toInt()}',
                style: outer.typography.mono.copyWith(
                  color: outer.colors.foregroundMuted,
                ),
              ),
              SizedBox(height: outer.spacing.sm),
              MonoButton(
                onPressed: () {},
                child: Text('Continue', style: theme.bodyText),
              ),
              SizedBox(height: outer.spacing.sm),
              Container(
                height: theme.rowHeight,
                alignment: AlignmentDirectional.centerStart,
                padding: EdgeInsets.symmetric(horizontal: theme.layoutMargin),
                color: theme.colors.card,
                child: Text('A list row', style: theme.bodyText),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TintCard extends StatelessWidget {
  const _TintCard({required this.colors});

  final MonokitColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final isDark = colors.page == MonokitColors.dark().page;
    return Container(
      padding: EdgeInsets.all(theme.spacing.lg),
      decoration: BoxDecoration(
        color: colors.page,
        borderRadius: BorderRadius.circular(theme.radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isDark ? 'Dark' : 'Light',
            style: theme.typography.labelLarge.copyWith(
              color: colors.foreground,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Container(
            padding: EdgeInsets.all(theme.spacing.md),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(theme.radii.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'tint — interactive text',
                  style: theme.typography.bodyMedium.copyWith(
                    color: colors.tint,
                  ),
                ),
                SizedBox(height: theme.spacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.md,
                    vertical: theme.spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(theme.radii.md),
                  ),
                  child: Text(
                    'primary — solid fill',
                    style: theme.typography.button.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
