// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forms_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$formsRoute];

RouteBase get $formsRoute => GoRouteData.$route(
  path: '/forms',
  name: 'forms',
  factory: $FormsRoute._fromState,
);

mixin $FormsRoute on GoRouteData {
  static FormsRoute _fromState(GoRouterState state) => const FormsRoute();

  @override
  String get location => GoRouteData.$location('/forms');

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
