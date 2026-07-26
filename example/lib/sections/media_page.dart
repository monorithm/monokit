import 'package:monokit/monokit.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Media',
          title: 'Immersive surfaces',
          tagline:
              'Full-bleed media on the always-dark canvas, glass controls, live '
              'badges, action rails, waveforms, and call controls.',
          child: const _MediaHero(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Immersive surface',
          widgetName: 'MonoMediaSurface',
          description:
              'Full-bleed media on the dark canvas; glass controls over content; '
              'marketplace facts survive immersion. The live badge is sacred.',
          child: SizedBox(
            width: 300,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(theme.radii.xl),
                child: MonoMediaSurface(
                  semanticLabel: 'Waakye, Accra Central',
                  overlay: Stack(
                    children: <Widget>[
                      PositionedDirectional(
                        top: theme.spacing.md,
                        start: theme.spacing.md,
                        child: const MonoLiveBadge(),
                      ),
                      PositionedDirectional(
                        bottom: 100,
                        end: theme.spacing.md,
                        child: MonoActionRail(
                          actions: const <Widget>[
                            _RailAction(MonoIcons.like, '128'),
                            _RailAction(MonoIcons.message, '12'),
                            _RailAction(MonoIcons.send, 'Share'),
                          ],
                        ),
                      ),
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _Facts(),
                      ),
                    ],
                  ),
                  child: const AppImage(
                    asset: AppAssets.food,
                    seed: 'waakye',
                    onMediaCanvas: true,
                  ),
                ),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Waveform',
          widgetName: 'MonoWaveform',
          description:
              'Voice-note visual (captions/transcripts required in '
              'production).',
          child: const SizedBox(
            width: 260,
            height: 40,
            child: MonoWaveform(
              amplitudes: <double>[.2, .6, .3, .9, .5, .7, .2, .8, .4, .6, .3],
              progress: .45,
            ),
          ),
        ),
        ComponentSection(
          title: 'Capture bar',
          widgetName: 'MonoCaptureBar',
          child: MonoCaptureBar(
            shutter: MonoCameraShutter(onPressed: () {}),
            leading: MonoButton.icon(
              variant: MonoButtonVariant.ghost,
              icon: const MonoIcon(MonoIcons.image),
              onPressed: () {},
            ),
            trailing: MonoButton.icon(
              variant: MonoButtonVariant.ghost,
              icon: const MonoIcon(MonoIcons.mic),
              onPressed: () {},
            ),
          ),
        ),
        ComponentSection(
          title: 'Call controls',
          widgetName: 'MonoCallControls',
          child: MonoCallControls(
            children: <Widget>[
              MonoButton(
                variant: MonoButtonVariant.secondary,
                size: MonoButtonSize.icon,
                onPressed: () {},
                child: const MonoIcon(MonoIcons.mic),
              ),
              MonoButton(
                variant: MonoButtonVariant.secondary,
                size: MonoButtonSize.icon,
                onPressed: () {},
                child: const MonoIcon(MonoIcons.video),
              ),
              MonoButton(
                variant: MonoButtonVariant.destructive,
                size: MonoButtonSize.icon,
                onPressed: () {},
                child: const MonoIcon(MonoIcons.close),
              ),
            ],
          ),
        ),
      ],
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
        MonoIcon(icon, size: 24, color: theme.colors.onMedia),
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

class _Facts extends StatelessWidget {
  const _Facts();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScrim(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Home-cooked waakye',
              style: theme.typography.mediaTitle.copyWith(
                color: theme.colors.onMedia,
              ),
            ),
            SizedBox(height: theme.spacing.xs),
            Row(
              children: <Widget>[
                Text(
                  'GH₵ 25',
                  style: theme.typography
                      .tabular(theme.typography.titleMedium)
                      .copyWith(color: theme.colors.onMedia),
                ),
                SizedBox(width: theme.spacing.sm),
                Flexible(
                  child: Text(
                    'Accra Central · 2 min',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.typography.mediaCaption.copyWith(
                      color: theme.colors.onMediaMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A pair of immersive media tiles for the hero.
class _MediaHero extends StatelessWidget {
  const _MediaHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      height: 200,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MediaTile(
              asset: AppAssets.live,
              seed: 'live',
              title: 'Live: market run',
              live: true,
            ),
          ),
          SizedBox(width: theme.spacing.lg),
          Expanded(
            child: _MediaTile(
              asset: AppAssets.travel,
              seed: 'travel',
              title: 'Cape Coast weekend',
              live: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.asset,
    required this.seed,
    required this.title,
    required this.live,
  });

  final String asset;
  final String seed;
  final String title;
  final bool live;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radii.lg),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AppImage(asset: asset, seed: seed, onMediaCanvas: true),
          if (live)
            PositionedDirectional(
              top: theme.spacing.sm,
              start: theme.spacing.sm,
              child: const MonoLiveBadge(),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MonoScrim(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.sm),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.mediaCaption.copyWith(
                    color: theme.colors.onMedia,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
