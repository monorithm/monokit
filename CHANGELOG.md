# Changelog

All notable changes to monokit are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project
follows [semantic versioning](https://semver.org/spec/v2.0.0.html).

3.0.0 is the first version published to pub.dev. Everything below it was
released privately, and is kept here because what changed in those versions is
still the history of this API.

## 4.1.0

Two components brought back into line with what the design actually draws, and
the tests that should have been holding them there.

The larger half is the text field. An audit against the Monorithm Atlas found
the input rendering as the exact inverse of its own specification: the contract
opens with *"A well rather than a bordered box. The field recedes and the value
the user typed is what reads"*, and the widget shipped a bordered box with a
transparent fill, a 14px value at regular weight, and a 40px height on a touch
product whose own `minTarget` token is 44. Seven measured differences, none of
which any test was watching, because every test asserted colours and none
asserted shape.

### Changed

- **A text field is a well now, not a bordered box.** `MonoInput`,
  `MonoInputOtp`, `MonoSelect` and `MonoCombobox` render as a filled recess at
  `muted` with no border in any state, radius `xl` (14, was `lg`/10). The four
  read their look from one new `MonoFieldSkin` rather than from four copies of
  the same decoration - which is how they drifted from the design together and
  then from each other.

- **Field height resolves from density instead of `spacing.huge`.** The new
  `MonoInputSize` picks one of three steps: `small` = `controlHeight` (44/36),
  `medium` = `row1` (48/40), `large` = `controlHeightLarge` (56/48). Every step
  clears the minimum touch target; the old fixed 40 did not.

  **This is a visible change to every field**, and the default (`medium`, 48)
  is 8px taller than what shipped in 4.0.0. Pass `size:` to choose another step.

- **The value the user typed is set loud.** 20/600 at `large`, 14/500 below it,
  where all four controls previously used `bodyMedium` (14/400). A placeholder
  is the same style one weight lighter in `mutedForeground`, so it reads as
  absent text rather than as a short value. `tabularFigures: true` opts a field
  into fixed-advance digits; the OTP takes them always.

- **The focus ring is a real outline, offset from the control.** `ringWidth`
  3 -> 2, `ringAlpha` 0.5 -> 1.0, `ringOffset` 2 -> 3, and `colors.ring` moves
  to `#A9B4B7` / `#5A686C`. This is a **system-wide** change: every focusable
  control wears this ring, not only fields.

  `ringOffset` had never been applied to anything. It could not be: the ring
  was a `BoxShadow`, and a shadow's spread starts at the border box, so the gap
  the design specifies was unrepresentable and the ring read as a thicker
  border. The new `MonoFocusRingOverlay` paints it outside the bounds, taking
  no part in layout - a field no longer grows when it takes focus, so its
  siblings stop shifting as the user tabs through.

- **Invalid wears the ring without focus**, in `destructive`. An error found on
  submit is now visible on a field nobody is standing in.

- **`MonoField` carries a pending affordance**, which its contract has always
  required and it has never had. It reports the wait in the message slot as a
  live region and leaves the control at full strength - a field that greys out
  while a network call runs reads as "you may not edit this", which is the
  opposite of what is true.


- **A selected `MonoChip` now takes the soft brand pair** - `primarySoft` under
  `primaryText` - instead of inverting to a solid foreground fill with
  page-coloured text. `02-color-and-surface.md` had already assigned this job:
  "`primary`/`primarySoft` follow the same solid/soft grammar for brand emphasis
  (selected chips, active filters, highlighted rows)". The chip was the only
  component not honouring it.

  The old reading was that a chip row is selection rather than intent, so it
  should not spend the brand colour. The standard had decided otherwise, and the
  result was a selected chip that read as a solid black pill - outranking the
  primary button beside it, which inverts the intended hierarchy.

  **This changes how selected chips look.** The API is untouched, so nothing
  breaks at compile time; if you were relying on the inverted pill visually, this
  is the release that moves it. No golden baseline shifts, because no golden
  rendered a chip - which is part of how the drift went unnoticed.

- **Press and hover now darken a chip toward its own ink**, both weights. While
  selection inverted, the selected chip lerped toward `background` instead: the
  one fill in the kit that got *lighter* under the finger.

### Added

- **`MonoInput` takes a controlled `value`** alongside `onChanged`, matching
  every other stateful control in the kit. `controller` and `initialValue` still
  work; the three are mutually exclusive and asserted.
- **`MonoInput.pending`** - an affordance for asynchronous validation, distinct
  from disabled as the Field contract requires. It shows a spinner and announces
  itself, and deliberately does not block typing: taking the field away because
  a network call is slow is how a form loses a keystroke.
- `MonoFieldSkin` and `MonoInputSize`, exported, so a consumer composing its own
  field can sit on the same ladder.
- `MonoFocusRingOverlay`, for any control that needs the ring without the
  layout shift.
- `MonokitDensity.controlHeightLarge` (56/48). Not in `contract/space.json`,
  which stops at one control height; filed as an amendment.
- `MonoChip` has tests. It had none, in a package where every other component
  does, which is why nothing caught the divergence. They pin the treatment to
  the tokens rather than to literal colours, so a palette change moves them and
  a grammar change breaks them.
- 14 structural tests for the field: is there a fill, is there a border, which
  step of the ladder, is the ring outside the box, do all four controls still
  agree. The cosmetic values were already guarded; the *shape* was not, which is
  why it could invert without a single failure.

### Notes

- Selection remains legible without colour: the label still thickens to
  `FontWeight.w500` and the node still reports `selected`, so neither a
  monochrome display nor a screen reader depends on the fill.
- `MonoTextarea` extends `MonoInput`, so the skin had to learn the difference:
  a multi-line field takes body leading rather than the label register's tighter
  1.2, and gains vertical padding a centred single line does not need. Caught by
  the golden diff - the textarea had shrunk 27px - and now pinned by a test.
- Two Atlas values were not adopted literally. Horizontal padding is drawn at
  14, which is off the 4pt grid the whole system is built on, so fields use the
  neighbouring token (12) - a 2px difference, and no ungridded number in the
  kit. The ring extends `ringOffset + ringWidth` past the control, so an
  ancestor that clips will trim it; this matches `outline-offset` on the web.
- The Input contract still carries a MUST to *"colour its border with
  destructive"*, which a well has no border to colour. Its own description asks
  for the well. Both are filed for the system owner rather than settled here.

## 4.0.0

The removals 3.2.0 announced. 3.2.0 published the specification's token names
alongside the ones this package had invented and deprecated the latter; this
release deletes them, so there is one vocabulary rather than two. If you moved
your call sites when the deprecation warnings appeared, there is nothing to do
here.

Two other things go with them: the icon catalogue stops leaking its vendor, and
the chat receipt stops speaking in transport facts.

### Breaking

- **The package-specific colour names are gone.** Every one now carries the name
  the specification gives it. Values did not move — this is a rename, and the
  goldens are unchanged.
- **`MonoIconData` is opaque.** It no longer exposes the vendor's path data as a
  public field, and it can no longer be constructed from a raw vendor constant.
  While it did, a change of icon vendor was a breaking change for every consumer
  rather than an internal detail, which is exactly what the "accept a role,
  never a vendor glyph" clause exists to prevent. `MonoIcons` is the API; a role
  missing from it should be added to it. `withSemanticLabel` covers the case
  where one call site needs a narrower announcement than the catalogue can know.
- **`MonoReceiptState` is gone; `MonoReceipt` takes a `MonoPhase` and a label.**
  Three of its five values described a pipe rather than an intent, and its
  labels were hardcoded English in a system with translatable chrome.
- **`onStatus` became four tokens** — `destructiveForeground`,
  `successForeground`, `warningForeground`, `infoForeground` — as the contract
  names them. They share a value today; naming them per family is what lets one
  move later without dragging the other three.
- **`lib/src/widgets/components.dart` is deleted.** A second barrel that nothing
  imported, ten files out of date, and shipped in the archive regardless.

### Migration

```dart
// colours — the name changes, the value does not
colors.page            → colors.background
colors.foregroundMuted → colors.mutedForeground
colors.foregroundSubtle→ colors.mutedText
colors.fill            → colors.muted
colors.separator       → colors.border
colors.elevated        → colors.popover
colors.tint            → colors.primaryText
colors.onPrimary       → colors.primaryForeground
colors.danger          → colors.destructive
colors.dangerSoft      → colors.destructiveSoft
colors.dangerText      → colors.destructiveText
colors.onLive          → colors.liveForeground
colors.canvas          → colors.mediaCanvas
colors.mistFill        → colors.glassFill
colors.mistLine        → colors.glassBorder
colors.onStatus        → colors.destructiveForeground   // or the family you meant

// icons — construct from the catalogue, not from the vendor
MonoIconData(HugeIcons.strokeRoundedSearch01)  → MonoIcons.search
MonoIconData(x, semanticLabel: 'Find')         → MonoIcons.search.withSemanticLabel('Find')

// receipts — a phase and your own copy
MonoReceipt(state: MonoReceiptState.read)   → MonoReceipt(phase: MonoPhase.succeeded, label: 'Seen')
MonoReceipt(state: MonoReceiptState.failed) → MonoReceipt(phase: MonoPhase.rejected,  label: 'Not sent')
```

### Still open

Nine token **values** differ from the contract on purpose — this ground is mist
where `background` is white, the glass pair is mist-tinted, `muted` and `border`
are alpha rather than opaque. They are written up in monokit-spec's
`record/AMENDMENTS.md` and are the system owner's to rule on; whichever way each
goes, the names above are settled.

129 exported classes across 41 files still ship without a contract. The README
marks which parts of the API are specified and which are provisional, and
contracts for the rest are being written.

## 3.2.0

Conformance. An audit of this package against the specification at
monokit.monorithm.dev found twenty divergences, and the structural one was that the
two had stopped sharing a vocabulary: forty-three specified colour tokens did not
resolve under their specified names. Governance is not ambiguous about which side
moves — *"where a realization contradicts this site, the realization is what
changes"* — so the specified names are now the API, published alongside the ones
this package invented. Nothing is removed here and no value moved, so this is
additive; the old names go away in 4.0.0.

Three components the specification names were missing outright, and the two the
design boards depend on were among them. Two more findings were fixed by the tests
written for this release rather than by the audit: the pager's drag surface was only
as tall as its content, and the modal's Escape key never fired because its shortcut
sat below the focus scope rather than above it.

### Added

- **`MonoPager`, `MonoPageDots`, `MonoModal`** — specified components that had no
  implementation. The pager commits past 30% of its width or 700px/s, rubber-bands
  at 0.55 past the end stops, claims one gesture axis, and ships arrow keys and
  pointer-density chevrons in the same change as the gesture. The dots widen the
  active dot rather than only recolouring it, and expose one semantics node
  reporting position and length instead of a row of anonymous stops. The modal owns
  the focus trap, the exclusion triad, focus restoration and a labelled dismiss
  barrier — `MonoModalBarrierScope` applies focus, pointer and semantics exclusion
  together, since any subset leaves the overlay reachable by whichever modality was
  missed.
- **`MonoPhase`** — the five visible phases of a command: pending, reconciling,
  succeeded, rejected, stalled. None of them existed, which meant *rejected* and
  *stalled* could not be told apart: a declined payment and a dropped connection
  rendered the same and call for opposite responses. `MonoPhaseBadge` renders one,
  quietly.
- **`MonoSkeleton.sweepOnce`** — a single sweep rather than a loop. A looping
  shimmer means loading; one sweep means settled.
- **The specified colour names.** `background`, `cardForeground`, `popover`,
  `popoverForeground`, `mutedForeground`, `mutedText`, `muted`, `accent`,
  `accentForeground`, `border`, `primaryForeground`, `primaryText`, `destructive`,
  `destructiveSoft`, `destructiveText`, the four status foregrounds,
  `liveForeground`, `mediaCanvas`, `glassFill` and `glassBorder` all resolve.
- **Nineteen tokens that were simply absent**: `input`, `secondary`,
  `secondaryForeground`, `overlayScrim`, `glassFillLight`, `glassBorderLight`,
  `chart1`–`chart5`, and the eight `sidebar*` roles, plus `MonokitColors.glassBlur`.
- **Semantic layout tokens** — `MonokitContainers`, `MonokitChrome`,
  `MonokitPageInset`, `MonokitGutter`, `MonokitIconSize`, `MonokitList` and
  `MonoReachSide`, mirroring the shape the specification's own generator emits. The
  raw four-point scale was already here; what was missing was every number the
  language actually names, so a developer reading "a 64px list row" had nothing to
  reach for. Density now resolves `minTarget`, `controlHeight`, `gap`, `row1`–`row3`
  and `iconChrome`.
- **Motion role names** — `press`, `state`, `emphasis`, `screen`, at the values they
  already had.
- **`MonokitRadii.xs`** (4), which the scale was missing.
- **IBM Plex Sans Arabic**, bundled and wired as a fallback on every register. IBM
  Plex Sans has no Arabic block — the Arabic cut is a separate family — so until now
  every Arabic string fell back to a platform face at different metrics, in a
  product that ships Arabic as one of five languages.
- **Twelve icon roles** the design boards needed and had to reach past the catalogue
  for: `list`, `shield`, `trash`, `flag`, `wifiOff`, `eyeOff`, `zap`,
  `phoneIncoming`, `phoneOutgoing`, `plus`, `refresh`, `crop`.
- `MonokitLabels.active`, so the live badge has a localisable label.

### Changed

- **`MonoIcon` resolves its own size and stroke.** The default size now comes from
  density — 20 at touch, 16 at pointer — where it was hardcoded to 16, which
  under-sized every default icon in a touch product. The optical stroke floor of
  1.75 is applied at 16 and only at 16, `active` renders at 2.0, and the
  constructor asserts the five sanctioned sizes. Icons that mean direction —
  back, forward, the chevrons, send, reply — now mirror in RTL; icons that depict
  an object do not.
- **`MonoLiveBadge` no longer defaults to `'LIVE'`.** That string was uppercase
  where the content rules call for sentence case, English in a five-language
  product, and the wrong word: the state a merchant surface reports is *active*. It
  now falls back to `MonokitLabels.active`.
- **`proseHeading` tracking is -0.22**, not -0.1 — the contract sets -0.01em at
  22px, so it had been running at less than half the specified track.
  `headlineLarge` is -0.36, not -0.35.
- `MonoPager`'s panes fill the frame, so the drag surface is the whole pager rather
  than only as tall as the content inside it.

### Deprecated

Both removed in 4.0.0:

- The package-specific colour names, in favour of the specified ones: `page`,
  `foregroundMuted`, `foregroundSubtle`, `fill`, `separator`, `danger`,
  `dangerSoft`, `dangerText`, `onPrimary`, `onLive`, `onStatus`, `canvas`,
  `elevated`, `tint`, `mistFill`, `mistLine`.
- `MonoReceiptState`. Three of its five values — `sent`, `delivered`, `read` — are
  facts about a transport rather than phases of a command, and a component takes
  the phase, never the transport type. Use `MonoPhase`.

### Known gaps

Not fixed here, and tracked for 4.0.0 because each is breaking: `MonoIconData`
still exposes raw vendor path data publicly, which is the leak the "never a vendor
glyph name" clause exists to prevent; and 129 exported classes across 41 files
still ship without a contract — the README now marks which parts of the API are
specified and which are provisional.

## 3.1.0

The Makola realization finished its design work the way governance asks: the
proposal register updated, nothing invented privately. This release builds
that register — the three components it raised, and the smaller gaps the same
screens stepped into on the way to them.

### Added

- **`MonoImmersiveFeed`**, a primitive rather than a component: a
  full-viewport vertical feed that owns layout, gesture and resource policy,
  and composes the item presentation as its child. One swipe advances one item
  however hard the fling; the builder is told each item's phase (`active`,
  `near`, `far`) so items own their own decode, prefetch and release;
  `dataSaver` is a first-class input that switches neighbour keep-alive off;
  `onExposure` fires only when scrolling settles, because an item scrolled
  past was never actually seen; arrow and page keys page (jumping under
  reduced motion); and `restorationId` carries the position across navigation.
