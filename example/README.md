# Monokit showcase

A greenfield showcase for the [Monokit](../) design system. It has two registers:

- **Components** — every `Mono*` widget documented with a composed hero, the full
  variant/state matrix, and a live **responsive stage** you can drag.
- **Scenarios** — eight full-fidelity product screens (Storefront, Checkout, Order
  tracking, Conversation, Live studio, Creator studio, Team workspace, Group call),
  each framable on Phone / Tablet / Desktop from the header switcher.

## Responsive by design

Breakpoint demonstration is first-class, three ways:

- **Resizable stage** (`kit/responsive/responsive_stage.dart`) — drag the handle or
  snap to a preset; the framed subtree gets an overridden `MediaQuery`, so real
  Monokit widgets reflow live.
- **Side-by-side viewports** (`kit/responsive/viewport_row.dart`) — the same component
  at several breakpoints at once.
- **Global device switcher** (`kit/responsive/device_canvas.dart`) — pin the whole
  page to a framed device.

Breakpoints follow the Monokit ladder: compact `<600` · medium `600–960` ·
expanded `960–1280` · wide `≥1280`.

## Imagery

Real photography under the Unsplash License lives in `assets/images/` and is loaded
through `AppImage` (`kit/app_image.dart`), which falls back to deterministic
procedural art if an asset is missing. See `assets/README.md` to add more.

## Run

```bash
flutter run -d chrome
```

Resize the window (or use the header device switcher) to watch layouts reflow. Try
light and dark with the theme toggle.

Build an Android debug APK:

```bash
flutter build apk --debug
```

## Develop

```bash
flutter pub get
flutter analyze
flutter test
```
