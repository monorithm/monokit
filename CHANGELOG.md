## 3.0.0

Focus handling had two halves and the system only ever shipped one. There were
ring tokens, a traversal policy and a focus trap — and nothing anywhere that
*dropped* text-input focus in response to a gesture. On a phone the software
keyboard could only be closed with its own Done key.

The framework is half the reason. `EditableText`'s default tap-outside action
deliberately ignores a touch tap on native Android/iOS; it only unfocuses on
desktop, on the web, or for a non-touch pointer. That is a considered default
rather than a bug, but it means the policy has to come from the design system,
and `MonoInput` never set `onTapOutside`. So it came from nowhere.

### Breaking

- **An open compact `MonoScreen` sidebar now makes the page inert.** It took
  taps, keyboard traversal and screen-reader focus with no scrim in front of it,
  so the sidebar only ever *looked* modal. The page is now excluded from
  semantics while it is open, which means its own sidebar trigger no longer
  appears in the tree or reports an expanded state. Hiding a disclosure control
  with nothing in its place would strand screen-reader users, so the dismiss
  barrier over the page is a labelled button instead — `MonokitLabels
  .closeSidebar`, "Close sidebar" by default. Any test asserting the trigger
  stays reachable while the sidebar is open needs updating.

### Added

- **`MonokitFocus.dismissKeyboardOnTapOutside`** (default `true`), the token
  that owns the behaviour. It lives beside the ring geometry on purpose: this
  group is the system's answer to "what does focus do", and for a long time it
  only answered "what does focus look like".
- **Per-field overrides** on `MonoInput`, `MonoTextarea` and `MonoInputOtp`, for
  the case the token cannot cover — a chat composer whose message list is
  tappable wants to survive taps on it. Setting `false` restores Flutter's
  platform default rather than inventing a third behaviour.
- **`MonoField.focusNode` and `MonoFieldLabel.focusNode`**, the `<label for>`
  equivalent. Tapping an associated label focuses its control and the label
  carries a semantics tap action. Opt-in, so existing labels are unchanged.
- **`MonoOverlayFocusController.restoreTextInputFocus`**, to opt back into
  full restoration on touch.

### Fixed

- **Tapping away drops the keyboard.** Dismissal lives on the field rather than
  on the screen: `EditableText`'s `TextFieldTapRegion` already computes
  "outside" with group semantics, so moving between two fields, or tapping a
  combobox panel, is correct for free. A screen-level handler would have had to
  reimplement that grouping and would still miss every field outside a
  `MonoScreen`. Scroll-to-dismiss falls out of the same change, since a drag
  opens with a pointer-down outside the region.
- **`MonoInput` advertised `textField: true` with no semantics action at all.**
  `TextSelectionGestureDetector` builds with `excludeFromSemantics: true`, so
  the pointer gestures contribute nothing, and there was no `Semantics.onTap` to
  make up for it — a VoiceOver or TalkBack double-tap on a Monokit field did
  nothing. Material's `TextField` compensates the same way.
- **The whole decorated field joins its tap region**, not just the
  `EditableText`'s own box. Clicking a field's own padding read as a tap
  *outside* it, which on desktop unfocused and then immediately refocused via
  the selection gestures — flickering the ring and tearing down the IME
  connection for nothing. The combobox and command-palette panels get the same
  treatment, so picking an option cannot drop the query field out from under a
  selection still in flight.
- **Closing an overlay no longer re-raises the keyboard.** Restoring focus is a
  keyboard-navigation contract and right on desktop; on touch it meant every
  sheet, drawer, menu and popover close threw the keyboard back up. Restoration
  into a text input is now declined on touch platforms — which needed saying
  twice, because the enclosing scope still remembers the field as its most
  recent focused child and replays that when the modal's own node is disposed.
- **`MonoDialog` and `MonoCommandPalette` restore focus on close.** Both trapped
  focus and then abandoned it, never having joined the shared controller.
- **`MonoDialog` now takes focus when it opens.** `MonoFocusTrap`'s autofocus is
  skipped when the enclosing scope already has a focused child — which is always
  the case for an `OverlayEntry` over a live page. Sheet and drawer have always
  worked around this with an explicit request; dialog had not, so Esc-to-dismiss
  only worked if you had tabbed into it first.

178 tests, up from 146. The new matrix is per-platform deliberately: every
mobile row in it is Monokit policy rather than framework behaviour, so nothing
but a test will notice if it regresses.

## 2.2.0

One fix. The badge was the last component whose status treatment disagreed with
the rest of the system.

No API changes — this is a pure visual correction, so unlike 2.1.0 the version
number means what it says.

### Fixed

- **Every semantic badge status is now a soft fill with its contrast-safe
  text.** `success`, `warning` and `info` were saturated fills on `onStatus`
  while `danger` alone used `dangerSoft`/`dangerText`, so a row of status badges
  came out half shouting and half whispering — with the quiet one being the
  alarm. `MonoAlert` has always used soft+text for all four, and the destructive
  button uses it too; the badge was the outlier, which is what makes this a
  defect rather than a preference.
