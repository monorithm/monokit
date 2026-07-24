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
