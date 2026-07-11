import 'monokit_colors.dart';
import 'monokit_component_themes.dart';
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
    this.components = const MonokitComponentThemes(),
  });

  final MonokitColors colors;
  final MonokitRadii radii;
  final MonokitSpacing spacing;
  final MonokitTypography typography;
  final MonokitMotion motion;
  final MonokitComponentThemes components;

  factory MonokitThemeData.light() =>
      MonokitThemeData(colors: MonokitColors.light());

  factory MonokitThemeData.dark() =>
      MonokitThemeData(colors: MonokitColors.dark());

  MonokitThemeData copyWith({
    MonokitColors? colors,
    MonokitRadii? radii,
    MonokitSpacing? spacing,
    MonokitTypography? typography,
    MonokitMotion? motion,
    MonokitComponentThemes? components,
  }) {
    return MonokitThemeData(
      colors: colors ?? this.colors,
      radii: radii ?? this.radii,
      spacing: spacing ?? this.spacing,
      typography: typography ?? this.typography,
      motion: motion ?? this.motion,
      components: components ?? this.components,
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
      components == other.components;

  @override
  int get hashCode =>
      Object.hash(colors, radii, spacing, typography, motion, components);
}
