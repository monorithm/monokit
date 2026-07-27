import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Foundations',
          title: 'The design language',
          tagline:
              'Emerald on mist, IBM Plex across three registers, depth from a '
              'luminance step, and spring-driven motion — the tokens every '
              'widget resolves from MonokitTheme.of(context).',
          child: const _MotionDemo(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Palette — emerald on mist',
          widgetName: 'MonokitColors',
          description:
              'A rationed emerald accent over cool mist neutrals, in light and '
              'dark. Surfaces separate by a luminance step — page, then card, '
              'then elevated — not by a hairline.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _PaletteRow(label: 'Light', colors: MonokitColors.light()),
              SizedBox(height: theme.spacing.lg),
              _PaletteRow(label: 'Dark', colors: MonokitColors.dark()),
            ],
          ),
        ),
        ComponentSection(
          title: 'Type ramp',
          widgetName: 'MonokitTypography',
          description:
              'Sans for chrome and content; a serif reading register; and the '
              'mono/tabular register for machine-shaped text.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TypeRow('displayMedium', theme.typography.displayMedium),
              _TypeRow('headlineMedium', theme.typography.headlineMedium),
              _TypeRow('titleMedium', theme.typography.titleMedium),
              _TypeRow('bodyMedium', theme.typography.bodyMedium),
              _TypeRow('labelMedium', theme.typography.labelMedium),
              Padding(
                padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
                child: MonoSeparator(),
              ),
              _TypeRow(
                'prose (serif)',
                theme.typography.prose,
                sample: 'Clean iPhone 13, meet at Nima.',
              ),
              _TypeRow(
                'mono · tabular',
                theme.typography.mono,
                sample: 'GH₵ 4,800   ·   024 000 0000   ·   #A1B2C3',
              ),
              _TypeRow(
                'tabular(titleLarge) — a price',
                theme.typography.tabular(theme.typography.titleLarge),
                sample: 'GH₵ 4,800',
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Elevation — reserved for what actually floats',
          widgetName: 'MonoSurface',
          description:
              'Three tiers: flat · raised · floating. Flat is the common case, '
              'because the page-to-card step already carries the depth; a '
              'shadow means something is genuinely above the page.',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            children: <Widget>[
              for (final tier in MonoElevation.values)
                DemoTile(
                  label: tier.name,
                  child: MonoSurface(
                    elevation: tier,
                    padding: EdgeInsets.all(theme.spacing.lg),
                    child: const SizedBox(width: 56, height: 40),
                  ),
                ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Radius scale',
          widgetName: 'MonokitRadii',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            children: <Widget>[
              _RadiusTile('sm', theme.radii.sm),
              _RadiusTile('md', theme.radii.md),
              _RadiusTile('lg', theme.radii.lg),
              _RadiusTile('xl', theme.radii.xl),
              _RadiusTile('full', theme.radii.full),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Motion tokens',
          widgetName: 'MonokitMotion',
          description:
              'If it moves in space it springs; if it only changes appearance '
              'it eases. Press Play to watch the curves that remain — opacity '
              'and colour — run rather than just read their names.',
          child: _MotionDemo(),
        ),
        ComponentSection(
          title: 'Icons',
          widgetName: 'MonoIcons',
          description:
              'The dependency-free catalog (vector migration pending).',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            children: const <Widget>[
              _IconTile('add', MonoIcons.add),
              _IconTile('search', MonoIcons.search),
              _IconTile('send', MonoIcons.send),
              _IconTile('like', MonoIcons.like),
              _IconTile('message', MonoIcons.message),
              _IconTile('location', MonoIcons.location),
              _IconTile('filter', MonoIcons.filter),
              _IconTile('mic', MonoIcons.mic),
              _IconTile('image', MonoIcons.image),
              _IconTile('bag', MonoIcons.bag),
              _IconTile('video', MonoIcons.video),
              _IconTile('call', MonoIcons.call),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.label, required this.colors});
  final String label;
  final MonokitColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    // The 2.0 role names. The old labels survived the rename and had started
    // lying — `secondary` and `muted` both pointed at `fill`, and `accent` at
    // `primary`, so three swatches were duplicates of two others.
    final entries = <(String, Color)>[
      ('page', colors.page),
      ('card', colors.card),
      ('elevated', colors.elevated),
      ('foreground', colors.foreground),
      ('foregroundMuted', colors.foregroundMuted),
      ('foregroundSubtle', colors.foregroundSubtle),
      ('fill', colors.fill),
      ('separator', colors.separator),
      ('tint', colors.tint),
      ('primary', colors.primary),
      ('primarySoft', colors.primarySoft),
      ('danger', colors.danger),
      ('success', colors.success),
      ('warning', colors.warning),
      ('info', colors.info),
      ('live', colors.live),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: theme.typography.labelLarge),
        SizedBox(height: theme.spacing.sm),
        Wrap(
          spacing: theme.spacing.sm,
          runSpacing: theme.spacing.sm,
          children: <Widget>[
            for (final (name, color) in entries)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(theme.radii.sm),
                      border: Border.all(color: theme.colors.separator),
                    ),
                  ),
                  SizedBox(height: theme.spacing.xs),
                  SizedBox(
                    width: 52,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow(this.name, this.style, {this.sample});
  final String name;
  final TextStyle style;
  final String? sample;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: theme.typography.labelMedium.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
          Text(sample ?? 'The quick brown fox', style: style),
        ],
      ),
    );
  }
}

