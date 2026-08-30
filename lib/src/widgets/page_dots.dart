import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Position, stated quietly.
///
/// Dots report where the user is in a short sequence and nothing else. Two
/// rules are easy to get wrong and are the reason this is a component rather
/// than a `Row` of circles:
///
/// * **The active dot widens.** It does not only change colour. Position has to
///   survive a colour-blind reading, and a wider dot says "here" without any
///   hue at all.
/// * **It is one semantics node, not five.** A row of anonymous dots is five
///   stops for a screen reader and tells it nothing; one node reporting "2 of
///   5" is the whole message in one move.
///
/// Never the only way to see progress through a flow, and never on a spring —
/// an indicator reports, it does not perform.
class MonoPageDots extends StatelessWidget {
  const MonoPageDots({
    super.key,
    required this.count,
    this.index = 0,
    this.onMedia = false,
    this.label = 'Page',
  }) : assert(count > 0, 'A sequence needs at least one page.');

  final int count;
  final int index;

  /// Renders in the on-media register, for dots drawn over a photograph.
  final bool onMedia;

  /// The noun this sequence counts, in the user's language — "Page", "Photo".
  final String label;

  /// Beyond a handful, position is a number rather than a picture. This is the
  /// point where a caller should show "7 of 24" instead.
  static const int comfortable = 8;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final active = index.clamp(0, count - 1);

    final Color activeInk = onMedia
        ? theme.colors.onMedia
        : theme.colors.primary;
    final Color restInk = onMedia
        ? theme.colors.onMediaMuted
        : theme.colors.mutedForeground;

    return Semantics(
      container: true,
      // One node for the whole sequence: the count and the position are the
      // message, and the dots themselves are decoration for the eye only.
      label: '$label ${active + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: theme.motion.reduced(context, theme.motion.state),
              curve: theme.motion.standard,
              margin: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
              width: i == active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == active
                    ? activeInk
                    : restInk.withValues(alpha: 0.35),
                borderRadius: theme.radii.borderRadiusFull,
              ),
            ),
        ],
      ),
    );
  }
}
