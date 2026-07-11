# Monokit

Monokit is a compact, token-driven, widgets-first Flutter design system inspired by the clean, zinc-neutral Monorithm visual language. It is built from `flutter/widgets.dart` primitives rather than a Material reskin, with semantic light/dark themes, keyboard-friendly controls, and responsive screen composition.

## Install

```bash
flutter pub add monokit
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

The included `example/` is a runnable eight-screen documentation showcase of
the library's component groups. Start it with `cd example && flutter run -d chrome`.

## Included in v0.1

- Semantic light and dark tokens: colors, typography, radii, spacing, and motion.
- `MonokitApp` and `MonoScreen`, including safe-area, keyboard inset, floating, sidebar, and overlay layers.
- Foundations: buttons, badges, cards, avatars, separators, skeletons, spinners, and keyboard hints.
- Forms: `EditableText`-based inputs and textareas, fields, checkboxes, radio groups, and switches.
- Navigation controls: tabs and accordions.
- Widgets-first dialog, icon, and sidebar primitives for composable application shells.

Every component resolves its appearance from `MonokitTheme.of(context)`:

```dart
final theme = MonokitTheme.of(context);
final radius = theme.radii.lg;
final color = theme.colors.primary;
```

## Design principles

- No `MaterialApp`, `Scaffold`, `TextField`, `InkWell`, or Material `ThemeData` in the core library.
- Stable semantic sRGB hex tokens for a consistent zinc-inspired palette.
- Accessible focus, hover, pressed, selected, invalid, and disabled states.
- Compact rounded surfaces, subtle shadows, and 150ms motion by default.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```

The package is MIT licensed.