class _RadiusTile extends StatelessWidget {
  const _RadiusTile(this.label, this.radius);
  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DemoTile(
      label: label,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colors.fill,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: theme.colors.separator),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile(this.label, this.icon);
  final String label;
  final MonoIconData icon;

  @override
  Widget build(BuildContext context) =>
      DemoTile(label: label, child: MonoIcon(icon, size: 22));
}

/// An animated motion demo — dots ride each curve on a loop so the tokens are
/// felt, not just named.
class _MotionDemo extends StatefulWidget {
  const _MotionDemo();

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final tracks = <(String, Curve)>[
      ('linear', theme.motion.linear),
      ('standard', theme.motion.standard),
      ('monoOut', theme.motion.monoOut),
      ('emphasized', theme.motion.emphasized),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final (label, curve) in tracks)
          Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.md),
            child: _Track(label: label, curve: curve, controller: _controller),
          ),
        SizedBox(height: theme.spacing.xs),
        Wrap(
          spacing: theme.spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            MonoButton(
              variant: MonoButtonVariant.tinted,
              size: MonoButtonSize.sm,
              onPressed: () => _controller
                ..reset()
                ..repeat(),
              leading: const MonoIcon(MonoIcons.play, size: 14),
              child: const Text('Replay'),
            ),
            const MonoBadge(
              variant: MonoBadgeVariant.secondary,
              child: Text('150–300ms'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.label,
    required this.curve,
    required this.controller,
  });

  final String label;
  final Curve curve;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Row(
      children: <Widget>[
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: theme.typography.mono.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
        SizedBox(width: theme.spacing.sm),
        Expanded(
          child: SizedBox(
            height: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dot = 16.0;
                final travel = constraints.maxWidth - dot;
                return AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    // Ease the first half out, hold, then return — so the curve
                    // shape is legible on a loop.
                    final t = controller.value;
                    final phase = t < 0.5 ? t * 2 : (1 - t) * 2;
                    final v = curve.transform(phase.clamp(0.0, 1.0));
                    return Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 2,
                            color: theme.colors.separator,
                          ),
                        ),
                        Positioned(
                          left: v * travel,
                          top: 2,
                          child: Container(
                            width: dot,
                            height: dot,
                            decoration: BoxDecoration(
                              color: theme.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
