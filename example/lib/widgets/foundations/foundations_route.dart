import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'foundations_page.dart';

part 'foundations_route.g.dart';

@TypedGoRoute<FoundationsRoute>(path: '/foundations', name: 'foundations')
class FoundationsRoute extends GoRouteData with $FoundationsRoute {
  const FoundationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FoundationsPage();
}
