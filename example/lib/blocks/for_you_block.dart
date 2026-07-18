import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/sample.dart';

/// Production-style block: the immersive For You feed. Media on the dark canvas;
/// glass controls over content; marketplace facts survive immersion; a person
/// advances the feed (no auto-play).
class ForYouBlock extends StatelessWidget {
  const ForYouBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScreen(
      background: theme.colors.mediaCanvas,
      insetPolicy: const MonoInsetPolicy(top: MonoInsetMode.scrim),
      body: MonoFeedPager(
        itemCount: sampleFeed.length,
        itemBuilder: (context, i) => _FeedItem(post: sampleFeed[i]),
      ),
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({required this.post});
  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final topInset = MonoScreen.of(context).resolvedBodyInsets.top;
    return MonoMediaSurface(
      semanticLabel: post.title,
      overlay: Stack(
        children: <Widget>[
          if (post.isLive)
            PositionedDirectional(
              top: topInset + theme.spacing.md,
              start: theme.spacing.md,
              child: const MonoLiveBadge(),
            ),
          PositionedDirectional(
            bottom: 140,
            end: theme.spacing.md,
            child: MonoActionRail(
              actions: <Widget>[
                _RailAction(MonoIcons.like, '128', onTap: () {}),
                _RailAction(MonoIcons.message, '12', onTap: () {}),
                _RailAction(MonoIcons.send, 'Share', onTap: () {}),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MonoScrim(
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        MonoBadge(
                          variant: MonoBadgeVariant.secondary,
                          child: Text(post.reason),
                        ),
                        SizedBox(width: theme.spacing.sm),
                        Flexible(
                          child: Text(
                            '${post.ageLabel} · ${post.location}',
                            style: theme.typography.mediaCaption.copyWith(
                              color: theme.colors.onMediaMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: theme.spacing.sm),
                    Text(
                      post.title,
                      style: theme.typography.mediaTitle.copyWith(
                        color: theme.colors.onMedia,
                      ),
                    ),
                    SizedBox(height: theme.spacing.md),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            post.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography
                                .tabular(theme.typography.titleLarge)
                                .copyWith(color: theme.colors.onMedia),
                          ),
                        ),
                        SizedBox(width: theme.spacing.sm),
                        MonoButton(
                          onPressed: () {},
                          child: const Text('Register interest'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      child: post.media,
    );
  }
}

class _RailAction extends StatelessWidget {
  const _RailAction(this.icon, this.label, {required this.onTap});
  final MonoIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoButton(
      variant: MonoButtonVariant.ghost,
      onPressed: onTap,
      child: Column(
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
      ),
    );
  }
}
