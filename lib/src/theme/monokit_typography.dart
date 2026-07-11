import 'package:flutter/widgets.dart';

/// Typography tokens with a system sans-serif default.
class MonokitTypography {
  const MonokitTypography({
    this.displayLarge = const TextStyle(
      fontSize: 36,
      height: 1.1,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.9,
    ),
    this.displayMedium = const TextStyle(
      fontSize: 30,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
    ),
    this.headlineLarge = const TextStyle(
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.35,
    ),
    this.headlineMedium = const TextStyle(
      fontSize: 20,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    this.titleLarge = const TextStyle(
      fontSize: 18,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    this.titleMedium = const TextStyle(
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    this.bodyLarge = const TextStyle(fontSize: 16, height: 1.5),
    this.bodyMedium = const TextStyle(fontSize: 14, height: 1.45),
    this.labelLarge = const TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
    this.labelMedium = const TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
    this.button = const TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle button;

  /// Alias used by [MonokitApp]'s default text style.
  TextStyle get body => bodyMedium;

  MonokitTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? button,
  }) {
    return MonokitTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      button: button ?? this.button,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitTypography &&
      displayLarge == other.displayLarge &&
      displayMedium == other.displayMedium &&
      headlineLarge == other.headlineLarge &&
      headlineMedium == other.headlineMedium &&
      titleLarge == other.titleLarge &&
      titleMedium == other.titleMedium &&
      bodyLarge == other.bodyLarge &&
      bodyMedium == other.bodyMedium &&
      labelLarge == other.labelLarge &&
      labelMedium == other.labelMedium &&
      button == other.button;

  @override
  int get hashCode => Object.hashAll(<Object>[
    displayLarge,
    displayMedium,
    headlineLarge,
    headlineMedium,
    titleLarge,
    titleMedium,
    bodyLarge,
    bodyMedium,
    labelLarge,
    labelMedium,
    button,
  ]);
}
