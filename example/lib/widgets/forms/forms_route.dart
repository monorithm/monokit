import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'forms_page.dart';

part 'forms_route.g.dart';

@TypedGoRoute<FormsRoute>(path: '/forms', name: 'forms')
class FormsRoute extends GoRouteData with $FormsRoute {
  const FormsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FormsPage();
}
