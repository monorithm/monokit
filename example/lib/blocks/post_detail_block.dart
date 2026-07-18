import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/sample.dart';

/// Production-style block: post detail / public share. The opened post owns the
/// viewport; availability is a first-class, visually-distinct state; a terminal
/// state disables the primary action. Toggle "Mark sold" to see it.
class PostDetailBlock extends StatefulWidget {
  const PostDetailBlock({super.key});

  @override
  State<PostDetailBlock> createState() => _PostDetailBlockState();
}

class _PostDetailBlockState extends State<PostDetailBlock> {
  final FeedPost _post = sampleFeed.first;
  bool _sold = false;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final availability = _sold
        ? MonoAvailability.fulfilled
        : MonoAvailability.available;
    final actionable = availability.isActionable;
    return MonoScreen(
      header: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: <Widget>[
            Text('Post', style: theme.typography.titleMedium),
            const Spacer(),
            MonoButton.icon(
              variant: MonoButtonVariant.ghost,
              icon: const MonoIcon(MonoIcons.send),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: MonoMediaSurface(child: _post.media),
          ),
          Padding(
            padding: EdgeInsets.all(theme.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AvailabilityBadge(availability),
                    const Spacer(),
                    Text(
                      '${_post.ageLabel} · ${_post.location}',
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing.md),
                Text(_post.title, style: theme.typography.headlineMedium),
                SizedBox(height: theme.spacing.sm),
                MonoPriceTag(
                  currency: 'GH₵',
                  price: _post.price.replaceAll('GH₵ ', ''),
                  compareAt: _post.wasPrice?.replaceAll('GH₵ ', ''),
                ),
                SizedBox(height: theme.spacing.lg),
                Text(_post.description, style: theme.typography.prose),
                SizedBox(height: theme.spacing.xl),
                Row(
                  children: <Widget>[
                    MonoAvatar(initials: _post.seller.initials),
                    SizedBox(width: theme.spacing.sm),
                    Expanded(
                      child: Text(
                        _post.seller.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.titleMedium,
                      ),
                    ),
                    SizedBox(width: theme.spacing.sm),
                    MonoButton(
                      variant: MonoButtonVariant.outline,
                      size: MonoButtonSize.sm,
                      onPressed: () => setState(() => _sold = !_sold),
                      child: Text(_sold ? 'Mark available' : 'Mark sold'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      footer: MonoSurface(
        tier: MonoElevationTier.e4,
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                actionable ? 'Available now' : 'This item is sold',
                style: theme.typography.titleMedium.copyWith(
                  color: actionable
                      ? theme.colors.foreground
                      : theme.colors.mutedForeground,
                ),
              ),
            ),
            MonoButton(
              variant: actionable
                  ? MonoButtonVariant.primary
                  : MonoButtonVariant.secondary,
              onPressed: actionable ? () {} : null,
              child: Text(actionable ? 'Register interest' : 'Sold'),
            ),
          ],
        ),
      ),
    );
  }
}
