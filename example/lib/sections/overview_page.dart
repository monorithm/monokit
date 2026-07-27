import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';

/// The landing hero: a designed composition, not a list. A headline and CTAs on
/// one side; a live collage of real Monokit widgets on the other, reflowing to a
/// stack on compact viewports.
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= theme.breakpoints.medium;
            const pitch = _Pitch();
            const collage = _Collage();
            if (!wide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  pitch,
                  SizedBox(height: theme.spacing.xxl),
                  collage,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Expanded(flex: 5, child: pitch),
                SizedBox(width: theme.spacing.giant),
                const Expanded(flex: 6, child: collage),
              ],
            );
          },
        ),
        SizedBox(height: theme.spacing.giant),
        const _Highlights(),
      ],
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const MonoBadge(
          variant: MonoBadgeVariant.secondary,
          child: Text('Monokit · v0.10'),
        ),
        SizedBox(height: theme.spacing.lg),
        Text(
          'The design system,\nshown at its best.',
          style: theme.typography.displayLarge,
        ),
        SizedBox(height: theme.spacing.md),
        SizedBox(
          width: 520,
          child: Text(
            'A widgets-first, Material-free Flutter system — emerald on mist, '
            'a luminance step, not hairlines. Explore every component, watch it '
            'reflow across breakpoints, and see it composed into real products.',
            style: theme.typography.bodyLarge.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.xl),
        Wrap(
          spacing: theme.spacing.md,
          runSpacing: theme.spacing.md,
          children: <Widget>[
            // IntrinsicWidth keeps each CTA shrink-wrapped so they sit inline
            // rather than stretching to the full column width.
            IntrinsicWidth(
              child: MonoButton(
                size: MonoButtonSize.lg,
                onPressed: () => context.go('/foundations'),
                leading: const MonoIcon(MonoIcons.sparkles, size: 18),
                child: const Text('Explore foundations'),
              ),
            ),
            IntrinsicWidth(
              child: MonoButton(
                variant: MonoButtonVariant.tinted,
                size: MonoButtonSize.lg,
                onPressed: () => context.go('/responsive'),
                leading: const MonoIcon(MonoIcons.grid, size: 18),
                child: const Text('See it reflow'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A curated arrangement of real widgets — the proof that the system is handsome
/// in composition, not just in a matrix.
class _Collage extends StatelessWidget {
  const _Collage();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MonoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppImage(
                asset: AppAssets.chair,
                seed: 'linen-armchair',
                height: 168,
                icon: MonoIcons.image,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(theme.radii.lg),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(theme.spacing.lg),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Linen lounge chair',
                            style: theme.typography.titleMedium,
                          ),
                          SizedBox(height: theme.spacing.xs / 2),
                          Text(
                            'East Legon · like new',
                            style: theme.typography.labelMedium.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const MonoPriceTag(
                      price: '4,800',
                      compareAt: '5,500',
                      currency: 'GH₵',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: theme.spacing.lg),
        LayoutBuilder(
          builder: (context, constraints) {
            // Side by side when there's room; stacked on narrow panes so the
            // non-ellipsizing status badges never overflow their column.
            if (constraints.maxWidth < theme.breakpoints.medium) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ChatSnippet(),
                  SizedBox(height: 16),
                  _StatusStack(),
                ],
              );
            }
            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: _ChatSnippet()),
                SizedBox(width: 16),
                Expanded(child: _StatusStack()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ChatSnippet extends StatelessWidget {
  const _ChatSnippet();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoSurface(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const MonoAvatar.initials('EA', size: MonoAvatarSize.sm),
              SizedBox(width: theme.spacing.sm),
              Text('Esi Addo', style: theme.typography.labelLarge),
            ],
          ),
          SizedBox(height: theme.spacing.md),
          const MonoBubble(
            align: MonoMessageAlign.start,
            child: Text('Is the chair still available?'),
          ),
          SizedBox(height: theme.spacing.sm),
          const MonoBubble(
            variant: MonoBubbleVariant.primary,
            align: MonoMessageAlign.end,
            child: Text('Yes — free delivery in Accra.'),
          ),
        ],
      ),
    );
  }
}

class _StatusStack extends StatelessWidget {
  const _StatusStack();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoSurface(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Order status', style: theme.typography.labelLarge),
          SizedBox(height: theme.spacing.md),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              MonoBadge(variant: MonoBadgeVariant.success, child: Text('Paid')),
              MonoBadge(
                variant: MonoBadgeVariant.warning,
                child: Text('Packing'),
              ),
              MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text('Out for delivery'),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.lg),
          MonoButton(
            variant: MonoButtonVariant.secondary,
            size: MonoButtonSize.sm,
            onPressed: () {},
            leading: const MonoIcon(MonoIcons.receipt, size: 16),
            child: const Text('Track order'),
          ),
        ],
      ),
    );
  }
}

class _Highlights extends StatelessWidget {
  const _Highlights();

  static const List<(MonoIconData, String, String)>
  _cards = <(MonoIconData, String, String)>[
    (
      MonoIcons.grid,
      'Responsive by design',
      'Widgets read the viewport. Drag the stage or pin any device to watch '
          'real reflow.',
    ),
    (
      MonoIcons.sparkles,
      'Two registers',
      'Component pages document every variant and state; scenarios show them '
          'composed into products.',
    ),
    (
      MonoIcons.image,
      'Emerald on mist',
      'A rationed accent over cool mist neutrals, separated by value — '
          'in light and dark.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < theme.breakpoints.compact
            ? 1
            : constraints.maxWidth < theme.breakpoints.expanded
            ? 2
            : 3;
        final gap = theme.spacing.lg;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final (icon, title, body) in _cards)
              SizedBox(
                width: tileWidth,
                child: MonoCard(
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        MonoIcon(icon, color: theme.colors.primary),
                        SizedBox(height: theme.spacing.sm),
                        Text(title, style: theme.typography.titleMedium),
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          body,
                          style: theme.typography.bodyMedium.copyWith(
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
