import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'messaging_page.dart';

part 'messaging_route.g.dart';

@TypedGoRoute<MessagingRoute>(path: '/messaging', name: 'messaging')
class MessagingRoute extends GoRouteData with $MessagingRoute {
  const MessagingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const MessagingPage();
}
