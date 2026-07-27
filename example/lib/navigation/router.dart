import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

import '../container/gallery_shell.dart';
import '../scenarios/checkout_scenario.dart';
import '../scenarios/conversation_scenario.dart';
import '../scenarios/creator_studio_scenario.dart';
import '../scenarios/group_call_scenario.dart';
import '../scenarios/live_studio_scenario.dart';
import '../scenarios/order_tracking_scenario.dart';
import '../scenarios/scenarios_index.dart';
import '../scenarios/storefront_scenario.dart';
import '../scenarios/team_workspace_scenario.dart';
import '../sections/actions_page.dart';
import '../sections/chat_page.dart';
import '../sections/commerce_page.dart';
import '../sections/data_display_page.dart';
import '../sections/feedback_page.dart';
import '../sections/forms_page.dart';
import '../sections/decisions_page.dart';
import '../sections/foundations_page.dart';
import '../sections/media_page.dart';
import '../sections/navigation_page.dart';
import '../sections/overlays_page.dart';
import '../sections/overview_page.dart';
import '../sections/responsive_page.dart';

GoRoute _page(String path, Widget page) =>
    GoRoute(path: path, builder: (context, state) => page);

final GoRouter router = GoRouter(
  initialLocation: '/',
  // Matches MonokitApp.router(restorationScopeId: 'gallery') so the location is
  // restored across process death.
  restorationScopeId: 'gallery',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) => GalleryShell(child: child),
      routes: <RouteBase>[
        _page('/', const OverviewPage()),
        _page('/foundations', const FoundationsPage()),
        _page('/decisions', const DecisionsPage()),
        _page('/responsive', const ResponsivePage()),
        _page('/actions', const ActionsPage()),
        _page('/forms', const FormsPage()),
        _page('/overlays', const OverlaysPage()),
        _page('/navigation', const NavigationPage()),
        _page('/feedback', const FeedbackPage()),
        _page('/data-display', const DataDisplayPage()),
        _page('/chat', const ChatPage()),
        _page('/media', const MediaPage()),
        _page('/commerce', const CommercePage()),
        _page('/scenarios', const ScenariosIndexPage()),
        _page('/scenarios/storefront', const StorefrontScenario()),
        _page('/scenarios/checkout', const CheckoutScenario()),
        _page('/scenarios/order-tracking', const OrderTrackingScenario()),
        _page('/scenarios/conversation', const ConversationScenario()),
        _page('/scenarios/live-studio', const LiveStudioScenario()),
        _page('/scenarios/creator-studio', const CreatorStudioScenario()),
        _page('/scenarios/team-workspace', const TeamWorkspaceScenario()),
        _page('/scenarios/group-call', const GroupCallScenario()),
      ],
    ),
  ],
);
