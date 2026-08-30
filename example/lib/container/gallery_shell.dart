import 'package:go_router/go_router.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '../kit/responsive/device_canvas.dart';
import '../kit/responsive/viewport_controller.dart';
import '../navigation/sections.dart';
import 'app_scope.dart';

/// The persistent gallery chrome: on wide viewports a pinned Monokit sidebar; on
/// compact viewports a modal [MonoDrawer] (scrim, rounded panel, focus trap)
/// opened from the header. Plus a command-palette search, device switcher, and
/// theme toggle, with the routed page as the body.
class GalleryShell extends StatelessWidget {
  const GalleryShell({super.key, required this.child});

  final Widget child;

  GallerySection get _fallback => gallerySections.first;

  GallerySection _activeSection(String location) {
    final path = location.startsWith('/scenarios') ? '/scenarios' : location;
    for (final section in gallerySections) {
      if (section.path == path) return section;
    }
    return _fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final location = GoRouterState.of(context).matchedLocation;
    final active = _activeSection(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Below the compact breakpoint the sidebar becomes a modal drawer; at or
        // above it, MonoScreen pins the sidebar.
        final compact = constraints.maxWidth < theme.breakpoints.compact;
        return MonoScreen(
          sidebar: compact
              ? null
              : MonoSidebar(
                  header: _SidebarHeader(),
                  child: _NavList(activePath: active.path),
                ),
          header: _GalleryHeader(active: active, compact: compact),
          body: DeviceCanvas(child: child),
        );
      },
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({required this.active, required this.compact});

  final GallerySection active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        child: Row(
          children: <Widget>[
            if (compact) ...<Widget>[
              MonoDrawer(
                side: MonoDrawerSide.start,
                width: 288,
                semanticLabel: 'Navigation',
                trigger: MonoButton(
                  variant: MonoButtonVariant.ghost,
                  size: MonoButtonSize.sm,
                  iconOnly: true,
                  semanticLabel: 'Open navigation',
                  child: const MonoIcon(MonoIcons.menu),
                ),
                child: _DrawerNav(activePath: active.path),
              ),
              SizedBox(width: theme.spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(active.title, style: theme.typography.titleMedium),
                  Text(
                    active.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            const _ViewportSwitcher(),
            const _SearchButton(),
            SizedBox(width: theme.spacing.sm),
            const _ThemeToggle(),
          ],
        ),
      ),
    );
  }
}

/// The nav content inside the compact [MonoDrawer]: the branded header plus the
/// scrollable section list.
class _DrawerNav extends StatelessWidget {
  const _DrawerNav({required this.activePath});
  final String activePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SidebarHeader(),
        Expanded(child: _NavList(activePath: activePath)),
      ],
    );
  }
}

/// The global device switcher: pins the routed page to a framed viewport (or
/// `Fluid` to let the real window drive layout). Hidden on compact headers,
/// where there's no room and the window is already phone-sized.
class _ViewportSwitcher extends StatelessWidget {
  const _ViewportSwitcher();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    if (MonoScreenScope.of(context).isCompact) return const SizedBox.shrink();
    final controller = AppScope.viewportOf(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.only(right: theme.spacing.sm),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: BorderRadius.circular(theme.radii.md),
              border: Border.all(color: theme.colors.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.xs / 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (final mode in ViewportMode.values)
                    IntrinsicWidth(
                      child: MonoButton(
                        variant: controller.mode == mode
                            ? MonoButtonVariant.secondary
                            : MonoButtonVariant.ghost,
                        size: MonoButtonSize.sm,
                        semanticLabel: '${mode.label} viewport',
                        onPressed: () => controller.set(mode),
                        child: Text(mode.label),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    // Inset below the status bar / Dynamic Island when shown at the screen edge
    // (compact drawer). On a pinned sidebar the top inset is 0.
    final topInset = MediaQuery.of(context).padding.top;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rail = constraints.maxWidth < 140;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            theme.spacing.md,
            theme.spacing.md + topInset,
            theme.spacing.md,
            theme.spacing.md,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.colors.primary,
                  borderRadius: BorderRadius.circular(theme.radii.sm),
                ),
                child: MonoIcon(
                  MonoIcons.sparkles,
                  size: 16,
                  color: theme.colors.primaryForeground,
                ),
              ),
              if (!rail) ...<Widget>[
                SizedBox(width: theme.spacing.sm),
                Text('Monokit', style: theme.typography.titleMedium),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NavList extends StatelessWidget {
  const _NavList({required this.activePath});
  final String activePath;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final rail = constraints.maxWidth < 140;
        final groups = <String>[];
        for (final s in gallerySections) {
          if (!groups.contains(s.group)) groups.add(s.group);
        }
        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: rail ? theme.spacing.xs : theme.spacing.sm,
            vertical: theme.spacing.sm,
          ),
          children: <Widget>[
            for (final group in groups) ...<Widget>[
              if (!rail)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    theme.spacing.sm,
                    theme.spacing.md,
                    theme.spacing.sm,
                    theme.spacing.xs,
                  ),
                  child: Text(
                    group.toUpperCase(),
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              for (final s in gallerySections.where((s) => s.group == group))
                _NavItem(section: s, active: s.path == activePath, rail: rail),
            ],
          ],
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.active,
    required this.rail,
  });

  final GallerySection section;
  final bool active;
  final bool rail;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs / 2),
      child: MonoButton(
        variant: active ? MonoButtonVariant.secondary : MonoButtonVariant.ghost,
        size: MonoButtonSize.sm,
        semanticLabel: section.title,
        onPressed: () {
          // Close the drawer when navigating from the compact modal nav; a
          // no-op when the sidebar is pinned (no enclosing drawer).
          MonoDrawer.maybeOf(context)?.close();
          context.go(section.path);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: rail
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            MonoIcon(section.icon, size: 16),
            if (!rail) ...<Widget>[
              SizedBox(width: theme.spacing.sm),
              Text(section.navLabel),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return MonoCommandPalette(
      trigger: MonoButton(
        // Ghost + a full-size glyph so it reads as a balanced icon action rather
        // than a large, near-empty outlined box on touch (where the tap target
        // clamps to 48).
        variant: MonoButtonVariant.ghost,
        size: MonoButtonSize.md,
        iconOnly: true,
        semanticLabel: 'Search sections',
        child: const MonoIcon(MonoIcons.search, size: 20),
      ),
      placeholder: 'Jump to a section…',
      commands: <MonoCommand>[
        for (final s in gallerySections)
          MonoCommand(
            id: s.path,
            label: Text(s.title),
            description: Text(s.description),
            leading: MonoIcon(s.icon, size: 16),
            onSelected: () => context.go(s.path),
          ),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return MonoButton(
      variant: MonoButtonVariant.ghost,
      size: MonoButtonSize.sm,
      onPressed: controller.toggle,
      leading: MonoIcon(
        controller.isDark ? MonoIcons.sparkles : MonoIcons.star,
        size: 16,
      ),
      child: Text(controller.isDark ? 'Dark' : 'Light'),
    );
  }
}
