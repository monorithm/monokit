import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Paints Monokit's token-derived keyboard focus ring around [child].
class MonoFocusRing extends StatelessWidget {
  const MonoFocusRing({
    super.key,
    required this.child,
    required this.focused,
    this.borderRadius,
    this.width = 2,
    this.padding = 2,
  });

  final Widget child;
  final bool focused;
  final BorderRadius? borderRadius;
  final double width;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(theme.radii.md);
    return AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.curve,
      padding: EdgeInsets.all(focused ? padding : 0),
      decoration: BoxDecoration(
        borderRadius: radius,
        border: focused
            ? Border.all(color: theme.colors.ring, width: width)
            : null,
      ),
      child: child,
    );
  }
}
