import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'overview_page.dart';

part 'overview_route.g.dart';

@TypedGoRoute<OverviewRoute>(path: '/', name: 'overview')
class OverviewRoute extends GoRouteData with $OverviewRoute {
  const OverviewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OverviewPage();
}