- `live` deliberately stays solid. It is an attention signal rather than a
  status, and the loudness is the point. `neutral` was already a soft fill.

`onStatus` is now read only by `MonoBubble`. It is still live, but if that call
site ever changes the role should go with it.

## 2.1.0

The three things 2.0's plan specified and 2.0 shipped without. Small, but they
are the last places where the system contradicted its own stated rules.

> **Note on the version.** These are enum member removals, so by strict semver
> this is a major. It is tagged 2.1.0 deliberately: monokit has one consumer,
> which pins an exact tag, so nothing upgrades into the break unattended. Read
> the migration below before bumping the pin.

### Breaking

- **`MonoBadgeVariant` 8 → 6:** `{neutral, success, warning, danger, info, live}`.
  A badge reports state, so the ladder is the state vocabulary and nothing else.
  `primary`, `secondary` and `outline` were three ways to say "no particular
  status" — and `outline` drew a hairline border that the grouped surface model
  had already abolished. All three collapse into `neutral`; `destructive`
  renames to `danger`, matching the colour role it has resolved to since 2.0.
- **The default badge is now `neutral`, not `primary`.** An emerald-filled badge
  competed with the primary button for attention. Badges no longer solicit.
- **`MonoResolvedBadgeStyle.borderColor` is gone.** `outline` was its only
  setter, so after the trim it was permanently null.
- **`MonoTabsVariant {defaultStyle, line}` → `{line, segmented}`, and `line` is
  now the default.** `defaultStyle` was already documented as "a compact
  segmented control", so this names what it always was. The default changed
  because tabs usually sit on a card that is already the focus, where a filled
  strip is a second competing surface; `segmented` remains right when the choice
  itself is the content, as in a short filter row.

### Fixed

- **`MonoAccordion`'s panel height now springs.** It was the last spatial
  animation still on a curve — `AnimatedSize` with `Cubic(0.2, 0, 0, 1)` — which
  the 2.0 motion doctrine had ruled out and 2.0 then skipped. Height is now
  driven by `MonoSpringController` on the `spatial` spring. The ceiling on
  `heightFactor` is deliberately left open so the overshoot reads as momentum;
  only the floor is clamped, because `Align` asserts on a negative factor and a
  collapse undershoot is invisible anyway. Mounting an already-expanded item
  still adopts its resting state outright rather than animating open.

### Migration

```dart
MonoBadgeVariant.primary     → MonoBadgeVariant.neutral
MonoBadgeVariant.secondary   → MonoBadgeVariant.neutral
MonoBadgeVariant.outline     → MonoBadgeVariant.neutral
MonoBadgeVariant.destructive → MonoBadgeVariant.danger
MonoTabsVariant.defaultStyle → MonoTabsVariant.segmented
```

Tabs that relied on the old segmented default must now ask for it explicitly.

## 2.0.0

Monokit stops mirroring the shadcn `base-nova` web reference and becomes its own
system, built on four decisions: **springs** for anything spatial, **adaptive**
density, **grouped** surfaces, and **emerald on mist** with a lifted dark mode.

This is a hard break. There are no deprecation shims.

### Breaking

- **Colours: 52 fields → 35 semantic roles.** Named for their job, not a palette
  position. `background` → `page` (and its value changed: `#FFFFFF` → `#F1F3F3`),
  `mutedForeground` → `foregroundMuted`, `border`/`input` → `separator`,
  `popover` → `elevated`, `muted`/`secondary` → `fill`, `destructive*` →
  `danger*`, `mediaCanvas` → `canvas`, `liveForeground` → `onLive`,
  `glassFill`/`glassBorder` → `mistFill`/`mistLine`. Added `foregroundSubtle`,
  `tint`, `onStatus`. **Removed:** all eight `sidebar*`, `accent`/`accentForeground`
  (the reference already had `accent == primary`), `secondary*`, `popover*`,
  `input`, `overlayScrim`, and the per-status `*Foreground` family.
- **`tint` and `primary` are now separate roles.** `tint` colours interactive
  text and icons; `primary` fills solids. Identical in light, divergent in dark.
- **Dark no longer bottoms out at black.** `page` is `#161B1D`, `card` `#22292B`,
  `elevated` `#2E3639`. The media `canvas` is still true black in both modes.
- **`MonoElevationTier` → `MonoElevation {flat, raised, floating}`.** The old five
  tiers resolved to three distinct shadows; `shadowColor` is now theme-derived
  rather than a fixed near-black that was invisible in dark mode.
- **`MonokitDensityData` → `MonokitDensity`,** with `mode` nullable meaning
  *adaptive*. `touchTarget` 48 → 44.
- **`MonoButtonVariant` 6 → 5:** `{filled, tinted, secondary, ghost, destructive}`.
  `outline` is gone (a bordered button contradicts a borderless surface model);
  `link` folded into `ghost`, which now takes the tint.
- **`MonoButtonSize` 8 → 3** `{sm, md, lg}` plus an `iconOnly` flag.
- **`MonoPopoverPlacement`, `MonoTooltipPlacement` and `MonoHoverCardPlacement`**
  — three identical 12-member enums — collapsed into `MonoPlacement`.
