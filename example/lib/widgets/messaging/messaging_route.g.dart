// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$messagingRoute];

RouteBase get $messagingRoute => GoRouteData.$route(
  path: '/messaging',
  name: 'messaging',
  factory: $MessagingRoute._fromState,
);

mixin $MessagingRoute on GoRouteData {
  static MessagingRoute _fromState(GoRouterState state) =>
      const MessagingRoute();

  @override
  String get location => GoRouteData.$location('/messaging');

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
