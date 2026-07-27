import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class OverlaysPage extends StatelessWidget {
  const OverlaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Overlays',
          title: 'Layered surfaces',
          tagline:
              'Dialogs, sheets, drawers, popovers, tooltips, menus, and hover '
              'cards — viewport-aware, focus-trapping, and animated in and out.',
          child: const _OverlaysHero(),
        ),
        const SectionDivider(),
        MonoBanner(
          variant: MonoAlertVariant.info,
          child: const Text(
            'Every overlay animates in AND out (open one and close it), '
            'dismisses on outside-tap or Escape, and flips to stay on screen '
            '(collision-aware). Reduced-motion collapses to an instant swap.',
          ),
        ),
        SizedBox(height: theme.spacing.xl),
        ComponentSection(
          title: 'Dialog',
          widgetName: 'MonoDialog',
          description:
              'Modal decisions. Scales + fades in, and back out on '
              'close. Destructive actions live behind confirmation.',
          child: MonoDialog(
            trigger: MonoButton(
              variant: MonoButtonVariant.tinted,
              child: const Text('Delete post'),
            ),
            child: MonoDialogContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const MonoDialogHeader(
                    title: Text('Delete this post?'),
                    description: Text('This cannot be undone.'),
                  ),
                  SizedBox(height: theme.spacing.lg),
                  MonoDialogFooter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        MonoButton(
                          variant: MonoButtonVariant.tinted,
                          onPressed: () {},
                          child: const Text('Cancel'),
                        ),
                        SizedBox(width: theme.spacing.sm),
                        MonoButton(
                          variant: MonoButtonVariant.destructive,
                          onPressed: () {},
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Sheet',
          widgetName: 'MonoSheet',
          description:
              'Slides up from the bottom edge, and slides back down '
              'on close.',
          child: MonoSheet(
            trigger: MonoButton(
              variant: MonoButtonVariant.tinted,
              child: const Text('Open sheet'),
            ),
            child: MonoSheetContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const MonoSheetHeader(
                    title: Text('Filters'),
                    description: Text('Narrow your search.'),
                  ),
                  SizedBox(height: theme.spacing.md),
                  Text(
                    'Sheet body content.',
                    style: theme.typography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Drawer',
          widgetName: 'MonoDrawer',
          description: 'Slides in from the side, and back out on close.',
          child: MonoDrawer(
            trigger: MonoButton(
              variant: MonoButtonVariant.tinted,
              child: const Text('Open drawer'),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Navigation', style: theme.typography.titleMedium),
                  SizedBox(height: theme.spacing.sm),
                  Text(
                    'Drawer body content.',
                    style: theme.typography.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Popover',
          widgetName: 'MonoPopover',
          description: 'Anchored, non-modal. Fades + scales from the trigger.',
          child: MonoPopover(
            trigger: MonoButton(
              variant: MonoButtonVariant.tinted,
              child: const Text('Show details'),
            ),
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: SizedBox(
                width: 220,
                child: Text(
                  'Anchored content that animates in and out.',
                  style: theme.typography.bodyMedium,
                ),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Collision-aware placement',
          widgetName: 'MonoPlacement.resolveWithin',
          description:
              'This popover prefers to open toward the right — but it '
              'sits at the right edge, so it flips left to stay on screen. '
              '(Selects and dropdowns flip up near the bottom the same way.)',
          child: Align(
            alignment: Alignment.centerRight,
            child: MonoPopover(
              placement: MonoPlacement.rightStart,
              trigger: MonoButton(
                variant: MonoButtonVariant.secondary,
                trailing: const MonoIcon(MonoIcons.chevronRight, size: 14),
                child: const Text('Opens toward the edge'),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: SizedBox(
                  width: 240,
                  child: Text(
                    'Preferred side was the right; it flipped left because '
                    'there was no room.',
                    style: theme.typography.bodyMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Tooltip',
          widgetName: 'MonoTooltip',
          description: 'Hover or focus the button. Flips side near an edge.',
          child: MonoTooltip(
            message: 'Reaches people near Nima',
            child: MonoButton(
              variant: MonoButtonVariant.ghost,
              size: MonoButtonSize.md,
              iconOnly: true,
              onPressed: () {},
              child: const MonoIcon(MonoIcons.location),
            ),
          ),
        ),
        ComponentSection(
          title: 'Hover card',
          widgetName: 'MonoHoverCard',
          description: 'Hover the name to reveal a rich card.',
          child: MonoHoverCard(
            card: MonoHoverCardContent(
              child: SizedBox(
                width: 240,
                child: Row(
                  children: <Widget>[
                    const MonoAvatar(initials: 'AB'),
                    SizedBox(width: theme.spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Abbas Mohammed',
                            style: theme.typography.titleMedium,
                          ),
                          Text(
                            '12 active posts · Nima',
                            style: theme.typography.labelMedium.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            child: Text(
              '@abbas',
              style: theme.typography.bodyMedium.copyWith(
                color: theme.colors.primary,
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Context menu',
          widgetName: 'MonoContextMenu',
          description: 'Right-click (or long-press) the area.',
          child: MonoContextMenu(
            menu: MonoContextMenuContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Share', style: theme.typography.bodyMedium),
                  SizedBox(height: theme.spacing.sm),
                  Text('Save', style: theme.typography.bodyMedium),
                  SizedBox(height: theme.spacing.sm),
                  Text(
                    'Report',
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.colors.dangerText,
                    ),
                  ),
                ],
              ),
            ),
            child: Container(
              width: 220,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colors.fill,
                borderRadius: BorderRadius.circular(theme.radii.md),
                border: Border.all(color: theme.colors.separator),
              ),
              child: Text(
                'Right-click me',
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Dropdown menu',
          widgetName: 'MonoDropdownMenu',
          description:
              'Fades in/out and flips up when it would overflow below.',
          child: MonoDropdownMenu<String>(
            trigger: MonoButton(
              variant: MonoButtonVariant.tinted,
              trailing: const MonoIcon(MonoIcons.chevronDown, size: 14),
              child: const Text('Actions'),
            ),
            items: <MonoDropdownMenuItem<String>>[
              MonoDropdownMenuItem<String>(
                value: 'share',
                label: const Text('Share'),
                leading: const MonoIcon(MonoIcons.send, size: 16),
              ),
              MonoDropdownMenuItem<String>(
                value: 'save',
                label: const Text('Save'),
                leading: const MonoIcon(MonoIcons.bookmark, size: 16),
              ),
              MonoDropdownMenuItem<String>(
                value: 'report',
                label: const Text('Report'),
                destructive: true,
              ),
            ],
            onSelected: (_) {},
          ),
        ),
      ],
    );
  }
}

/// A composed row-actions surface for the hero.
class _OverlaysHero extends StatelessWidget {
  const _OverlaysHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Manage listing', style: theme.typography.titleMedium),
        SizedBox(height: theme.spacing.lg),
        Wrap(
          spacing: theme.spacing.sm,
          runSpacing: theme.spacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            IntrinsicWidth(
              child: MonoButton(
                onPressed: () {},
                leading: const MonoIcon(MonoIcons.send, size: 16),
                child: const Text('Share'),
              ),
            ),
            IntrinsicWidth(
              child: MonoTooltip(
                message: 'Save for later',
                child: MonoButton(
                  variant: MonoButtonVariant.tinted,
                  size: MonoButtonSize.md,
                  iconOnly: true,
                  onPressed: () {},
                  child: const MonoIcon(MonoIcons.bookmark),
                ),
              ),
            ),
            // MonoDropdownMenu sizes its menu to the trigger's width, so a tiny
            // icon trigger near the screen edge collapses the menu to a sliver.
            // A labelled, intrinsic-width trigger keeps the menu readable.
            IntrinsicWidth(
              child: MonoDropdownMenu<String>(
                onSelected: (_) {},
                items: <MonoDropdownMenuItem<String>>[
                  MonoDropdownMenuItem<String>(
                    value: 'edit',
                    label: const Text('Edit'),
                  ),
                  MonoDropdownMenuItem<String>(
                    value: 'archive',
                    label: const Text('Archive'),
                  ),
                ],
                trigger: MonoButton(
                  variant: MonoButtonVariant.tinted,
                  size: MonoButtonSize.sm,
                  trailing: const MonoIcon(MonoIcons.chevronDown, size: 14),
                  child: const Text('More'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
