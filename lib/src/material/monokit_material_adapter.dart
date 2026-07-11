import 'package:flutter/material.dart';

import '../theme/monokit_theme_data.dart';
import 'monokit_theme_extension.dart';

/// Produces a Material [ThemeData] from a Monokit token bundle when a host app
/// must use Material routes or third-party Material widgets.
abstract final class MonokitMaterialAdapter {
  static ThemeData light({MonokitThemeData? monokit, ThemeData? base}) {
    return from(monokit ?? MonokitThemeData.light(), base: base);
  }

  static ThemeData dark({MonokitThemeData? monokit, ThemeData? base}) {
    return from(monokit ?? MonokitThemeData.dark(), base: base);
  }

  static ThemeData from(MonokitThemeData monokit, {ThemeData? base}) {
    final colors = monokit.colors;
    final brightness = colors.background.computeLuminance() < 0.5
        ? Brightness.dark
        : Brightness.light;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.primaryForeground,
      secondary: colors.secondary,
      onSecondary: colors.secondaryForeground,
      error: colors.destructive,
      onError: colors.primaryForeground,
      surface: colors.card,
      onSurface: colors.cardForeground,
    );
    final initial =
        base ?? ThemeData(colorScheme: colorScheme, useMaterial3: true);
    final extensions = <ThemeExtension<dynamic>>[
      ...initial.extensions.values.whereType<ThemeExtension<dynamic>>(),
      MonokitThemeExtension(monokit),
    ];
    return initial.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.border,
      focusColor: colors.ring.withValues(alpha: 0.16),
      textTheme: initial.textTheme.copyWith(
        bodyLarge: monokit.typography.bodyLarge.copyWith(
          color: colors.foreground,
        ),
        bodyMedium: monokit.typography.bodyMedium.copyWith(
          color: colors.foreground,
        ),
        titleLarge: monokit.typography.titleLarge.copyWith(
          color: colors.foreground,
        ),
        labelLarge: monokit.typography.labelLarge.copyWith(
          color: colors.foreground,
        ),
      ),
      extensions: extensions,
    );
  }
}
