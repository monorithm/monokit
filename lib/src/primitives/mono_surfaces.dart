import 'package:flutter/widgets.dart';

import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';

/// Which step of the grouped ladder a surface occupies.
enum MonoSurfaceRole {
  /// The screen ground. Rarely drawn directly — [MonoScreen] owns it.
  page,

  /// The default content surface, one luminance step above the page.
  card,

  /// Genuinely floating layers: menus, popovers, dialogs, sheets.
  elevated,
}

/// The one way a surface is drawn.
///
/// Monokit's surface model is **grouped**: a surface separates from what is
/// behind it by a *luminance step*, not by a hairline. So there is no border
/// here, and none should be added at call sites — use [MonoSeparator] to
/// divide content *within* a surface instead.
///
/// Elevation defaults to [MonoElevation.flat] because in the grouped model the
/// colour step already carries the depth. Reserve a shadow for things that
/// genuinely float above the page.
class MonoSurface extends StatelessWidget {
  const MonoSurface({
    super.key,
    required this.child,
    this.role = MonoSurfaceRole.card,
    this.elevation = MonoElevation.flat,
    this.padding,
    this.radius,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final MonoSurfaceRole role;
  final MonoElevation elevation;
  final EdgeInsetsGeometry? padding;

  /// Defaults to `radii.lg`.
  final BorderRadius? radius;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedRadius = radius ?? BorderRadius.circular(theme.radii.lg);
    final color = switch (role) {
      MonoSurfaceRole.page => theme.colors.page,
      MonoSurfaceRole.card => theme.colors.card,
      MonoSurfaceRole.elevated => theme.colors.elevated,
    };
    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: color,
        borderRadius: resolvedRadius,
        boxShadow: theme.elevation.resolve(elevation),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// A surface drawn *on top of media*.
///
/// This was `MonoGlassSurface`. It never contained a `BackdropFilter` — it was
/// flat translucency all along — and with the glass tokens retired it now
/// reads from the mist-on-media pair, so overlay chrome sits in the same colour
/// family as the rest of the system instead of being generic white.
///
/// Unlike [MonoSurface] this one *does* carry a hairline: over arbitrary
/// photography a luminance step alone cannot be relied on to separate.
class MonoMediaChrome extends StatelessWidget {
  const MonoMediaChrome({
    super.key,
    required this.child,
    this.padding,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.mistFill,
        border: Border.all(color: theme.colors.mistLine),
        borderRadius: radius ?? BorderRadius.circular(theme.radii.lg),
      ),
      padding: padding ?? EdgeInsets.all(theme.spacing.md),
      child: child,
    );
  }
}

/// A flat modal ground.
///
/// Deliberately not blurred. Monokit's depth model separates by luminance and
/// the scrim is part of that — a backdrop blur is a different visual language,
/// and an expensive one.
class MonoScrim extends StatelessWidget {
  const MonoScrim({super.key, this.strong = false, this.child});

  final bool strong;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = MonokitTheme.of(context).colors;
    return ColoredBox(
      color: strong ? colors.scrimStrong : colors.scrim,
      child: child,
    );
  }
}
