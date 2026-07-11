import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';
import 'overlays_state.dart';

/// Live documentation for modal, anchored, and contextual overlays.
class OverlaysPage extends StatefulWidget {
  const OverlaysPage({super.key});

  @override
  State<OverlaysPage> createState() => _OverlaysPageState();
}

class _OverlaysPageState extends State<OverlaysPage> {
  final OverlaysState _state = OverlaysState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaysScope(
      state: _state,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = OverlaysScope.of(context);
    final theme = MonokitTheme.of(context);
    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Overlays & menus',
          description:
              'Modal surfaces, anchored hints, and contextual actions. Every '
              'example below is interactive and uses the same Widgets-only '
              'overlay system as an application.',
        ),
        DocSection(
          name: 'Interaction guide',
          description:
              'Use the labelled controls below. Hover cards and tooltips open '
              'on hover or focus; the context menu opens on right-click or '
              'long press; Escape and outside presses dismiss eligible layers.',
          code: '''// Overlay roots provide their own gesture handling.
// Use a non-interactive visual in trigger:, or control open state externally.
MonoPopover(
  trigger: MonoPopoverTrigger(child: TriggerFace(label: 'Open')),
  child: MonoPopoverContent(child: Text('Details')),
)''',
          child: MonoAlert(
            variant: MonoAlertVariant.info,
            title: const Text('Try the live controls'),
            description: const Text(
              'The badge-shaped trigger faces are intentionally non-interactive '
              'widgets. Their surrounding Monokit overlay trigger owns the press.',
            ),
          ),
        ),
        const DocGroupTitle('Modal overlays'),
        DocSection(
          name:
              'MonoDialog · MonoDialogPortal · MonoDialogContent · MonoDialogHeader · MonoDialogFooter · MonoDialogClose',
          description:
              'A controlled dialog keeps a normal MonoButton outside the dialog '
              'trigger tree. MonoDialogPortal is a transparent composition slot '
              'for dialog content.',
          code:
              '''MonoButton(onPressed: () => setState(() => open = true), child: Text('Open'))
MonoDialog(
  open: open,
  onOpenChange: (value) => setState(() => open = value),
  child: MonoDialogPortal(
    child: MonoDialogContent(
      child: MonoDialogHeader(title: Text('Title')),
    ),
  ),
)''',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              MonoButton(
                onPressed: () => state.setDialogOpen(true),
                child: const Text('Open composed dialog'),
              ),
              MonoDialog(
                open: state.dialogOpen,
                onOpenChange: (value) => state.setDialogOpen(value),
                semanticLabel: 'Composed documentation dialog',
                child: MonoDialogPortal(
                  child: MonoDialogContent(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const MonoDialogHeader(
                          title: Text('Publish component changes?'),
                          description: Text(
                            'The portal, content, header, footer, and close slots '
                            'are all composed in this example.',
                          ),
                        ),
                        MonoDialogFooter(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: MonoDialogClose(
                              child: const _OverlayActionFace(
                                label: 'Close dialog',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoAlertDialog',
          description:
              'A compact, opinionated dialog surface that bundles title, '
              'description, content, and trailing action slots.',
          code: '''MonoDialog(
  open: alertOpen,
  onOpenChange: (value) => setState(() => alertOpen = value),
  child: MonoAlertDialog(
    title: const Text('Archive draft?'),
    actions: <Widget>[MonoButton(onPressed: close, child: Text('Cancel'))],
  ),
)''',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: <Widget>[
              MonoButton(
                variant: MonoButtonVariant.outline,
                onPressed: () => state.setAlertDialogOpen(true),
                child: const Text('Open alert dialog'),
              ),
              MonoDialog(
                open: state.alertDialogOpen,
                onOpenChange: (value) => state.setAlertDialogOpen(value),
                semanticLabel: 'Archive draft dialog',
                child: MonoAlertDialog(
                  title: const Text('Archive this draft?'),
                  description: const Text(
                    'The compact alert dialog supplies the familiar modal layout.',
                  ),
                  content: const MonoAlert(
                    variant: MonoAlertVariant.warning,
                    description: Text('Archived drafts remain recoverable.'),
                  ),
                  actions: <Widget>[
                    MonoButton(
                      variant: MonoButtonVariant.ghost,
                      onPressed: () => state.setAlertDialogOpen(false),
                      child: const Text('Cancel'),
                    ),
                    MonoButton(
                      variant: MonoButtonVariant.destructive,
                      onPressed: () {
                        state.setAlertDialogOpen(false);
                        state.recordAction(
                          'Archived the draft from MonoAlertDialog.',
                        );
                      },
                      child: const Text('Archive'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name:
              'MonoDrawer · MonoDrawerTrigger · MonoDrawerContent · MonoDrawerHeader · MonoDrawerFooter · MonoDrawerClose',
          description:
              'A side-modal drawer. MonoDrawerScope is installed automatically '
              'for the trigger and overlay content, allowing close controls to '
              'resolve their nearest drawer.',
          code: '''MonoDrawer(
  trigger: MonoDrawerTrigger(child: TriggerFace(label: 'Open drawer')),
  child: MonoDrawerContent(
    child: Column(children: <Widget>[
      MonoDrawerHeader(title: Text('Navigation')),
      MonoDrawerFooter(child: MonoDrawerClose(child: ActionFace(label: 'Close'))),
    ]),
  ),
)''',
          child: MonoDrawer(
            trigger: const MonoDrawerTrigger(
              child: _OverlayTriggerFace(label: 'Open side drawer'),
            ),
            semanticLabel: 'Documentation side drawer',
            child: MonoDrawerContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const MonoDrawerHeader(
                    title: Text('Drawer anatomy'),
                    description: Text(
                      'A modal edge panel with focus restoration and Escape dismissal.',
                    ),
                  ),
                  SizedBox(height: theme.spacing.lg),
                  const Text(
                    'The trigger face is presentation only; MonoDrawerTrigger owns interaction.',
                  ),
                  MonoDrawerFooter(
                    child: MonoDrawerClose(
                      child: const _OverlayActionFace(label: 'Close drawer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DocSection(
          name:
              'MonoSheet · MonoSheetTrigger · MonoSheetContent · MonoSheetHeader · MonoSheetFooter · MonoSheetClose',
          description:
              'A modal top or bottom sheet. MonoSheetScope provides open, close, '
              'and toggle actions to its composition slots.',
          code: '''MonoSheet(
  trigger: MonoSheetTrigger(child: TriggerFace(label: 'Open sheet')),
  child: MonoSheetContent(
    child: Column(children: <Widget>[
      MonoSheetHeader(title: Text('Filters')),
      MonoSheetFooter(child: MonoSheetClose(child: ActionFace(label: 'Done'))),
    ]),
  ),
)''',
          child: MonoSheet(
            trigger: const MonoSheetTrigger(
              child: _OverlayTriggerFace(label: 'Open bottom sheet'),
            ),
            semanticLabel: 'Documentation bottom sheet',
            child: MonoSheetContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const MonoSheetHeader(
                    title: Text('Sheet anatomy'),
                    description: Text(
                      'Bottom sheets provide a compact mobile-friendly modal surface.',
                    ),
                  ),
                  SizedBox(height: theme.spacing.lg),
                  const Text(
                    'Drag affordance, focus behavior, and dismissal are built in.',
                  ),
                  MonoSheetFooter(
                    child: MonoSheetClose(
                      child: const _OverlayActionFace(label: 'Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const DocGroupTitle('Anchored hints and contextual menus'),
        DocSection(
          name:
              'MonoPopover · MonoPopoverTrigger · MonoPopoverContent · MonoPopoverClose',
          description:
              'A keyboard-aware anchored surface. Unlike a centered dialog, a '
              'popover must keep a trigger in the tree to provide its anchor.',
          code: '''MonoPopover(
  trigger: MonoPopoverTrigger(child: TriggerFace(label: 'More')),
  child: MonoPopoverContent(
    child: MonoPopoverClose(child: ActionFace(label: 'Close')),
  ),
)''',
          child: MonoPopover(
            trigger: const MonoPopoverTrigger(
              child: _OverlayTriggerFace(label: 'Open popover'),
            ),
            semanticLabel: 'Documentation popover',
            child: MonoPopoverContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Anchored content'),
                  SizedBox(height: theme.spacing.xs),
                  Text(
                    'Click outside or press Escape to dismiss.',
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  SizedBox(height: theme.spacing.md),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: MonoPopoverClose(
                      child: const _OverlayActionFace(label: 'Close popover'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DocSection(
          name: 'MonoTooltip · MonoTooltipContent',
          description:
              'A lightweight, non-modal hint. MonoTooltip wraps its message or '
              'custom content in MonoTooltipContent automatically.',
          code: '''MonoTooltip(
  message: 'Copied to clipboard',
  content: const Text('Copied to clipboard'),
  child: TriggerFace(label: 'Hover or focus'),
)''',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoTooltip(
                message: 'Tooltips announce a concise plain-text message.',
                content: const Text(
                  'Custom tooltip content, styled by MonoTooltipContent.',
                ),
                child: MonoButton(
                  variant: MonoButtonVariant.outline,
                  onPressed: () {},
                  child: const Text('Hover, focus, or long press'),
                ),
              ),
              SizedBox(height: theme.spacing.md),
              const MonoTooltipContent(
                child: Text('MonoTooltipContent surface preview.'),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoHoverCard · MonoHoverCardContent',
          description:
              'A richer hover or long-press surface. Its content may include '
              'multiple widgets, unlike the concise tooltip message.',
          code: '''MonoHoverCard(
  child: TriggerFace(label: 'Hover card'),
  card: MonoHoverCardContent(child: Text('Rich supporting details')),
)''',
          child: MonoHoverCard(
            semanticLabel: 'Documentation hover card',
            card: MonoHoverCardContent(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hover card content',
                    style: theme.typography.titleMedium,
                  ),
                  SizedBox(height: theme.spacing.xs),
                  const Text(
                    'The card stays open while the pointer moves from its trigger to this surface.',
                  ),
                ],
              ),
            ),
            child: MonoButton(
              variant: MonoButtonVariant.outline,
              onPressed: () {},
              child: const Text('Hover, focus, or long press'),
            ),
          ),
        ),
        DocSection(
          name:
              'MonoContextMenu · MonoContextMenuContent · MonoContextMenuItem · MonoContextMenuSeparator',
          description:
              'A secondary-click and long-press menu. It supports item leading '
              'and trailing slots, destructive styling, automatic close-on-select, '
              'and Escape dismissal.',
          code: '''MonoContextMenu(
  child: const Text('Right-click me'),
  menu: MonoContextMenuContent(
    child: Column(children: <Widget>[
      MonoContextMenuItem(onPressed: rename, child: Text('Rename')),
      MonoContextMenuSeparator(),
      MonoContextMenuItem(destructive: true, onPressed: remove, child: Text('Delete')),
    ]),
  ),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                state.lastAction,
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              SizedBox(height: theme.spacing.sm),
              MonoContextMenu(
                semanticLabel: 'Documentation context menu target',
                menu: MonoContextMenuContent(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MonoContextMenuItem(
                        leading: const MonoIcon(MonoIcons.add),
                        trailing: MonoKbd.text('R'),
                        onPressed: () => state.recordAction('Rename selected.'),
                        child: const Text('Rename'),
                      ),
                      MonoContextMenuItem(
                        leading: const MonoIcon(MonoIcons.check),
                        onPressed: () =>
                            state.recordAction('Marked as reviewed.'),
                        child: const Text('Mark reviewed'),
                      ),
                      const MonoContextMenuSeparator(),
                      MonoContextMenuItem(
                        destructive: true,
                        leading: const MonoIcon(MonoIcons.close),
                        onPressed: () =>
                            state.recordAction('Deleted selected item.'),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
                child: MonoPressable(
                  onPressed: () {},
                  child: (context, states) => const _ContextTarget(),
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoDropdownMenu · MonoDropdownMenuItem',
          description:
              'An anchored, keyboard-accessible action menu. Its root supplies '
              'press and focus behavior, so the trigger face stays presentation-only.',
          code: '''MonoDropdownMenu<String>(
  trigger: TriggerFace(label: 'Actions'),
  items: <MonoDropdownMenuItem<String>>[
    MonoDropdownMenuItem.text(value: 'copy', label: 'Copy'),
  ],
  onSelected: (value) => handle(value),
)''',
          child: MonoDropdownMenu<String>(
            trigger: const _OverlayTriggerFace(label: 'Open action menu'),
            semanticLabel: 'Documentation action menu',
            onSelected: (value) =>
                state.recordAction('Dropdown selected: $value.'),
            items: <MonoDropdownMenuItem<String>>[
              MonoDropdownMenuItem.text(
                value: 'copy',
                label: 'Copy link',
                leading: const MonoIcon(MonoIcons.arrowRight),
                trailing: MonoKbd.text('C'),
              ),
              MonoDropdownMenuItem.text(
                value: 'duplicate',
                label: 'Duplicate',
                leading: const MonoIcon(MonoIcons.add),
              ),
              MonoDropdownMenuItem.text(
                value: 'archive',
                label: 'Archive',
                destructive: true,
                leading: const MonoIcon(MonoIcons.close),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoCommandPalette · MonoCommand',
          description:
              'A centered searchable command launcher. Commands expose ids, '
              'search keywords, descriptions, leading and trailing slots, and '
              'per-command or root selection callbacks.',
          code: '''MonoCommandPalette(
  trigger: TriggerFace(label: 'Open command palette'),
  commands: <MonoCommand>[
    MonoCommand.text(id: 'new', label: 'Create component', keywords: ['add']),
  ],
  onSelected: (command) => run(command.id),
)''',
          child: MonoCommandPalette(
            trigger: const _OverlayTriggerFace(label: 'Open command palette'),
            semanticLabel: 'Documentation command palette',
            onSelected: (command) =>
                state.recordAction('Command selected: ${command.id}.'),
            commands: <MonoCommand>[
              MonoCommand.text(
                id: 'create',
                label: 'Create component',
                description: const Text(
                  'Start from a documented component pattern.',
                ),
                leading: const MonoIcon(MonoIcons.add),
                trailing: MonoKbd.text('N'),
                keywords: const <String>['new', 'add', 'component'],
              ),
              MonoCommand.text(
                id: 'search',
                label: 'Search documentation',
                description: const Text('Jump to a component group.'),
                leading: const MonoIcon(MonoIcons.search),
                keywords: const <String>['find', 'docs'],
              ),
              MonoCommand.text(
                id: 'theme',
                label: 'Toggle theme',
                description: const Text(
                  'Switch between light and dark tokens.',
                ),
                leading: const MonoIcon(MonoIcons.sparkles),
                enabled: false,
              ),
            ],
          ),
        ),
        const DocSection(
          name: 'Automatic overlay scopes',
          description:
              'MonoDialogScope, MonoDrawerScope, MonoSheetScope, '
              'MonoPopoverScope, MonoHoverCardScope, and MonoContextMenuScope '
              'are installed by their owning overlay roots. Use each scope\'s '
              'of or maybeOf helper from a composition slot instead of '
              'instantiating a scope directly.',
          child: Text(
            'The close controls and overlay content above resolve their nearest '
            'scope automatically.',
          ),
        ),
      ],
    );
  }
}

/// A deliberately non-interactive trigger presentation.
///
/// Overlay roots wrap this widget in their own focus and pointer handling, so
/// using [MonoButton] here would create competing press recognizers.
class _OverlayTriggerFace extends StatelessWidget {
  const _OverlayTriggerFace({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(theme.radii.md),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.labelLarge.copyWith(
            color: theme.colors.secondaryForeground,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Visual content for a close action supplied by a Monokit overlay slot.
class _OverlayActionFace extends StatelessWidget {
  const _OverlayActionFace({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(theme.radii.md),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.primaryForeground,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// A non-interactive context-menu target with an obvious pointer affordance.
class _ContextTarget extends StatelessWidget {
  const _ContextTarget();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 260),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(theme.radii.md),
          border: Border.all(color: theme.colors.border),
        ),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Project Aurora', style: theme.typography.titleMedium),
              SizedBox(height: theme.spacing.xs),
              Text(
                'Right-click or long-press this target.',
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
