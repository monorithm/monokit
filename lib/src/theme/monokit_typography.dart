import 'package:flutter/widgets.dart';

/// Typography tokens.
///
/// Three registers, per the design language:
/// * **Sans** — chrome and content (the display→label ramp). Platform sans by
///   default.
/// * **Mono** — *machine-shaped text*: prices, OTP digits, order IDs, ages, and
///   deadline counters. Always uses **tabular figures** so `0/O` and `1/l` never
///   blur on a receipt ([mono], [code], and the [tabular] helper).
/// * **Serif** — the long-form reading register ([prose] / [proseHeading]).
///
/// Font families are applied at construction. Use [MonokitTypography.withFamilies]
/// (or [MonokitTypography.plex]) to bind real families; the default is the
/// platform sans + a system monospace.
@immutable
class MonokitTypography {
  const MonokitTypography({
    this.sansFamily,
    this.monoFamily,
    this.serifFamily,
    this.displayLarge = _kDisplayLarge,
    this.displayMedium = _kDisplayMedium,
    this.headlineLarge = _kHeadlineLarge,
    this.headlineMedium = _kHeadlineMedium,
    this.titleLarge = _kTitleLarge,
    this.titleMedium = _kTitleMedium,
    this.bodyLarge = _kBodyLarge,
    this.bodyMedium = _kBodyMedium,
    this.labelLarge = _kLabelLarge,
    this.labelMedium = _kLabelMedium,
    this.button = _kButton,
    this.mono = _kMono,
    this.code = _kCode,
    this.prose = _kProse,
    this.proseHeading = _kProseHeading,
    this.mediaTitle = _kMediaTitle,
    this.mediaCaption = _kMediaCaption,
  });

  /// Binds font families to each register, baking them into every style.
  factory MonokitTypography.withFamilies({
    String? sans,
    String? mono,
    String? serif,
  }) {
    TextStyle s(TextStyle base) => base.copyWith(fontFamily: sans);
    TextStyle m(TextStyle base) => base.copyWith(fontFamily: mono);
    TextStyle f(TextStyle base) => base.copyWith(fontFamily: serif);
    return MonokitTypography(
      sansFamily: sans,
      monoFamily: mono,
      serifFamily: serif,
      displayLarge: s(_kDisplayLarge),
      displayMedium: s(_kDisplayMedium),
      headlineLarge: s(_kHeadlineLarge),
      headlineMedium: s(_kHeadlineMedium),
      titleLarge: s(_kTitleLarge),
      titleMedium: s(_kTitleMedium),
      bodyLarge: s(_kBodyLarge),
      bodyMedium: s(_kBodyMedium),
      labelLarge: s(_kLabelLarge),
      labelMedium: s(_kLabelMedium),
      button: s(_kButton),
      mono: m(_kMono),
      code: m(_kCode),
      prose: f(_kProse),
      proseHeading: f(_kProseHeading),
      mediaTitle: s(_kMediaTitle),
      mediaCaption: s(_kMediaCaption),
    );
  }

  /// The canonical IBM Plex superfamily, bundled with the `monokit` package —
  /// works out of the box (no font registration required). This is the default
  /// typography for [MonokitThemeData.light]/[MonokitThemeData.dark].
  factory MonokitTypography.plex() => MonokitTypography.withFamilies(
    sans: 'packages/monokit_ui/IBM Plex Sans',
    mono: 'packages/monokit_ui/IBM Plex Mono',
    serif: 'packages/monokit_ui/IBM Plex Serif',
  );

  final String? sansFamily;
  final String? monoFamily;
  final String? serifFamily;

  // Sans register (chrome + content).
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

  // Mono register (machine-shaped text; tabular figures).
  final TextStyle mono;
  final TextStyle code;

  // Serif register (long-form reading).
  final TextStyle prose;
  final TextStyle proseHeading;

  // On-media register.
  final TextStyle mediaTitle;
  final TextStyle mediaCaption;

  /// Alias used by [MonokitApp]'s default text style.
  TextStyle get body => bodyMedium;

  /// Applies the mono/tabular register to any style — e.g. a price shown at
  /// `titleLarge` size: `typography.tabular(typography.titleLarge)`.
  TextStyle tabular(TextStyle base) => base.copyWith(
    fontFamily: monoFamily,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle _kDisplayLarge = TextStyle(
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9,
  );
  static const TextStyle _kDisplayMedium = TextStyle(
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const TextStyle _kHeadlineLarge = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.35,
  );
  static const TextStyle _kHeadlineMedium = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle _kTitleLarge = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _kTitleMedium = TextStyle(
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _kBodyLarge = TextStyle(fontSize: 16, height: 1.5);
  static const TextStyle _kBodyMedium = TextStyle(fontSize: 14, height: 1.45);
  static const TextStyle _kLabelLarge = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle _kLabelMedium = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle _kButton = TextStyle(
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle _kMono = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  static const TextStyle _kCode = TextStyle(
    fontSize: 13,
    height: 1.5,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );
  static const TextStyle _kProse = TextStyle(fontSize: 17, height: 1.65);
  static const TextStyle _kProseHeading = TextStyle(
    fontSize: 22,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );
  static const TextStyle _kMediaTitle = TextStyle(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle _kMediaCaption = TextStyle(fontSize: 14, height: 1.4);

  MonokitTypography copyWith({
    String? sansFamily,
    String? monoFamily,
    String? serifFamily,
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
    TextStyle? mono,
    TextStyle? code,
    TextStyle? prose,
    TextStyle? proseHeading,
    TextStyle? mediaTitle,
    TextStyle? mediaCaption,
  }) {
    return MonokitTypography(
      sansFamily: sansFamily ?? this.sansFamily,
      monoFamily: monoFamily ?? this.monoFamily,
      serifFamily: serifFamily ?? this.serifFamily,
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
      mono: mono ?? this.mono,
      code: code ?? this.code,
      prose: prose ?? this.prose,
      proseHeading: proseHeading ?? this.proseHeading,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      mediaCaption: mediaCaption ?? this.mediaCaption,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitTypography &&
      sansFamily == other.sansFamily &&
      monoFamily == other.monoFamily &&
      serifFamily == other.serifFamily &&
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
      button == other.button &&
      mono == other.mono &&
      code == other.code &&
      prose == other.prose &&
      proseHeading == other.proseHeading &&
      mediaTitle == other.mediaTitle &&
      mediaCaption == other.mediaCaption;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    sansFamily,
    monoFamily,
    serifFamily,
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
    mono,
    code,
    prose,
    proseHeading,
    mediaTitle,
    mediaCaption,
  ]);
}
