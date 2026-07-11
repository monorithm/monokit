import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'overlays_page.dart';

part 'overlays_route.g.dart';

@TypedGoRoute<OverlaysRoute>(path: '/overlays', name: 'overlays')
class OverlaysRoute extends GoRouteData with $OverlaysRoute {
  const OverlaysRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OverlaysPage();
}
