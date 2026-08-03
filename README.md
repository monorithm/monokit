# Monokit

Monokit is a token-driven, widgets-first design system for Flutter.

**Widgets-first.** No `MaterialApp`, `Scaffold`, `TextField`, `InkWell` or
Material `ThemeData` anywhere in the core library. Every component is built
directly on `package:flutter/widgets.dart`, so what you get is the component
you see rather than a Material widget wearing a different colour scheme.

**Token-driven.** Colours, radii, spacing, elevation, density, breakpoints,
motion, haptics, focus and user-facing strings all resolve from
`MonokitTheme.of(context)`. Changing a token changes every component that reads
it; nothing hard-codes its own appearance.

**Complete enough to build with.** Buttons, badges, cards and avatars; inputs,
textareas and OTP fields with real selection handles, a copy/paste toolbar and a
magnifier; tabs, accordions and pagination; viewport-aware overlays — select,
dropdown, combobox, popover, context menu, tooltip, hover card — that stay
on-screen; sheets, drawers and dialogs; and app shells with sidebars, safe-area
and keyboard-inset handling.

**Batteries included.** The IBM Plex superfamily ships inside the package and is
the default typography, so text looks right on first run with no font
registration and no network fetch.

## Install

```bash
flutter pub add monokit_ui
```

The package is `monokit_ui` on pub.dev. The design system, its widgets and its
theme classes are all still named Monokit — only the package and its import
path carry the suffix.

## Start an app

```dart
import 'package:monokit_ui/monokit_ui.dart';

void main() {
  runApp(
    MonokitApp(
      theme: MonokitThemeData.light(),
      darkTheme: MonokitThemeData.dark(),
      home: const DashboardPage(),
    ),
  );
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MonoScreen(
      header: const MonoScreenHeader(title: Text('Projects')),
      body: Center(
        child: MonoButton.icon(
          icon: const MonoIcon(MonoIcons.add),
          label: const Text('New project'),
          onPressed: () {},
        ),
      ),
    );
  }
}
```

`package:monokit_ui/monokit_ui.dart` re-exports `package:flutter/widgets.dart`,
the way `material.dart` does — one import gets you both. The trade-off is that
every Flutter name in `widgets.dart` lands in monokit's namespace, so an app
with its own `Page`, `Action` or `Route` will hit an ambiguous-import error and
needs to `hide` one side. Prefixing monokit's own symbols with `Mono` does not
help: the collision is between Flutter's names and yours.

## Theming

Components never hold their own colours. They read them:

```dart
final theme = MonokitTheme.of(context);
final radius = theme.radii.lg;
final color = theme.colors.primary;
```

`MonokitThemeData.light()` and `.dark()` are the two semantic token sets — mist
surfaces, a rationed emerald action colour, and status treatments that stay
legible in both. Override any group to retheme wholesale:

```dart
MonokitThemeData.light().copyWith(
  radii: const MonokitRadii(base: 4, sm: 2, md: 3, lg: 4, xl: 6),
  typography: MonokitTypography.withFamilies(sans: 'Inter'),
)
```

Density and breakpoints are tokens too, so the same tree can go compact on a
phone and comfortable on a desktop without a second widget set.

## Routes and transitions

`MonokitApp` forwards the standard `WidgetsApp` routing inputs. Named routes get
a token-timed fade by default, replaceable with a custom `pageRouteBuilder`:

```dart
MonokitApp(
  theme: MonokitThemeData.light(),
  darkTheme: MonokitThemeData.dark(),
  initialRoute: '/overview',
  routes: <String, WidgetBuilder>{
    '/overview': (_) => const OverviewPage(),
    '/settings': (_) => const SettingsPage(),
  },
)
```

`pushNamed` keeps normal Navigator history, so browser and platform Back move
through previously visited routes.

## What's in the box

- Semantic light and dark tokens: colours, status, media, glass, elevation,
  density, breakpoints, typography, radii, spacing, motion, haptics, focus ring,
  and overridable labels.
- `MonokitApp` and `MonoScreen` — safe-area, keyboard inset, floating, sidebar
  and overlay layers.
- Foundations: buttons, badges, cards, avatars, separators, skeletons, spinners,
  keyboard hints.
- Forms: `EditableText`-based inputs, textareas and OTP fields, plus fields,
  checkboxes, radio groups and switches.
- Navigation: tabs, accordions, breadcrumbs, pagination, bottom nav, command
  palette.
- Overlays via `MonoAnchoredLayout`: select, dropdown, combobox, popover,
  context menu, tooltip, hover card — all viewport-aware.
- Honest-state banner, toast host, empty state.
- Engine-neutral media, communication, call, capture, document and gallery
  surfaces.
- Product, price, quantity and cart commerce components.

Accessible focus, hover, pressed, selected, invalid and disabled states are part
of the primitives, not something each component reinvents.

## Scope

Monokit ships **widget and design primitives only**. Product-shaped composites —
your app's onboarding card, your particular settings row — belong in the app
that consumes it. The line is deliberate: a design system that grows product
components stops being reusable.

## Example

`example/` is a runnable gallery with two registers: every `Mono*` widget with
its full variant and state matrix on a draggable responsive stage, and eight
full-fidelity product screens framable at phone, tablet and desktop.

```bash
cd example
flutter run -d chrome
```

## Development

```bash
flutter pub get
flutter analyze
flutter test
```

The golden suite compares against reference images generated on Linux CI, so it
fails on other platforms where anti-aliasing differs. Locally:

```bash
flutter test --exclude-tags golden
```

Regenerate baselines through the **Goldens** workflow (Actions ▸ Goldens ▸ Run
workflow) after an intentional visual change, then commit the uploaded artifact.

## Licence

Monokit is MIT licensed — see [LICENSE](LICENSE).

The bundled IBM Plex fonts in `fonts/` are © 2017 IBM Corp. and licensed
separately under the SIL Open Font License 1.1 — see [fonts/OFL.txt](fonts/OFL.txt).
