import 'package:go_router/go_router.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';

/// An immersive live-shopping surface on the always-dark media canvas.
class LiveStudioScenario extends StatelessWidget {
  const LiveStudioScenario({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: theme.colors.mediaCanvas,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const AppImage(
            asset: AppAssets.live,
            seed: 'live',
            onMediaCanvas: true,
          ),
          // Top gradient scrim for legibility.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: MonoScrim(),
          ),
          Positioned(
            top: media.padding.top + theme.spacing.sm,
            left: theme.spacing.md,
            right: theme.spacing.md,
            child: Row(
              children: <Widget>[
                MonoButton(
                  variant: MonoButtonVariant.ghost,
                  size: MonoButtonSize.sm,
                  iconOnly: true,
                  semanticLabel: 'Back',
                  onPressed: () => context.go('/scenarios'),
                  child: MonoIcon(
                    MonoIcons.chevronLeft,
                    color: theme.colors.onMedia,
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                const MonoLiveBadge(),
                SizedBox(width: theme.spacing.sm),
                _MistPill(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      MonoIcon(
                        MonoIcons.user,
                        size: 16,
                        color: theme.colors.onMedia,
                      ),
                      SizedBox(width: theme.spacing.xs),
                      Text(
                        '1.2k',
                        style: theme.typography.labelMedium.copyWith(
                          color: theme.colors.onMedia,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: theme.spacing.md,
            bottom: media.padding.bottom + 140,
            child: MonoActionRail(
              actions: <Widget>[
                _RailAction(MonoIcons.like, '3.4k'),
                _RailAction(MonoIcons.message, '212'),
                _RailAction(MonoIcons.send, 'Share'),
              ],
            ),
          ),
          Positioned(
            left: theme.spacing.md,
            right: theme.spacing.md,
            bottom: media.padding.bottom + theme.spacing.lg,
            child: _BuyBar(),
          ),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoMediaChrome(
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.sm),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: AppImage(asset: AppAssets.sneakers, seed: 'sneakers'),
            ),
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Retro sneakers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.labelLarge.copyWith(
                    color: theme.colors.onMedia,
                  ),
                ),
                Text(
                  'GH₵ 320 · 8 left',
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.onMediaMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: theme.spacing.sm),
          MonoButton(
            onPressed: () {},
            leading: const MonoIcon(MonoIcons.bag, size: 16),
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }
}

class _MistPill extends StatelessWidget {
  const _MistPill({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoMediaChrome(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.sm,
        vertical: theme.spacing.xs,
      ),
      child: child,
    );
  }
}

class _RailAction extends StatelessWidget {
  const _RailAction(this.icon, this.label);
  final MonoIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MonoIcon(icon, size: 26, color: theme.colors.onMedia),
        SizedBox(height: theme.spacing.xs),
        Text(
          label,
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.onMedia,
          ),
        ),
      ],
    );
  }
}
