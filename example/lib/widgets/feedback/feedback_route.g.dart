// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_route.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$feedbackRoute];

RouteBase get $feedbackRoute => GoRouteData.$route(
  path: '/actions-feedback',
  name: 'feedback',
  factory: $FeedbackRoute._fromState,
);

mixin $FeedbackRoute on GoRouteData {
  static FeedbackRoute _fromState(GoRouterState state) => const FeedbackRoute();

  @override
  String get location => GoRouteData.$location('/actions-feedback');

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
