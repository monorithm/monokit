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
