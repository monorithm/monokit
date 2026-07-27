import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'monokit_colors.dart';
import 'monokit_component_themes.dart';
import 'monokit_density.dart';
import 'monokit_elevation.dart';
import 'monokit_focus.dart';
import 'monokit_haptics.dart';
import 'monokit_labels.dart';
import 'monokit_motion.dart';
import 'monokit_radii.dart';
import 'monokit_spacing.dart';
import 'monokit_typography.dart';

/// Immutable token bundle consumed by all Monokit widgets.
@immutable
final class MonokitThemeData {
  const MonokitThemeData({
    required this.brightness,
    required this.colors,
    required this.elevation,
    this.radii = const MonokitRadii(),
    this.spacing = const MonokitSpacing(),
    this.typography = const MonokitTypography(),
    this.motion = const MonokitMotion(),
    this.density = const MonokitDensity(),
    this.breakpoints = const MonokitBreakpoints(),
    this.haptics = const MonokitHaptics(),
    this.components = const MonokitComponentThemes(),
    this.focus = const MonokitFocus(),
    this.labels = const MonokitLabels(),
  });

  /// Which mode this bundle *is*. Nothing could previously ask a theme whether
  /// it was light or dark, so components that needed to know had to compare
  /// colour values.
  final Brightness brightness;

  final MonokitColors colors;
  final MonokitElevation elevation;
  final MonokitRadii radii;
  final MonokitSpacing spacing;
  final MonokitTypography typography;
  final MonokitMotion motion;
  final MonokitDensity density;
  final MonokitBreakpoints breakpoints;
  final MonokitHaptics haptics;
  final MonokitComponentThemes components;
  final MonokitFocus focus;
  final MonokitLabels labels;

  factory MonokitThemeData.light() => MonokitThemeData(
    brightness: Brightness.light,
    colors: MonokitColors.light(),
    elevation: MonokitElevation.light(),
    typography: MonokitTypography.plex(),
  );

  factory MonokitThemeData.dark() => MonokitThemeData(
    brightness: Brightness.dark,
    colors: MonokitColors.dark(),
    elevation: MonokitElevation.dark(),
    typography: MonokitTypography.plex(),
  );

  // ---------------------------------------------------------------------------
  // Adaptive metrics
  //
  // Density drives the whole ramp, not just a hit target. Components read these
  // rather than reaching for raw tokens, so switching touch/pointer moves type,
  // row heights and margins together instead of one at a time.
  // ---------------------------------------------------------------------------

  bool get isTouch => density.isTouch;

  /// Minimum interactive height for list rows.
  double get rowHeight => isTouch ? 44 : 32;

  /// Height of buttons, inputs and other standalone controls.
  double get controlHeight => isTouch ? 44 : 36;

  /// Horizontal page margin.
  double get layoutMargin => isTouch ? spacing.lg : spacing.md;

  /// Body copy. 16 at touch, 14 at pointer.
  TextStyle get bodyText =>
      isTouch ? typography.bodyLarge : typography.bodyMedium;

  /// The page heading that collapses into the bar title on scroll.
  TextStyle get titleText =>
      isTouch ? typography.headlineLarge : typography.headlineMedium;

  /// Applies a resolved density mode without disturbing the target sizes.
  MonokitThemeData withDensityMode(MonoDensity? mode) =>
      copyWith(density: density.withMode(mode));

  static MonokitThemeData lerp(
    MonokitThemeData a,
    MonokitThemeData b,
    double t,
  ) => MonokitThemeData(
    // Discrete fields snap at the midpoint; only the continuous ones tween.
    brightness: t < 0.5 ? a.brightness : b.brightness,
    colors: MonokitColors.lerp(a.colors, b.colors, t),
    elevation: MonokitElevation.lerp(a.elevation, b.elevation, t),
    radii: t < 0.5 ? a.radii : b.radii,
    spacing: t < 0.5 ? a.spacing : b.spacing,
    typography: t < 0.5 ? a.typography : b.typography,
    motion: t < 0.5 ? a.motion : b.motion,
    density: t < 0.5 ? a.density : b.density,
    breakpoints: t < 0.5 ? a.breakpoints : b.breakpoints,
    haptics: t < 0.5 ? a.haptics : b.haptics,
    components: t < 0.5 ? a.components : b.components,
    focus: t < 0.5 ? a.focus : b.focus,
    labels: t < 0.5 ? a.labels : b.labels,
  );

  MonokitThemeData copyWith({
    Brightness? brightness,
    MonokitColors? colors,
    MonokitElevation? elevation,
    MonokitRadii? radii,
    MonokitSpacing? spacing,
    MonokitTypography? typography,
    MonokitMotion? motion,
    MonokitDensity? density,
    MonokitBreakpoints? breakpoints,
    MonokitHaptics? haptics,
    MonokitComponentThemes? components,
    MonokitFocus? focus,
    MonokitLabels? labels,
  }) => MonokitThemeData(
    brightness: brightness ?? this.brightness,
    colors: colors ?? this.colors,
    elevation: elevation ?? this.elevation,
    radii: radii ?? this.radii,
    spacing: spacing ?? this.spacing,
    typography: typography ?? this.typography,
    motion: motion ?? this.motion,
    density: density ?? this.density,
    breakpoints: breakpoints ?? this.breakpoints,
    haptics: haptics ?? this.haptics,
    components: components ?? this.components,
    focus: focus ?? this.focus,
    labels: labels ?? this.labels,
  );

  List<Object?> get _fields => <Object?>[
    brightness,
    colors,
    elevation,
    radii,
    spacing,
    typography,
    motion,
    density,
    breakpoints,
    haptics,
    components,
    focus,
    labels,
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitThemeData && listEquals(_fields, other._fields));

  @override
  int get hashCode => Object.hashAll(_fields);
}
