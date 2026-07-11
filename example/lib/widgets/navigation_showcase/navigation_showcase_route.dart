import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'navigation_showcase_page.dart';

part 'navigation_showcase_route.g.dart';

@TypedGoRoute<NavigationShowcaseRoute>(path: '/navigation', name: 'navigation')
class NavigationShowcaseRoute extends GoRouteData
    with $NavigationShowcaseRoute {
  const NavigationShowcaseRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NavigationShowcasePage();
}
