# Monokit

Monokit is Monorithm's private, canonical Flutter implementation of the Monokit design language. It uses mist surfaces, a rationed emerald action color, honest status treatments, and widgets-first primitives rather than a Material reskin.

Monokit ships **widget and design primitives only** — buttons, the icon catalog, interaction states, navigation surfaces, theme tokens via `MonokitTheme.of(context)`. Product-shaped composites belong in the consuming app (for Monorithm: its `packages/ui`).

## Install

```bash
flutter pub add monokit --hosted-url <private-pub-server>
```

## Start an app

```dart
import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

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

## Routes and transitions

`MonokitApp` forwards the standard `WidgetsApp` routing inputs. Named routes
receive a token-timed fade transition by default, and can be replaced with a
custom `pageRouteBuilder` when an application needs a different motion style.

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

// From a route:
Navigator.of(context).pushNamed('/settings');
```

`pushNamed` retains normal Navigator history, so browser and platform Back
move through previously visited named routes.

The included `example/` is a runnable collection of eight product scenarios:
creator studio, storefront, checkout, order tracking, workspace, live commerce,
conversation, and group call. Start it with `cd example && flutter run -d chrome`.

## Included in v0.2

- Semantic light and dark tokens: mist/emerald colors, status, media, glass,
  elevation, density, breakpoints, typography, radii, spacing, motion, and haptics.
- `MonokitApp` and `MonoScreen`, including safe-area, keyboard inset, floating, sidebar, and overlay layers.
- Foundations: buttons, badges, cards, avatars, separators, skeletons, spinners, and keyboard hints.
- Forms: `EditableText`-based inputs and textareas, fields, checkboxes, radio groups, and switches.
- Navigation controls: tabs and accordions.
- Widgets-first dialog, icon, and sidebar primitives for composable application shells.
- Honest-state banner, toast host, empty state, and command-phase vocabulary.
- Engine-neutral media, communication, call, capture, document, and gallery surfaces.
- Product, price, quantity, cart, and order-status commerce components.

Every component resolves its appearance from `MonokitTheme.of(context)`:

```dart
final theme = MonokitTheme.of(context);
final radius = theme.radii.lg;
final color = theme.colors.primary;
```

## Design principles

- No `MaterialApp`, `Scaffold`, `TextField`, `InkWell`, or Material `ThemeData` in the core library.
- Stable semantic sRGB hex tokens for a consistent mist-and-emerald palette.
- Accessible focus, hover, pressed, selected, invalid, and disabled states.
- Compact rounded surfaces, semantic elevation tiers, and calm motion roles.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```

The package is MIT licensed.
