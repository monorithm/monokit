import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

import '../navigation/sections.dart';
import 'app_scope.dart';

/// The persistent gallery chrome: a responsive Monokit sidebar of sections, a
/// header with a working command-palette search and a theme toggle, and the
/// routed page as the body.
class GalleryShell extends StatelessWidget {
  const GalleryShell({super.key, required this.child});

  final Widget child;

  GallerySection get _fallback => gallerySections.first;

  GallerySection _activeSection(String location) {
    final path = location.startsWith('/blocks') ? '/blocks' : location;
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

    return MonoScreen(
      sidebar: MonoSidebar(
        header: _SidebarHeader(),
        child: _NavList(activePath: active.path),
      ),
      header: DecoratedBox(
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
              Builder(
                builder: (context) => MonoButton(
                  variant: MonoButtonVariant.ghost,
                  size: MonoButtonSize.iconSm,
                  semanticLabel: 'Toggle navigation',
                  onPressed: () =>
                      MonoScreen.of(context).sidebarController.toggle(),
                  child: const MonoIcon(MonoIcons.menu),
                ),
              ),
              SizedBox(width: theme.spacing.sm),
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
              const _SearchButton(),
              SizedBox(width: theme.spacing.sm),
              const _ThemeToggle(),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final rail = constraints.maxWidth < 140;
        return Padding(
          padding: EdgeInsets.all(theme.spacing.md),
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
          MonoScreen.of(context).sidebarController.close();
          context.go(section.path);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              rail ? MainAxisAlignment.center : MainAxisAlignment.start,
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
        variant: MonoButtonVariant.outline,
        size: MonoButtonSize.iconSm,
        semanticLabel: 'Search sections',
        child: const MonoIcon(MonoIcons.search),
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
