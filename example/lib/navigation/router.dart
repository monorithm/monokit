import 'package:go_router/go_router.dart';

import '../container/docs_shell.dart';
import '../widgets/widgets.dart';

/// The application router.
///
/// A single [ShellRoute] keeps the [DocsShell] chrome (sidebar, header, footer)
/// mounted while only the body swaps as sections navigate. Each child is a
/// generated route tree from a feature's `@TypedGoRoute`.
final GoRouter router = GoRouter(
  initialLocation: const OverviewRoute().location,
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) =>
          DocsShell(location: state.matchedLocation, child: child),
      routes: <RouteBase>[
        $overviewRoute,
        $foundationsRoute,
        $feedbackRoute,
        $formsRoute,
        $navigationShowcaseRoute,
        $overlaysRoute,
        $messagingRoute,
        $primitivesRoute,
      ],
    ),
  ],
);
