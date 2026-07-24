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
class MonokitThemeData {
  const MonokitThemeData({
    required this.colors,
    this.radii = const MonokitRadii(),
    this.spacing = const MonokitSpacing(),
    this.typography = const MonokitTypography(),
    this.motion = const MonokitMotion(),
    this.elevation = const MonokitElevation(),
    this.density = const MonokitDensityData(),
    this.breakpoints = const MonokitBreakpoints(),
    this.haptics = const MonokitHaptics(),
    this.components = const MonokitComponentThemes(),
    this.focus = const MonokitFocus(),
    this.labels = const MonokitLabels(),
  });

  final MonokitColors colors;
  final MonokitRadii radii;
  final MonokitSpacing spacing;
  final MonokitTypography typography;
  final MonokitMotion motion;
  final MonokitElevation elevation;
  final MonokitDensityData density;
  final MonokitBreakpoints breakpoints;
  final MonokitHaptics haptics;
  final MonokitComponentThemes components;
  final MonokitFocus focus;
  final MonokitLabels labels;

  factory MonokitThemeData.light() => MonokitThemeData(
    colors: MonokitColors.light(),
    typography: MonokitTypography.plex(),
  );

  factory MonokitThemeData.dark() => MonokitThemeData(
    colors: MonokitColors.dark(),
    typography: MonokitTypography.plex(),
  );

  MonokitThemeData copyWith({
    MonokitColors? colors,
    MonokitRadii? radii,
    MonokitSpacing? spacing,
    MonokitTypography? typography,
    MonokitMotion? motion,
    MonokitElevation? elevation,
    MonokitDensityData? density,
    MonokitBreakpoints? breakpoints,
    MonokitHaptics? haptics,
    MonokitComponentThemes? components,
    MonokitFocus? focus,
    MonokitLabels? labels,
  }) {
    return MonokitThemeData(
      colors: colors ?? this.colors,
      radii: radii ?? this.radii,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
      motion: motion ?? this.motion,
      elevation: elevation ?? this.elevation,
      density: density ?? this.density,
      breakpoints: breakpoints ?? this.breakpoints,
      haptics: haptics ?? this.haptics,
      components: components ?? this.components,
      focus: focus ?? this.focus,
      labels: labels ?? this.labels,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitThemeData &&
      colors == other.colors &&
      radii == other.radii &&
      spacing == other.spacing &&
      typography == other.typography &&
      motion == other.motion &&
      elevation == other.elevation &&
      density == other.density &&
      breakpoints == other.breakpoints &&
      haptics == other.haptics &&
      components == other.components &&
      focus == other.focus &&
      labels == other.labels;

  @override
  int get hashCode => Object.hash(
    colors,
    radii,
    spacing,
    typography,
    motion,
    elevation,
    density,
    breakpoints,
    haptics,
    components,
    focus,
    labels,
  );
}
