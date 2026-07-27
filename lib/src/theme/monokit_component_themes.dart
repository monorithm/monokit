import 'package:flutter/foundation.dart';

/// Per-component configuration tokens.
///
/// Colors remain semantic and live in [MonokitColors]. These lightweight theme
/// objects intentionally hold only component-specific geometry and behavior,
/// so a product can adjust a single component without breaking token usage.
class MonoButtonTheme {
  const MonoButtonTheme({this.focusRingWidth = 2, this.pressedScale = 0.98});

  final double focusRingWidth;
  final double pressedScale;

  @override
  bool operator ==(Object other) =>
      other is MonoButtonTheme &&
      focusRingWidth == other.focusRingWidth &&
      pressedScale == other.pressedScale;

  @override
  int get hashCode => Object.hash(focusRingWidth, pressedScale);
}

class MonoCardTheme {
  const MonoCardTheme({this.borderWidth = 1, this.elevation = 1});

  final double borderWidth;
  final double elevation;

  @override
  bool operator ==(Object other) =>
      other is MonoCardTheme &&
      borderWidth == other.borderWidth &&
      elevation == other.elevation;

  @override
  int get hashCode => Object.hash(borderWidth, elevation);
}

class MonoInputTheme {
  const MonoInputTheme({this.borderWidth = 1, this.focusRingWidth = 2});

  final double borderWidth;
  final double focusRingWidth;

  @override
  bool operator ==(Object other) =>
      other is MonoInputTheme &&
      borderWidth == other.borderWidth &&
      focusRingWidth == other.focusRingWidth;

  @override
  int get hashCode => Object.hash(borderWidth, focusRingWidth);
}

class MonoControlTheme {
  const MonoControlTheme({this.focusRingWidth = 2});

  final double focusRingWidth;

  @override
  bool operator ==(Object other) =>
      other is MonoControlTheme && focusRingWidth == other.focusRingWidth;

  @override
  int get hashCode => focusRingWidth.hashCode;
}

/// Sidebar geometry for [MonoScreen].
///
/// The width ladder used to live here too, as `compactBreakpoint`/
/// `mediumBreakpoint` — a second copy of `MonokitBreakpoints` carrying the same
/// numbers. `MonoScreen` read this copy while everything else read the theme's,
/// so overriding one had no effect on the other. There is now one ladder:
/// `theme.breakpoints`.
class MonoScreenTheme {
  const MonoScreenTheme({this.sidebarWidth = 280, this.sidebarRailWidth = 72});

  final double sidebarWidth;
  final double sidebarRailWidth;

  MonoScreenTheme copyWith({double? sidebarWidth, double? sidebarRailWidth}) =>
      MonoScreenTheme(
        sidebarWidth: sidebarWidth ?? this.sidebarWidth,
        sidebarRailWidth: sidebarRailWidth ?? this.sidebarRailWidth,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonoScreenTheme &&
          sidebarWidth == other.sidebarWidth &&
          sidebarRailWidth == other.sidebarRailWidth);

  @override
  int get hashCode => Object.hash(sidebarWidth, sidebarRailWidth);
}

/// Container for the component theme knobs that are actually consulted.
///
/// This held 17 slots, of which 14 were never read by any widget — and 12 of
/// those were the same one-field `MonoControlTheme`, so overriding one meant
/// re-listing all 17 (there was no `copyWith`). Components either hardcoded
/// the value or read `theme.focus.ringWidth` instead. What survives is the
/// three slots the library genuinely resolves from.
@immutable
class MonokitComponentThemes {
  const MonokitComponentThemes({
    this.button = const MonoButtonTheme(),
    this.card = const MonoCardTheme(),
    this.screen = const MonoScreenTheme(),
  });

  final MonoButtonTheme button;
  final MonoCardTheme card;
  final MonoScreenTheme screen;

  MonokitComponentThemes copyWith({
    MonoButtonTheme? button,
    MonoCardTheme? card,
    MonoScreenTheme? screen,
  }) => MonokitComponentThemes(
    button: button ?? this.button,
    card: card ?? this.card,
    screen: screen ?? this.screen,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitComponentThemes &&
          button == other.button &&
          card == other.card &&
          screen == other.screen);

  @override
  int get hashCode => Object.hash(button, card, screen);
}
