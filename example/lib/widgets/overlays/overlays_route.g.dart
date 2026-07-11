// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlays_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$overlaysRoute];

RouteBase get $overlaysRoute => GoRouteData.$route(
  path: '/overlays',
  name: 'overlays',
  factory: $OverlaysRoute._fromState,
);

mixin $OverlaysRoute on GoRouteData {
  static OverlaysRoute _fromState(GoRouterState state) => const OverlaysRoute();

  @override
  String get location => GoRouteData.$location('/overlays');

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
