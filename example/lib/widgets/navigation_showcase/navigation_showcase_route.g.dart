// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_showcase_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$navigationShowcaseRoute];

RouteBase get $navigationShowcaseRoute => GoRouteData.$route(
  path: '/navigation',
  name: 'navigation',
  factory: $NavigationShowcaseRoute._fromState,
);

mixin $NavigationShowcaseRoute on GoRouteData {
  static NavigationShowcaseRoute _fromState(GoRouterState state) =>
      const NavigationShowcaseRoute();

  @override
  String get location => GoRouteData.$location('/navigation');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
