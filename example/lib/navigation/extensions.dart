import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navigation verbs supported by [NavigationX.navigate].
enum NavigationAction { go, push, pop, replace, refresh }

/// Typed navigation over the generated [GoRouteData] routes.
///
/// Mirrors the single action-dispatch helper used in monorithm-mobile so
/// call sites always pass a typed route object rather than a raw path string:
///
/// ```dart
/// context.navigate(const FormsRoute());
/// context.navigate(const FormsRoute(), action: NavigationAction.push);
/// ```
extension NavigationX on BuildContext {
  Future<dynamic> navigate<R extends GoRouteData, T extends Object?>(
    R route, {
    NavigationAction action = NavigationAction.go,
    T? result,
  }) async {
    final router = GoRouter.of(this);
    switch (action) {
      case NavigationAction.push:
        return router.push<T>(route.location);
      case NavigationAction.replace:
        router.replace(route.location);
      case NavigationAction.refresh:
        router.refresh();
      case NavigationAction.pop:
        router.pop<T>(result);
      case NavigationAction.go:
        router.go(route.location);
    }
    return null;
  }
}
