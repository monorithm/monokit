## 0.10.0

Interaction-rebuild scoping, part 2 — the remaining stateful widgets.

### Performance
- Extends the 0.9.0 `ListenableBuilder` scoping to every widget that still
  rebuilt its whole subtree on each hover / press / focus tick:
  - **Toggles** (`MonoCheckbox`, `MonoSwitch`, `MonoRadio`): the empty
    `setState(() {})` states listener is gone; the visual and its
    `Semantics(focused:)` node build inside a `ListenableBuilder` on the
    states controller, so a pointer frame rebuilds only that leaf, not the
    `FocusableActionDetector` above it.
  - **Trigger widgets** (`MonoSelect`, `MonoCombobox`, `MonoDropdownMenu`,
    `MonoInput`): same treatment on the trigger/field. `MonoInput` passes its
    `EditableText` through as the builder's `child`, so hover/focus never
    rebuilds the text field — only the bordered container's decoration.
  - **Item collections** (`MonoTabs`, `MonoAccordion`): each trigger now scopes
    to its **own** per-item states controller, so hovering one tab/section
    rebuilds only that trigger — siblings and the (accordion) expandable
    content stay put.
- Open/close, selection, and keyboard-highlight `setState` calls are unchanged;
  only the interaction-tick rebuilds were scoped. Behavior is preserved
  (existing widget/semantics suites stay green).

### Performance
- `MonoPressable` now delivers hover / press / focus ticks to a
  `ListenableBuilder` wrapping only the state-consuming visual leaf, instead of
  calling `setState` on the whole widget. Its `Semantics` /
  `FocusableActionDetector` subtree no longer rebuilds on every pointer frame.
  This scopes the 14 widgets built on `MonoPressable` (attachment, bottom nav,
  breadcrumb, bubble, command palette, context menu, dialog, drawer, media,
  sidebar, navigation menu, pagination, popover, sheet).
- `MonoButton` bumps a `ValueNotifier` on state change rather than
  `setState`, and builds its style + contents + three nested implicit
  animations inside a `ListenableBuilder`, so the outer `Semantics` /
  `FocusableActionDetector` no longer reconstructs on hover.
- The remaining `setState`-per-tick widgets (checkbox, switch, radio, select,
  combobox, dropdown, input, tabs, accordion) can adopt the same pattern
  incrementally; their `Semantics(focused:)` entanglement wants per-widget care.

## 0.8.0

Input hardening.

- `MonoInput` / `MonoTextarea` gain a `restorationId`: with it set (and no
  external controller), the field's text and selection survive the app being
  killed and relaunched (via `RestorationMixin` +
  `RestorableTextEditingController`).
- Opt-in `showCounter` renders a `current/max` character counter when
  `maxLength` is set. The length is always exposed to screen readers
  (`maxValueLength`/`currentValueLength`) regardless of the visible counter.

## 0.7.0

Production-readiness pass, part 2 (P1/P2 hardening).

### Performance
- `RepaintBoundary` around all anchored-overlay content, so a menu's hover/
  highlight ticks no longer repaint the page behind it.

### API & keyboard
- `MonoSelect` gains `open` / `defaultOpen` / `onOpenChange`, matching the
  controlled-open contract of dropdown, combobox, and popover.
- `MonoCombobox` supports Home / End / Page Up / Page Down; the command palette
  supports Home / End (both were arrow-only).

### Diagnostics
- `debugFillProperties` on `MonoButton`, `MonoSelect`, `MonoInput`, and
  `MonoTabs`, so they expose their state in the Flutter DevTools inspector.

### Example
- Added `MonoCombobox` and `MonoNavigationMenu` gallery demos.

## 0.6.0

Production-readiness pass (audited against the Material reference).

### Overlays & layout
- Added `MonoAnchoredLayout` / `MonoAnchoredLayoutDelegate`, a viewport-aware
  `CustomSingleChildLayout` that replaces `CompositedTransformFollower` in
  select, dropdown, combobox, popover, context menu, tooltip, and hover card.
  Overlays now flip on their measured size, clamp to the safe area (padding +
  keyboard insets), and cap their height to the space actually available, so
  they can no longer render off-screen. Select and dropdown scroll the selected
  row into view on open.
- `MonoDialog` and `MonoSheet` now cap their height to the visible area, scroll
  overflowing content, and lift clear of the software keyboard.

