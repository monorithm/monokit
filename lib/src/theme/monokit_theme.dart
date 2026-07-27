import 'package:flutter/widgets.dart';

import 'monokit_theme_data.dart';

/// Makes [MonokitThemeData] available to descendants and overlays.
class MonokitTheme extends InheritedTheme {
  const MonokitTheme({super.key, required this.data, required super.child});

  final MonokitThemeData data;

  static MonokitThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<MonokitTheme>();
    assert(theme != null, 'No MonokitTheme found in context.');
    return theme!.data;
  }

  static MonokitThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonokitTheme>()?.data;
  }

  @override
  bool updateShouldNotify(MonokitTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return MonokitTheme(data: data, child: child);
  }
}

class _MonokitThemeDataTween extends Tween<MonokitThemeData> {
  // `end` is assigned by AnimatedWidgetBaseState's TweenVisitor, never passed
  // to the constructor, so it is deliberately not a parameter here.
  _MonokitThemeDataTween({super.begin});

  @override
  MonokitThemeData lerp(double t) => MonokitThemeData.lerp(begin!, end!, t);
}

/// [MonokitTheme], but changes to [data] cross-fade instead of snapping.
///
/// Swapping light for dark used to be a hard cut — there was no
/// `MonokitThemeData.lerp` at all, and the one `lerp` that existed
/// (`MonokitColors.lerp`) had no call sites.
///
/// This animates on a **curve**, not a spring, and that is deliberate: under
/// monokit's motion doctrine a spring drives anything that moves in space,
/// while a pure colour change eases. Nothing here moves.
class MonoAnimatedTheme extends ImplicitlyAnimatedWidget {
  const MonoAnimatedTheme({
    super.key,
    required this.data,
    required this.child,
    super.curve,
    super.duration = const Duration(milliseconds: 220),
    super.onEnd,
  });

  final MonokitThemeData data;
  final Widget child;

  @override
  AnimatedWidgetBaseState<MonoAnimatedTheme> createState() =>
      _MonoAnimatedThemeState();
}

class _MonoAnimatedThemeState
    extends AnimatedWidgetBaseState<MonoAnimatedTheme> {
  _MonokitThemeDataTween? _data;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _data =
        visitor(
              _data,
              widget.data,
              (dynamic value) =>
                  _MonokitThemeDataTween(begin: value as MonokitThemeData),
            )
            as _MonokitThemeDataTween?;
  }

  @override
  Widget build(BuildContext context) =>
      MonokitTheme(data: _data!.evaluate(animation), child: widget.child);
}
