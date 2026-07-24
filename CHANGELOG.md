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