- **`MonokitComponentThemes` 17 slots → 3** (`button`, `card`, `screen`), with a
  `copyWith`. Fourteen were never read by any widget.
- **`MonoGlassSurface` → `MonoMediaChrome`.** It never contained a
  `BackdropFilter`, so this is a rename more than a removal.
- **`MonoCard.showBorder` defaults to `false`,** and its `tier` enum plus
  deprecated `elevation` double collapse into one `elevation` field.

### Added

- **`MonoSpringController`** — velocity-preserving spring driver, with
  `monoProject`, `monoRubberBand` and `monoNearest`. The three spring tokens
  (`spatial`, `effect`, `celebrate`) previously had zero call sites.
- **Real gestures.** `MonoSheet` and `MonoDrawer` are draggable with velocity
  projection and rubber-band overdrag; `MonoScreen`'s compact sidebar has
  edge-swipe; `MonoGalleryViewer` gains drag-to-dismiss via `onDismiss`.
- **`MonokitScrollBehavior`**, installed by `MonokitApp` — bouncing overscroll
  on every platform. `WidgetsApp` provides none, so physics previously fell
  through to Flutter's platform default.
- **`MonokitThemeData.brightness`, `lerp`, and `MonoAnimatedTheme`** so a theme
  change cross-fades rather than snapping.
- **`MonoSurfaceRole`** and a `MonoSurface` that is now the one way a surface is
  drawn.

### Fixed

- **`MonokitThemeData.light() != MonokitThemeData.light()`.** `MonokitElevation`,
  `MonokitDensityData`, `MonokitBreakpoints` and `MonokitHaptics` had no
  `==`/`hashCode` while the theme compared them by field, so
  `MonokitTheme.updateShouldNotify` fired on every rebuild.
- **`MonokitColors.==` allocated two 51-entry maps per call,** on that same hot
  path. It is now a `listEquals` over one declared field list.
- **Two breakpoint ladders.** `MonoScreen` read `MonoScreenTheme`'s private copy
  while everything else read `theme.breakpoints`, so overriding one did nothing.
- **Reduced motion was honoured at 6 sites and bypassed at ~25.** All reads now
  route through `MonokitMotion`, enforced by a source test.
- **`MonoEmptyState` had no background** and relied on the page being white; under
  the grouped model it rendered mist-on-mist.
- **Shadows.** Ten hand-rolled `boxShadow` blocks consolidated into
  `elevation.resolve`, removing nine uses of a *spacing* token as a blur radius.
- **`MonoSheet` drew a drag handle it could not honour** — there was no drag
  gesture anywhere in the library.

## Unreleased

Balance the design tokens and components to the shadcn `base-nova` web reference.

### Changed
- **Tokens.** `accent`/`accentForeground` now the bold brand green
  (`#007A55`/`#006045` on `#ECFDF5`), matching the reference's `--accent == --primary`.
  Radius scale rebalanced to the reference multipliers (`sm 6`, `md 8`, `xl 14`) and
  extended with `xxl 18` / `xxxl 22` / `xxxxl 26`. `overlayScrim` lightened from ~60%
  to ~10% black. `MonokitFocus` gains a `ringAlpha` (0.5) and a `ringShadow()` helper,
  and defaults `ringWidth` to 3 — the single source of truth for every control's ring.
- **Focus rings.** Every control (input, textarea, select, combobox, input-otp,
  checkbox, radio, switch, button, nav) now draws the ring from `MonokitFocus`
  at the reference `ring/50` strength; input-like controls gained the previously
  missing invalid-state ring (`destructive/20`).
- **Accent application.** Only menu/select items paint the green accent (with an
  `accentForeground` follow-through on text/icons/description so nothing is
  dark-on-green); button/tab/accordion/command/navigation/pagination hovers were
  repointed to neutral `muted`, matching the reference.
- **Destructive.** Buttons and badges use the soft `destructiveSoft`/`destructiveText`
  tint instead of a solid fill.
- **Tooltip.** Inverted-neutral surface (`foreground`/`background`) instead of the brand color.
- **Overlays.** Popover/hover-card/dropdown/context-menu/select/dialog/command surfaces
  use a translucent `foreground/10` hairline instead of an opaque border; dialog/drawer/
  sheet/command scrims are `~10% black + 4px backdrop blur`.
- **Misc parity.** Input/select/button/otp radius `md → lg`; card radius `lg → xl` +
  hairline; alert radius `md → lg`; tabs list/trigger radii + active `shadow-sm` +
  neutral line indicator; progress track `8 → 4px`; spinner inherits `foreground`;
  switch unchecked track uses `input`; sidebar container uses `sidebar`/`sidebarBorder`;
  bubble `tinted` uses the soft `primarySoft`.
- **Polish.** Selected radio is now a filled primary circle with a
  `primaryForeground` dot (was a hollow ring); `kbd` drops its border/shadow and
  uses `mutedForeground` text; avatar border is a translucent hairline; empty state
  gains the reference's dashed rounded-xl frame and muted icon chip.
- Control sizes (touch targets) intentionally kept larger than the web reference.

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
