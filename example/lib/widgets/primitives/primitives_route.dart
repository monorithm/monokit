import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'primitives_page.dart';

part 'primitives_route.g.dart';

@TypedGoRoute<PrimitivesRoute>(path: '/primitives', name: 'primitives')
class PrimitivesRoute extends GoRouteData with $PrimitivesRoute {
  const PrimitivesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const PrimitivesPage();
}