### Text input
- `MonoInput` / `MonoTextarea` now have full text selection: engine-neutral
  drag handles (`MonoTextSelectionControls`), a token-styled cut/copy/paste/
  select-all toolbar (`monoContextMenuBuilder`), a `RawMagnifier` loupe, and the
  standard selection gestures. **Selection requires an `Overlay` ancestor**
  (as every `EditableText` does); `MonokitApp` provides one.

### Accessibility & feel
- Fixed-height controls (button, badge, bottom nav, input) grow with the OS
  text scale via `monoScaledExtent`, clamped at 2x, so labels no longer clip.
- `MonokitHaptics` is now actually invoked on activation (was a dead token,
  still disabled by default).
- Reduced-motion is honored by the dialog entrance and radio group; the
  accordion chevron mirrors in RTL; select and dropdown menus show a token
  `RawScrollbar` on desktop/web.
- A missing `Overlay` ancestor now asserts (was a silent no-op).

### Buttons
- Intrinsic-safe layout (removed the `Flexible` label wrapper) and the pressed
  state is cleared when a button is disabled mid-gesture.

## 0.5.0

### Accessibility — focus & semantics
- Added `MonoOverlayFocusController`, a shared capture-and-restore focus
  contract adopted by combobox, select, dropdown menu, context menu, hover
  card, popover, sheet, and drawer (replacing eight divergent per-widget
  implementations). Overlays now restore focus to whoever held it before
  opening, falling back to the trigger.
- Added `MonoFocusTrap` and applied it to the modal surfaces (dialog, sheet,
  drawer, command palette) so keyboard traversal wraps within the modal instead
  of escaping to the page behind it.
- Added `MonoHeading` and marked dialog, alert, card, sheet, drawer, and screen
  header titles as headings for screen-reader navigation.
- Added `MonoAnnouncer` (imperative screen-reader announcements) and announce
  page changes from `MonoPagination`.
- Tab triggers now report `inMutuallyExclusiveGroup`; `MonoScreen` assigns a
  reading order so the floating region is read after page content.
- Added the `MonokitFocus` theme token (focus-ring width/offset) and the
  overridable `MonokitLabels` vocabulary; component semantic labels now fall
  back to `MonokitTheme.of(context).labels`.

### Breaking
- Removed the `state/` command/honest-state vocabulary: `MonoCommandPhase`,
  `MonoAvailability`, `MonoPending`, `MonoReconcile`, `MonoOptimistic`, and the
  `MonoOrderStatus` commerce widget.
- Removed the opt-in `package:monokit/material.dart` Material interop layer.
- Renamed the internal `src/components/` directory to `src/widgets/` (no public
  import changes — everything is re-exported from `package:monokit/monokit.dart`).

## 0.4.0

- Added a `restorationScopeId` to `MonokitApp` and `MonokitApp.router`,
  forwarded to `WidgetsApp` / `WidgetsApp.router`. Setting it establishes the
  root restoration scope and the `Router`'s restoration id, so a declarative
  router (e.g. go_router with its own `restorationScopeId`) can restore the
  current location after the OS kills and relaunches a backgrounded app. Null
  by default, so existing apps are unaffected.

## 0.3.1

- Renamed `MonoIcons.user`'s semantic label from Profile to Account
  (Monorithm tab-5 terminology).

## 0.3.0

- Added `MonoBottomNav`, an icon-only bottom navigation primitive with
  per-item semantics (label, button, selected), token styling, and
  bottom-inset handling.
- Added `MonoIcons.user`.

## 0.2.0

- Migrated the theme to the canonical mist, emerald, status, media, glass,
  sidebar, elevation, density, breakpoint, haptic, and motion vocabulary.
- Added honest-state feedback, engine-neutral media and communication surfaces,
  and commerce components.
- Added shared logical placement and surface primitives while retaining the
  existing controlled overlay contracts.
- Deprecated numeric card elevation and legacy motion names.

## 0.1.0

- Introduce the widgets-first Monokit theme, app wrapper, state system, and page shell.
- Add foundational surfaces and feedback components: buttons, badges, cards, avatars, separators, skeletons, spinners, keyboard hints, alerts, progress, dialogs, and toasts.
- Add accessible form controls and navigation primitives including `EditableText` inputs, checkbox, radio group, switch, tabs, accordion, select, popover, tooltip, and dropdown menu.
- Add responsive sidebar, chat message, bubble, attachment, and message scroller components.
- Add an example gallery and opt-in Material theme adapter for hybrid apps.
