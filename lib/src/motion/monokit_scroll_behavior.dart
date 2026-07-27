import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// The scroll opinion monokit installs at the root.
///
/// [MonokitApp] builds on [WidgetsApp], which — unlike `MaterialApp` and
/// `CupertinoApp` — provides no `ScrollBehavior`. Monokit previously installed
/// none either, so physics fell through to Flutter's platform-conditional
/// default and the system had no opinion at all: bouncy on iOS, clamping with a
/// glow on Android, and inconsistent between the two for the same widget.
///
/// Monokit picks one: **rubber-band everywhere, no glow**. Overscroll is part
/// of the motion doctrine — it is the same "attached to your finger" feel that
/// [monoRubberBand] gives sheets — and it should not change identity per
/// platform.
///
/// Dragging with a mouse and a trackpad is enabled so the behaviour is
/// inspectable on desktop and in the gallery's web build.
class MonokitScrollBehavior extends ScrollBehavior {
  const MonokitScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

  /// The bounce *is* the indicator.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };
}
