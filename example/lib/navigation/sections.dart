import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

import '../widgets/widgets.dart';

/// Display metadata for a top-level documentation section, backed by its typed
/// route so navigation stays type-safe.
class NavSection {
  const NavSection({
    required this.route,
    required this.title,
    required this.navLabel,
    required this.icon,
    required this.description,
  });

  final GoRouteData route;

  /// Header / footer label.
  final String title;

  /// Compact label used in the expanded sidebar.
  final String navLabel;

  /// Glyph used in the collapsed sidebar rail.
  final MonoIconData icon;
  final String description;

  String get location => route.location;
}

/// The ordered sections rendered by the shell navigation and the overview map.
const List<NavSection> navSections = <NavSection>[
  NavSection(
    route: OverviewRoute(),
    title: 'Overview',
    navLabel: 'Overview',
    icon: MonoIcons.sparkles,
    description: 'Tokens, architecture, and getting started.',
  ),
  NavSection(
    route: FoundationsRoute(),
    title: 'Foundations',
    navLabel: 'Foundations',
    icon: MonoIconData('◈', semanticLabel: 'Foundations'),
    description: 'App shell, surfaces, icons, and loading states.',
  ),
  NavSection(
    route: FeedbackRoute(),
    title: 'Actions & feedback',
    navLabel: 'Feedback',
    icon: MonoIcons.add,
    description: 'Buttons, badges, alerts, progress, and toasts.',
  ),
  NavSection(
    route: FormsRoute(),
    title: 'Forms',
    navLabel: 'Forms',
    icon: MonoIcons.check,
    description: 'Inputs, selections, validation, and OTP.',
  ),
  NavSection(
    route: NavigationShowcaseRoute(),
    title: 'Navigation',
    navLabel: 'Navigation',
    icon: MonoIcons.arrowRight,
    description: 'Tabs, disclosure, links, menus, and command palette.',
  ),
  NavSection(
    route: OverlaysRoute(),
    title: 'Overlays',
    navLabel: 'Overlays',
    icon: MonoIcons.more,
    description: 'Dialogs, sheets, drawers, menus, and cards.',
  ),
  NavSection(
    route: MessagingRoute(),
    title: 'Messaging',
    navLabel: 'Messaging',
    icon: MonoIconData('◌', semanticLabel: 'Messaging'),
    description: 'Chat messages, bubbles, attachments, and scrolling.',
  ),
  NavSection(
    route: PrimitivesRoute(),
    title: 'Primitives',
    navLabel: 'Primitives',
    icon: MonoIconData('◇', semanticLabel: 'Primitives'),
    description: 'States, focus, pressables, overlays, and Material bridge.',
  ),
];
