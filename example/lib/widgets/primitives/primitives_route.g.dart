// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'primitives_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$primitivesRoute];

RouteBase get $primitivesRoute => GoRouteData.$route(
  path: '/primitives',
  name: 'primitives',
  factory: $PrimitivesRoute._fromState,
);

mixin $PrimitivesRoute on GoRouteData {
  static PrimitivesRoute _fromState(GoRouterState state) =>
      const PrimitivesRoute();

  @override
  String get location => GoRouteData.$location('/primitives');

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
