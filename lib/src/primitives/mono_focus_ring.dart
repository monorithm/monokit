import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Paints Monokit's token-derived keyboard focus ring around [child].
///
/// [width] and [padding] default to the theme's `focus` tokens
/// (`MonokitFocus.ringWidth` / `ringOffset`) when left null, so the ring stays
/// consistent with the rest of the system unless a caller overrides them.
class MonoFocusRing extends StatelessWidget {
  const MonoFocusRing({
    super.key,
    required this.child,
    required this.focused,
    this.borderRadius,
    this.width,
    this.padding,
  });

  final Widget child;
  final bool focused;
  final BorderRadius? borderRadius;

  /// Ring stroke width. Defaults to `theme.focus.ringWidth` when null.
  final double? width;

  /// Gap between [child] and the ring. Defaults to `theme.focus.ringOffset`
  /// when null.
  final double? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(theme.radii.md);
    final ringWidth = width ?? theme.focus.ringWidth;
    final ringOffset = padding ?? theme.focus.ringOffset;
    return AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.curve,
      padding: EdgeInsets.all(focused ? ringOffset : 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        border: focused
            ? Border.all(color: theme.colors.ring, width: ringWidth)
            : null,
      ),
      child: child,
    );
  }
}

/// Paints the focus ring **outside** [child]'s bounds, taking no part in
/// layout.
///
/// [MonoFocusRing] expresses the ring as padding, which grows the widget when
/// it gains focus — fine for a pressable that owns its own box, wrong for a
/// field in a form, where every sibling would shift as the user tabs through.
/// A `BoxShadow` avoids the shift but cannot express the gap: its spread
/// begins at the border box, so the band always touches the control and reads
/// as a thicker border.
///
/// So the ring is drawn as a real outline in an unclipped [Stack]: offset from
/// the control by `focus.ringOffset`, transparent in between so whatever the
/// field sits on shows through, and radius-corrected so it stays concentric
/// with the corner it traces rather than tightening against it.
///
/// One consequence worth knowing: the ring extends `ringOffset + ringWidth`
/// beyond the control, so an ancestor that clips — a scroll view at its default
/// `Clip.hardEdge`, a `ClipRRect` — will trim it. That is the same behaviour
/// `outline-offset` has on the web, and the reason forms leave a gutter.
class MonoFocusRingOverlay extends StatelessWidget {
  const MonoFocusRingOverlay({
    super.key,
    required this.child,
    required this.focused,
    required this.borderRadius,
    this.color,
    this.width,
    this.offset,
  });

  final Widget child;
  final bool focused;

  /// The radius of the control being ringed. The ring's own radius is this
  /// plus the gap, so the two curves stay concentric.
  final BorderRadius borderRadius;

  /// Defaults to `colors.ring`. Pass `colors.destructive` for an invalid
  /// control, so the ring carries the same meaning as the message beneath it.
  final Color? color;

  final double? width;
  final double? offset;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final double ringWidth = width ?? theme.focus.ringWidth;
    final double gap = offset ?? theme.focus.ringOffset;
    final double outset = gap + ringWidth;
    final Color ink = (color ?? theme.colors.ring).withValues(
      alpha: theme.focus.ringAlpha,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        Positioned(
          left: -outset,
          top: -outset,
          right: -outset,
          bottom: -outset,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: focused ? 1 : 0,
              duration: theme.motion.reduced(context, theme.motion.state),
              curve: theme.motion.standard,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius + BorderRadius.circular(outset),
                  border: Border.all(color: ink, width: ringWidth),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
