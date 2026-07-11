// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foundations_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$foundationsRoute];

RouteBase get $foundationsRoute => GoRouteData.$route(
  path: '/foundations',
  name: 'foundations',
  factory: $FoundationsRoute._fromState,
);

mixin $FoundationsRoute on GoRouteData {
  static FoundationsRoute _fromState(GoRouterState state) =>
      const FoundationsRoute();

  @override
  String get location => GoRouteData.$location('/foundations');

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
