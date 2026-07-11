import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../navigation/navigation.dart';
import 'app_scope.dart';

/// The shared responsive shell for every documentation route.
///
/// Mounted once by the router's [ShellRoute]; only [child] and [location]
/// change as sections navigate, so the sidebar, header, and footer stay put.
class DocsShell extends StatefulWidget {
  const DocsShell({super.key, required this.location, required this.child});

  /// The active route location, from `GoRouterState.matchedLocation`.
  final String location;

  /// The routed page for the active section.
  final Widget child;

  @override
  State<DocsShell> createState() => _DocsShellState();
}

class _DocsShellState extends State<DocsShell> {
  late final MonoSidebarController _sidebarController;

  @override
  void initState() {
    super.initState();
    _sidebarController = MonoSidebarController();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _navigate(String location) {
    _sidebarController.close();
    if (location != widget.location) {
      context.go(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final appTheme = AppScope.of(context);
    final location = widget.location;
    final active = navSections.firstWhere(
      (section) => section.location == location,
      orElse: () => navSections.first,
    );
    return MonoScreen(
      sidebarController: _sidebarController,
      sidebar: Builder(
        builder: (context) {
          final isRail =
              MonoScreen.maybeOf(context)?.sidebarReveal ==
              MonoSidebarReveal.rail;
          return MonoSidebar(
            controller: _sidebarController,
            padding: isRail
                ? EdgeInsets.symmetric(
                    horizontal: theme.spacing.xs,
                    vertical: theme.spacing.md,
                  )
                : null,
            header: Padding(
              padding: EdgeInsets.all(theme.spacing.sm),
              child: isRail
                  ? const Center(child: MonoIcon(MonoIcons.sparkles))
                  : Text('Monokit docs', style: theme.typography.titleLarge),
            ),
            footer: isRail
                ? null
                : Text(
                    'Every card below is an interactive widget example.',
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
            child: MonoNavigationMenu(
              value: location,
              orientation: MonoNavigationMenuOrientation.vertical,
              variant: MonoNavigationMenuVariant.pill,
              onChanged: _navigate,
              items: navSections
                  .map(
                    (section) => MonoNavigationMenuItem(
                      value: section.location,
                      semanticLabel: section.title,
                      child: isRail
                          ? ExcludeSemantics(child: MonoIcon(section.icon))
                          : Text(section.navLabel),
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        },
      ),
      header: MonoScreenHeader(
        leading: MonoSidebarTrigger(
          controller: _sidebarController,
          child: const MonoIcon(MonoIcons.menu),
        ),
        title: Text(active.title),
        trailing: MonoButton(
          size: MonoButtonSize.sm,
          variant: MonoButtonVariant.ghost,
          onPressed: appTheme.toggle,
          child: Text(appTheme.isDark ? 'Light theme' : 'Dark theme'),
        ),
      ),
      footer: MonoScreenFooter(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              for (final section in navSections) ...<Widget>[
                MonoButton(
                  size: MonoButtonSize.xs,
                  variant: section.location == location
                      ? MonoButtonVariant.primary
                      : MonoButtonVariant.ghost,
                  onPressed: () => _navigate(section.location),
                  child: Text(section.title),
                ),
                SizedBox(width: theme.spacing.xs),
              ],
            ],
          ),
        ),
      ),
      scrollBody: false,
      body: widget.child,
    );
  }
}
