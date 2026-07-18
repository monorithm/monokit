import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        ComponentSection(
          title: 'Palette — emerald on mist',
          widgetName: 'MonokitColors',
          description:
              'A rationed emerald accent over cool slate neutrals, in light '
              'and dark. Cards separate by border and light, not luminance.',
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
          title: 'Elevation — borders and light, not shadows',
          widgetName: 'MonoSurface',
          description: 'Five tiers: flat · raised · overlay · modal · system.',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            children: <Widget>[
              for (final tier in MonoElevationTier.values)
                DemoTile(
                  label: tier.name,
                  child: MonoSurface(
                    tier: tier,
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
        ComponentSection(
          title: 'Motion tokens',
          widgetName: 'MonokitMotion',
          description:
              'Physics for moments, curves for chrome. monoOut is the signature '
              'deceleration; springs are rationed to genuine moments.',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: const <Widget>[
              MonoBadge(
                variant: MonoBadgeVariant.secondary,
                child: Text('fast 100ms'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.secondary,
                child: Text('base 150ms'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.secondary,
                child: Text('moderate 220ms'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.secondary,
                child: Text('slow 300ms'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text('monoOut'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text('spatialSpring'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text('celebrateSpring'),
              ),
            ],
          ),
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
    final entries = <(String, Color)>[
      ('background', colors.background),
      ('foreground', colors.foreground),
      ('primary', colors.primary),
      ('primarySoft', colors.primarySoft),
      ('secondary', colors.secondary),
      ('muted', colors.muted),
      ('accent', colors.accent),
      ('destructive', colors.destructive),
      ('success', colors.success),
      ('warning', colors.warning),
      ('info', colors.info),
      ('live', colors.live),
      ('border', colors.border),
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
                      border: Border.all(color: theme.colors.border),
                    ),
                  ),
                  SizedBox(height: theme.spacing.xs),
                  SizedBox(
                    width: 52,
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.mutedForeground,
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
              color: theme.colors.mutedForeground,
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
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: theme.colors.border),
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
