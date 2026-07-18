import 'package:flutter/widgets.dart';

import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';

class MonoGlassSurface extends StatelessWidget {
  const MonoGlassSurface({super.key, required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.glassFill,
        border: Border.all(color: t.colors.glassBorder),
        borderRadius: BorderRadius.circular(t.radii.lg),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(t.spacing.md),
        child: child,
      ),
    );
  }
}

class MonoScrim extends StatelessWidget {
  const MonoScrim({super.key, this.strong = false, this.child});
  final bool strong;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    final c = MonokitTheme.of(context).colors;
    return ColoredBox(color: strong ? c.scrimStrong : c.scrim, child: child);
  }
}

class MonoSurface extends StatelessWidget {
  const MonoSurface({
    super.key,
    required this.child,
    this.tier = MonoElevationTier.e1,
    this.padding,
  });
  final Widget child;
  final MonoElevationTier tier;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.card,
        border: Border.all(color: t.colors.border),
        borderRadius: BorderRadius.circular(t.radii.lg),
        boxShadow: t.elevation.resolve(tier),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(t.spacing.md),
        child: child,
      ),
    );
  }
}
