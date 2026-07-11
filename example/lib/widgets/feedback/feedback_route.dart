import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'feedback_page.dart';

part 'feedback_route.g.dart';

@TypedGoRoute<FeedbackRoute>(path: '/actions-feedback', name: 'feedback')
class FeedbackRoute extends GoRouteData with $FeedbackRoute {
  const FeedbackRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FeedbackPage();
}