- **`MonoTrustBadge`**, the tiered credential: an ordered run of filled dots
  plus the tier's name — always as text, dots-only is not permitted. Brand ink
  on the soft brand fill on app surfaces, mist chrome and the on-media inks
  over media, and `lapsed` mutes the badge in place without changing its
  geometry. The lowest tier renders like every other tier: a starting point,
  never a warning.
- **`MonoMediaCard`**, the bounded media object with a lifecycle:
  `live | ended | archived | sold`. A non-live card asserts without a
  `stateLabel` — lifecycle is never carried by treatment alone — and a
  historical price renders in the muted label register, never typographically
  identical to a live one. The declared placeholder stands in for missing
  media, and the caption lives outside the media box so it renders before
  decode and survives text scaling.
- **`MonoChip`**: selection by inversion — the chosen chip swaps to the
  foreground fill — so a chip row reads without leaning on the brand colour.
- **`MonoListRow` and `MonoListGroup`**: rows as wells between collapsed
  hairlines at the 48/64 rhythm, with an optional muted footer for the
  group's fine print.
- **`MonoStepProgress`**: discrete progress for bounded flows — "which step of
  how many", where `MonoProgress` answers "how much". The strip announces as
  one progress semantic; the segments are presentation, not stops.
- **`MonoButtonSize.cta`**: the block commitment control — the 48 rhythm at
  the `xxl` radius. A size rather than a variant, because any weight can be
  the commitment.
- **`MonoBottomNav.showLabels` and `MonoBottomNav.onMedia`**: labels under the
  icons at the label floor (semibold when selected — a second, non-colour
  signal), and a translucent mist treatment for bars composed over the media
  canvas. Icon-only on the page surface stays the default.
- Eight `MonoIcons` roles: `back`, `store`, `camera`, `share`, `settings`,
  `notification`, `edit` and `home`.

### Changed

- `MonoButtonSize` gained a value, so an exhaustive `switch` over it in
  consuming code needs a `cta` arm. Nothing that already rendered changed how
  it renders.

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

- **The package is now `monokit_ui`.** Imports become
  `package:monokit_ui/monokit_ui.dart`, and the bundled font families are
  addressed as `packages/monokit_ui/IBM Plex Sans` (only relevant if you name
  them directly rather than going through `MonokitTypography.plex()`). Nothing
  else is renamed: every `Mono*` widget and `Monokit*` token class keeps its
  name. Repositories that depend on this one by git ref are pinned to v2.x
  tags, so they are unaffected until they bump.
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

## Unreleased (folded into 2.0.0)

Balance the design tokens and components to the shadcn `base-nova` web
reference. Never carried a version of its own — it landed before the 2.0.0 tag
and shipped inside it.

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
