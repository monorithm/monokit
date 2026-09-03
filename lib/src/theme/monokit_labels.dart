import 'package:flutter/foundation.dart';

/// Overridable vocabulary for the short semantic labels Monokit widgets expose
/// to screen readers (button names, region names, dismiss affordances).
///
/// Monokit is a widgets-only package with no localization tooling of its own;
/// this token group is the seam through which a consuming app supplies its own
/// translated strings. Components read `MonokitTheme.of(context).labels.close`
/// etc. and fall back to these English defaults when the app leaves a field
/// unset. Components that also expose an explicit `semanticLabel` parameter
/// keep it — the token is only the fallback.
@immutable
class MonokitLabels {
  const MonokitLabels({
    this.close = 'Close',
    this.active = 'Active',
    this.previous = 'Previous',
    this.next = 'Next',
    this.dismiss = 'Dismiss',
    this.loading = 'Loading',
    this.holding = 'Hold…',
    this.dialog = 'Dialog',
    this.closeDialog = 'Close dialog',
    this.sheet = 'Sheet',
    this.openSheet = 'Open sheet',
    this.closeSheet = 'Close sheet',
    this.drawer = 'Drawer',
    this.openDrawer = 'Open drawer',
    this.closeDrawer = 'Close drawer',
    this.closeSidebar = 'Close sidebar',
    this.togglePopover = 'Toggle popover',
    this.closePopover = 'Close popover',
    this.dismissPopover = 'Dismiss popover',
    this.dismissContextMenu = 'Dismiss context menu',
    this.menuItems = 'Menu items',
    this.openOptions = 'Open options',
    this.closeOptions = 'Close options',
    this.selectOptions = 'Select options',
    this.commandPalette = 'Command palette',
  });

  final String close;

  /// The label on a live/active badge. Sentence case, like every other badge.
  final String active;
  final String previous;
  final String next;
  final String dismiss;
  final String loading;

  /// Shown on a destructive swipe action while the finger is down. It replaces
  /// the action's own label for the duration of the hold, so the word says
  /// what is happening rather than a second progress element saying it.
  final String holding;
  final String dialog;
  final String closeDialog;
  final String sheet;
  final String openSheet;
  final String closeSheet;
  final String drawer;
  final String openDrawer;
  final String closeDrawer;

  /// Names the dismiss barrier over the page while a compact [MonoScreen]
  /// sidebar is open. The page's own toggle is concealed behind the sidebar at
  /// that point, so this is the labelled way back out.
  final String closeSidebar;
  final String togglePopover;
  final String closePopover;
  final String dismissPopover;
  final String dismissContextMenu;
  final String menuItems;
  final String openOptions;
  final String closeOptions;
  final String selectOptions;
  final String commandPalette;

  /// Name for the panel of the 1-based tab at [position].
  String tabPanel(int position) => 'Tab panel $position';

  MonokitLabels copyWith({
    String? close,
    String? previous,
    String? next,
    String? dismiss,
    String? loading,
    String? holding,
    String? dialog,
    String? closeDialog,
    String? sheet,
    String? openSheet,
    String? closeSheet,
    String? drawer,
    String? openDrawer,
    String? closeDrawer,
    String? closeSidebar,
    String? togglePopover,
    String? closePopover,
    String? dismissPopover,
    String? dismissContextMenu,
    String? menuItems,
    String? openOptions,
    String? closeOptions,
    String? selectOptions,
    String? commandPalette,
  }) {
    return MonokitLabels(
      close: close ?? this.close,
      previous: previous ?? this.previous,
      next: next ?? this.next,
      dismiss: dismiss ?? this.dismiss,
      loading: loading ?? this.loading,
      holding: holding ?? this.holding,
      dialog: dialog ?? this.dialog,
      closeDialog: closeDialog ?? this.closeDialog,
      sheet: sheet ?? this.sheet,
      openSheet: openSheet ?? this.openSheet,
      closeSheet: closeSheet ?? this.closeSheet,
      drawer: drawer ?? this.drawer,
      openDrawer: openDrawer ?? this.openDrawer,
      closeDrawer: closeDrawer ?? this.closeDrawer,
      closeSidebar: closeSidebar ?? this.closeSidebar,
      togglePopover: togglePopover ?? this.togglePopover,
      closePopover: closePopover ?? this.closePopover,
      dismissPopover: dismissPopover ?? this.dismissPopover,
      dismissContextMenu: dismissContextMenu ?? this.dismissContextMenu,
      menuItems: menuItems ?? this.menuItems,
      openOptions: openOptions ?? this.openOptions,
      closeOptions: closeOptions ?? this.closeOptions,
      selectOptions: selectOptions ?? this.selectOptions,
      commandPalette: commandPalette ?? this.commandPalette,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitLabels &&
      close == other.close &&
      previous == other.previous &&
      next == other.next &&
      dismiss == other.dismiss &&
      loading == other.loading &&
      dialog == other.dialog &&
      closeDialog == other.closeDialog &&
      sheet == other.sheet &&
      openSheet == other.openSheet &&
      closeSheet == other.closeSheet &&
      drawer == other.drawer &&
      openDrawer == other.openDrawer &&
      closeDrawer == other.closeDrawer &&
      closeSidebar == other.closeSidebar &&
      togglePopover == other.togglePopover &&
      closePopover == other.closePopover &&
      dismissPopover == other.dismissPopover &&
      dismissContextMenu == other.dismissContextMenu &&
      menuItems == other.menuItems &&
      openOptions == other.openOptions &&
      closeOptions == other.closeOptions &&
      selectOptions == other.selectOptions &&
      commandPalette == other.commandPalette;

  @override
  int get hashCode => Object.hashAll(<Object>[
    close,
    previous,
    next,
    dismiss,
    loading,
    dialog,
    closeDialog,
    sheet,
    openSheet,
    closeSheet,
    drawer,
    openDrawer,
    closeDrawer,
    closeSidebar,
    togglePopover,
    closePopover,
    dismissPopover,
    dismissContextMenu,
    menuItems,
    openOptions,
    closeOptions,
    selectOptions,
    commandPalette,
  ]);
}
