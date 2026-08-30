import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Monokit's semantic colour roles.
///
/// The palette is **emerald on mist**, and the surface model is **grouped**:
/// one thing is in focus at a time, and surfaces separate by *luminance step*
/// rather than by hairline. That is why there is a [page] → [card] → [elevated]
/// ladder and [separator] exists to divide content *within* a surface, not to
/// outline the surface itself. The specification's `border` resolves onto it.
///
/// Every specified token name resolves here. Where this package named a role
/// differently, the specified name is published as an alias further down and is
/// the one to write new code against.
///
/// Roles are named for their job, not for a palette position. `page` is
/// whatever the screen ground is in this theme; in light that is the mist
/// `#F1F3F3`, in dark the lifted charcoal `#161B1D`. Dark deliberately does not
/// bottom out at black — pure black reads as a hole rather than a surface, and
/// leaves nothing for [card] to step up from.
///
/// Two brand roles, not one: [tint] colours interactive *text and icons*,
/// [primary] fills solid backgrounds. They are the same value in light, but
/// diverge in dark, where the fill must go darker and the text lighter to hold
/// contrast against their respective grounds.
@immutable
final class MonokitColors {
  const MonokitColors({
    required this.page,
    required this.card,
    required this.elevated,
    required this.foreground,
    required this.foregroundMuted,
    required this.foregroundSubtle,
    required this.fill,
    required this.separator,
    required this.ring,
    required this.tint,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.danger,
    required this.dangerSoft,
    required this.dangerText,
    required this.success,
    required this.successSoft,
    required this.successText,
    required this.warning,
    required this.warningSoft,
    required this.warningText,
    required this.info,
    required this.infoSoft,
    required this.infoText,
    required this.onStatus,
    required this.live,
    required this.onLive,
    required this.canvas,
    required this.onMedia,
    required this.onMediaMuted,
    required this.mistFill,
    required this.mistLine,
    required this.scrim,
    required this.scrimStrong,
    this.input = const Color(0xFFE3E7E8),
    this.secondary = const Color(0xFFECEFEF),
    this.secondaryForeground = const Color(0xFF161B1D),
    this.overlayScrim = const Color(0x99090A0B),
    this.glassFillLight = const Color(0x0D000000),
    this.glassBorderLight = const Color(0x14000000),
    this.chart1 = const Color(0xFFD0D6D8),
    this.chart2 = const Color(0xFF67787C),
    this.chart3 = const Color(0xFF4B585B),
    this.chart4 = const Color(0xFF394447),
    this.chart5 = const Color(0xFF22292B),
    this.sidebar = const Color(0xFFF9FBFB),
    this.sidebarForeground = const Color(0xFF090B0C),
    this.sidebarPrimary = const Color(0xFF009966),
    this.sidebarPrimaryForeground = const Color(0xFFECFDF5),
    this.sidebarAccent = const Color(0xFFF1F3F3),
    this.sidebarAccentForeground = const Color(0xFF161B1D),
    this.sidebarBorder = const Color(0xFFE3E7E8),
    this.sidebarRing = const Color(0xFF9CA8AB),
  });

  /// The screen ground. Cards sit on top of this.
  final Color page;

  /// The default content surface — one luminance step above [page].
  final Color card;

  /// Surfaces that genuinely float: menus, popovers, dialogs, sheets. One step
  /// above [card] so a dialog still reads as above the card behind it in dark,
  /// where the two grounds are close together.
  final Color elevated;

  /// The three-step text ramp. [foregroundSubtle] is for placeholders,
  /// disabled labels and chevrons — never for body copy.
  final Color foreground;
  final Color foregroundMuted;
  final Color foregroundSubtle;

  /// Tile, track and inactive-control backgrounds. Alpha-based so it composites
  /// correctly on [page], [card] and [elevated] alike.
  final Color fill;

  /// Divides content *inside* a surface. Alpha-based for the same reason.
  final Color separator;

  /// Focus ring.
  final Color ring;

  /// Interactive text and icons.
  final Color tint;

  /// Solid brand fills, and the foreground that survives on them.
  final Color primary;
  final Color onPrimary;

  /// Brand tint at low saturation — icon tiles, selected rows, soft chips.
  final Color primarySoft;

  /// Status families. `x` is the solid, `xSoft` the tinted background, and
  /// `xText` the label that meets contrast *on* `xSoft`.
  final Color danger;
  final Color dangerSoft;
  final Color dangerText;
  final Color success;
  final Color successSoft;
  final Color successText;
  final Color warning;
  final Color warningSoft;
  final Color warningText;
  final Color info;
  final Color infoSoft;
  final Color infoText;

  /// The single foreground used on any solid status colour.
  final Color onStatus;

  /// Live/recording indicator. Never softened into the mist family — it is a
  /// state, not decoration.
  final Color live;
  final Color onLive;

  /// The media register. Identical in both themes: photo and video surfaces are
  /// true black regardless of the app theme, so their chrome cannot follow it.
  final Color canvas;
  final Color onMedia;
  final Color onMediaMuted;

  /// Mist-tinted chrome drawn *on* media — chips, rails, hairlines. Replaces
  /// the former `glassFill`/`glassBorder`, which were never actually glass
  /// (there was no backdrop blur behind them, only flat translucency).
  final Color mistFill;
  final Color mistLine;

  /// Modal grounds. Flat, never blurred.
  final Color scrim;
  final Color scrimStrong;

  /// Field and control outlines, where an outline is drawn at all.
  final Color input;

  /// The quiet button family — a filled control that is not the primary action.
  final Color secondary;
  final Color secondaryForeground;

  /// The ground behind a modal layer, distinct from [scrim] so an overlay can
  /// sit on a slightly cooler black than a media scrim does.
  final Color overlayScrim;

  /// The light-on-dark inverse of [mistFill] / [mistLine], for chrome drawn on
  /// a *pale* photograph rather than a dark one.
  final Color glassFillLight;
  final Color glassBorderLight;

  /// Categorical data series, in reading order. Neutral by construction: a
  /// chart is information, and information does not need the brand in it.
  final Color chart1;
  final Color chart2;
  final Color chart3;
  final Color chart4;
  final Color chart5;

  /// The sidebar register. A sidebar is its own ground with its own brand ink,
  /// which in dark is lighter than [primary] because it is read as text.
  final Color sidebar;
  final Color sidebarForeground;
  final Color sidebarPrimary;
  final Color sidebarPrimaryForeground;
  final Color sidebarAccent;
  final Color sidebarAccentForeground;
  final Color sidebarBorder;
  final Color sidebarRing;

  /// Backdrop blur radius for glass chrome, in logical pixels. Not a colour, so
  /// it does not vary by theme and is not part of the value identity below.
  static const double glassBlur = 16;

  // ---------------------------------------------------------------------------
  // Specification vocabulary.
  //
  // monokit's specification (monokit.monorithm.dev) is authoritative on token
  // *names*: "where a realization contradicts this site, the realization is what
  // changes". This package grew a parallel vocabulary, so the specified names
  // are published here as aliases onto the roles that already carry the values.
  //
  // The values themselves are deliberately unchanged — several differ from the
  // contract on purpose (this ground is mist where the contract's `background`
  // is white; `mistFill` is a mist tint where `glassFill` is white). Those
  // deltas are written up as amendments rather than silently overwritten, and
  // whichever way each is ruled, the *names* below are the ones to write new
  // code against. The package-specific names are deprecated for 4.0.0.
  // ---------------------------------------------------------------------------

  /// The screen ground. Specified name for [page].
  Color get background => page;

  /// Specified name for [foreground] as read on [card] and [popover].
  Color get cardForeground => foreground;
  Color get popover => elevated;
  Color get popoverForeground => foreground;

  /// Specified names for the text ramp.
  Color get mutedForeground => foregroundMuted;
  Color get mutedText => foregroundSubtle;

  /// Specified name for [fill]. `muted` and `accent` are one value in the
  /// contract, so both resolve here.
  Color get muted => fill;
  Color get accent => fill;
  Color get accentForeground => foreground;

  /// Specified name for [separator].
  Color get border => separator;

  /// Specified names for the brand pair. `primaryText` is brand as *ink*,
  /// which is what [tint] has always been.
  Color get primaryForeground => onPrimary;
  Color get primaryText => tint;

  /// Specified names for the danger family.
  Color get destructive => danger;
  Color get destructiveSoft => dangerSoft;
  Color get destructiveText => dangerText;

  /// The contract carries a foreground per status family; this package carries
  /// one [onStatus] for all four, which is the same colour four times.
  Color get destructiveForeground => onStatus;
  Color get successForeground => onStatus;
  Color get warningForeground => onStatus;
  Color get infoForeground => onStatus;

  /// Specified name for [onLive].
  Color get liveForeground => onLive;

  /// Specified name for [canvas] — the ground the immersion model is defined
  /// against.
  Color get mediaCanvas => canvas;

  /// Specified names for the chrome drawn on media.
  Color get glassFill => mistFill;
  Color get glassBorder => mistLine;

  factory MonokitColors.light() => const MonokitColors(
    page: Color(0xFFF1F3F3),
    card: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    foreground: Color(0xFF090B0C),
    foregroundMuted: Color(0xFF67787C),
    foregroundSubtle: Color(0xFF9CA8AB),
    fill: Color(0x0D090B0C),
    separator: Color(0x14090B0C),
    ring: Color(0xFF9CA8AB),
    tint: Color(0xFF007A55),
    primary: Color(0xFF007A55),
    onPrimary: Color(0xFFECFDF5),
    primarySoft: Color(0xFFCBF3E0),
    danger: Color(0xFFE7000B),
    dangerSoft: Color(0xFFFFE1DB),
    dangerText: Color(0xFF9F0712),
    success: Color(0xFF00A63E),
    successSoft: Color(0xFFD7F9DC),
    successText: Color(0xFF016630),
    warning: Color(0xFFE17100),
    warningSoft: Color(0xFFFFE6CB),
    warningText: Color(0xFF973C00),
    info: Color(0xFF155DFC),
    infoSoft: Color(0xFFDDEFFF),
    infoText: Color(0xFF193CB8),
    onStatus: Color(0xFFFAFAFA),
    live: Color(0xFFFB2C36),
    onLive: Color(0xFFFFFFFF),
    canvas: Color(0xFF000000),
    onMedia: Color(0xFFF9FBFB),
    onMediaMuted: Color(0xB8F9FBFB),
    mistFill: Color(0x1FF1F3F3),
    mistLine: Color(0x42F1F3F3),
    scrim: Color(0x73000000),
    scrimStrong: Color(0x9E000000),
  );

  factory MonokitColors.dark() => const MonokitColors(
    page: Color(0xFF161B1D),
    card: Color(0xFF22292B),
    elevated: Color(0xFF2E3639),
    foreground: Color(0xFFF9FBFB),
    foregroundMuted: Color(0xFF9CA8AB),
    foregroundSubtle: Color(0xFF67787C),
    fill: Color(0x12FFFFFF),
    separator: Color(0x1AFFFFFF),
    ring: Color(0xFF67787C),
    tint: Color(0xFF00BC7D),
    primary: Color(0xFF006045),
    onPrimary: Color(0xFFECFDF5),
    primarySoft: Color(0xFF19342A),
    danger: Color(0xFFFF6467),
    dangerSoft: Color(0xFF3F1919),
    dangerText: Color(0xFFFF6467),
    success: Color(0xFF05DF72),
    successSoft: Color(0xFF0A2E17),
    successText: Color(0xFF05DF72),
    warning: Color(0xFFFFB900),
    warningSoft: Color(0xFF332400),
    warningText: Color(0xFFFFB900),
    info: Color(0xFF51A2FF),
    infoSoft: Color(0xFF14273E),
    infoText: Color(0xFF51A2FF),
    onStatus: Color(0xFF090B0C),
    live: Color(0xFFFB2C36),
    onLive: Color(0xFFFFFFFF),
    canvas: Color(0xFF000000),
    onMedia: Color(0xFFF9FBFB),
    onMediaMuted: Color(0xB8F9FBFB),
    mistFill: Color(0x1FF1F3F3),
    mistLine: Color(0x42F1F3F3),
    scrim: Color(0x99000000),
    scrimStrong: Color(0xBF000000),
    input: Color(0x26FFFFFF),
    secondary: Color(0xFF263033),
    secondaryForeground: Color(0xFFF9FBFB),
    chart4: Color(0xFF9CA8AB),
    chart5: Color(0xFFC7CFD1),
    sidebar: Color(0xFF161B1D),
    sidebarForeground: Color(0xFFF9FBFB),
    sidebarPrimary: Color(0xFF00BC7D),
    sidebarPrimaryForeground: Color(0xFF002C22),
    sidebarAccent: Color(0xFF22292B),
    sidebarAccentForeground: Color(0xFFF9FBFB),
    sidebarBorder: Color(0x1AFFFFFF),
    sidebarRing: Color(0xFF67787C),
  );

  /// Declared once. [==], [hashCode] and [lerp] all derive from this, so adding
  /// a role is a one-line change in two places rather than four.
  ///
  /// The previous implementation built a 51-entry `Map<String, Color>` on every
  /// `==` and `hashCode` call — which ran on every `MonokitTheme`
  /// `updateShouldNotify`.
  List<Color> get _fields => <Color>[
    page,
    card,
    elevated,
    foreground,
    foregroundMuted,
    foregroundSubtle,
    fill,
    separator,
    ring,
    tint,
    primary,
    onPrimary,
    primarySoft,
    danger,
    dangerSoft,
    dangerText,
    success,
    successSoft,
    successText,
    warning,
    warningSoft,
    warningText,
    info,
    infoSoft,
    infoText,
    onStatus,
    live,
    onLive,
    canvas,
    onMedia,
    onMediaMuted,
    mistFill,
    mistLine,
    scrim,
    scrimStrong,
    input,
    secondary,
    secondaryForeground,
    overlayScrim,
    glassFillLight,
    glassBorderLight,
    chart1,
    chart2,
    chart3,
    chart4,
    chart5,
    sidebar,
    sidebarForeground,
    sidebarPrimary,
    sidebarPrimaryForeground,
    sidebarAccent,
    sidebarAccentForeground,
    sidebarBorder,
    sidebarRing,
  ];

  static MonokitColors lerp(
    MonokitColors a,
    MonokitColors b,
    double t,
  ) => MonokitColors(
    page: Color.lerp(a.page, b.page, t)!,
    card: Color.lerp(a.card, b.card, t)!,
    elevated: Color.lerp(a.elevated, b.elevated, t)!,
    foreground: Color.lerp(a.foreground, b.foreground, t)!,
    foregroundMuted: Color.lerp(a.foregroundMuted, b.foregroundMuted, t)!,
    foregroundSubtle: Color.lerp(a.foregroundSubtle, b.foregroundSubtle, t)!,
    fill: Color.lerp(a.fill, b.fill, t)!,
    separator: Color.lerp(a.separator, b.separator, t)!,
    ring: Color.lerp(a.ring, b.ring, t)!,
    tint: Color.lerp(a.tint, b.tint, t)!,
    primary: Color.lerp(a.primary, b.primary, t)!,
    onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
    primarySoft: Color.lerp(a.primarySoft, b.primarySoft, t)!,
    danger: Color.lerp(a.danger, b.danger, t)!,
    dangerSoft: Color.lerp(a.dangerSoft, b.dangerSoft, t)!,
    dangerText: Color.lerp(a.dangerText, b.dangerText, t)!,
    success: Color.lerp(a.success, b.success, t)!,
    successSoft: Color.lerp(a.successSoft, b.successSoft, t)!,
    successText: Color.lerp(a.successText, b.successText, t)!,
    warning: Color.lerp(a.warning, b.warning, t)!,
    warningSoft: Color.lerp(a.warningSoft, b.warningSoft, t)!,
    warningText: Color.lerp(a.warningText, b.warningText, t)!,
    info: Color.lerp(a.info, b.info, t)!,
    infoSoft: Color.lerp(a.infoSoft, b.infoSoft, t)!,
    infoText: Color.lerp(a.infoText, b.infoText, t)!,
    onStatus: Color.lerp(a.onStatus, b.onStatus, t)!,
    live: Color.lerp(a.live, b.live, t)!,
    onLive: Color.lerp(a.onLive, b.onLive, t)!,
    canvas: Color.lerp(a.canvas, b.canvas, t)!,
    onMedia: Color.lerp(a.onMedia, b.onMedia, t)!,
    onMediaMuted: Color.lerp(a.onMediaMuted, b.onMediaMuted, t)!,
    mistFill: Color.lerp(a.mistFill, b.mistFill, t)!,
    mistLine: Color.lerp(a.mistLine, b.mistLine, t)!,
    scrim: Color.lerp(a.scrim, b.scrim, t)!,
    scrimStrong: Color.lerp(a.scrimStrong, b.scrimStrong, t)!,
    input: Color.lerp(a.input, b.input, t)!,
    secondary: Color.lerp(a.secondary, b.secondary, t)!,
    secondaryForeground: Color.lerp(
      a.secondaryForeground,
      b.secondaryForeground,
      t,
    )!,
    overlayScrim: Color.lerp(a.overlayScrim, b.overlayScrim, t)!,
    glassFillLight: Color.lerp(a.glassFillLight, b.glassFillLight, t)!,
    glassBorderLight: Color.lerp(a.glassBorderLight, b.glassBorderLight, t)!,
    chart1: Color.lerp(a.chart1, b.chart1, t)!,
    chart2: Color.lerp(a.chart2, b.chart2, t)!,
    chart3: Color.lerp(a.chart3, b.chart3, t)!,
    chart4: Color.lerp(a.chart4, b.chart4, t)!,
    chart5: Color.lerp(a.chart5, b.chart5, t)!,
    sidebar: Color.lerp(a.sidebar, b.sidebar, t)!,
    sidebarForeground: Color.lerp(a.sidebarForeground, b.sidebarForeground, t)!,
    sidebarPrimary: Color.lerp(a.sidebarPrimary, b.sidebarPrimary, t)!,
    sidebarPrimaryForeground: Color.lerp(
      a.sidebarPrimaryForeground,
      b.sidebarPrimaryForeground,
      t,
    )!,
    sidebarAccent: Color.lerp(a.sidebarAccent, b.sidebarAccent, t)!,
    sidebarAccentForeground: Color.lerp(
      a.sidebarAccentForeground,
      b.sidebarAccentForeground,
      t,
    )!,
    sidebarBorder: Color.lerp(a.sidebarBorder, b.sidebarBorder, t)!,
    sidebarRing: Color.lerp(a.sidebarRing, b.sidebarRing, t)!,
  );

  MonokitColors copyWith({
    Color? page,
    Color? card,
    Color? elevated,
    Color? foreground,
    Color? foregroundMuted,
    Color? foregroundSubtle,
    Color? fill,
    Color? separator,
    Color? ring,
    Color? tint,
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? danger,
    Color? dangerSoft,
    Color? dangerText,
    Color? success,
    Color? successSoft,
    Color? successText,
    Color? warning,
    Color? warningSoft,
    Color? warningText,
    Color? info,
    Color? infoSoft,
    Color? infoText,
    Color? onStatus,
    Color? live,
    Color? onLive,
    Color? canvas,
    Color? onMedia,
    Color? onMediaMuted,
    Color? mistFill,
    Color? mistLine,
    Color? scrim,
    Color? scrimStrong,
    Color? input,
    Color? secondary,
    Color? secondaryForeground,
    Color? overlayScrim,
    Color? glassFillLight,
    Color? glassBorderLight,
    Color? chart1,
    Color? chart2,
    Color? chart3,
    Color? chart4,
    Color? chart5,
    Color? sidebar,
    Color? sidebarForeground,
    Color? sidebarPrimary,
    Color? sidebarPrimaryForeground,
    Color? sidebarAccent,
    Color? sidebarAccentForeground,
    Color? sidebarBorder,
    Color? sidebarRing,
  }) => MonokitColors(
    page: page ?? this.page,
    card: card ?? this.card,
    elevated: elevated ?? this.elevated,
    foreground: foreground ?? this.foreground,
    foregroundMuted: foregroundMuted ?? this.foregroundMuted,
    foregroundSubtle: foregroundSubtle ?? this.foregroundSubtle,
    fill: fill ?? this.fill,
    separator: separator ?? this.separator,
    ring: ring ?? this.ring,
    tint: tint ?? this.tint,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    primarySoft: primarySoft ?? this.primarySoft,
    danger: danger ?? this.danger,
    dangerSoft: dangerSoft ?? this.dangerSoft,
    dangerText: dangerText ?? this.dangerText,
    success: success ?? this.success,
    successSoft: successSoft ?? this.successSoft,
    successText: successText ?? this.successText,
    warning: warning ?? this.warning,
    warningSoft: warningSoft ?? this.warningSoft,
    warningText: warningText ?? this.warningText,
    info: info ?? this.info,
    infoSoft: infoSoft ?? this.infoSoft,
    infoText: infoText ?? this.infoText,
    onStatus: onStatus ?? this.onStatus,
    live: live ?? this.live,
    onLive: onLive ?? this.onLive,
    canvas: canvas ?? this.canvas,
    onMedia: onMedia ?? this.onMedia,
    onMediaMuted: onMediaMuted ?? this.onMediaMuted,
    mistFill: mistFill ?? this.mistFill,
    mistLine: mistLine ?? this.mistLine,
    scrim: scrim ?? this.scrim,
    scrimStrong: scrimStrong ?? this.scrimStrong,
    input: input ?? this.input,
    secondary: secondary ?? this.secondary,
    secondaryForeground: secondaryForeground ?? this.secondaryForeground,
    overlayScrim: overlayScrim ?? this.overlayScrim,
    glassFillLight: glassFillLight ?? this.glassFillLight,
    glassBorderLight: glassBorderLight ?? this.glassBorderLight,
    chart1: chart1 ?? this.chart1,
    chart2: chart2 ?? this.chart2,
    chart3: chart3 ?? this.chart3,
    chart4: chart4 ?? this.chart4,
    chart5: chart5 ?? this.chart5,
    sidebar: sidebar ?? this.sidebar,
    sidebarForeground: sidebarForeground ?? this.sidebarForeground,
    sidebarPrimary: sidebarPrimary ?? this.sidebarPrimary,
    sidebarPrimaryForeground:
        sidebarPrimaryForeground ?? this.sidebarPrimaryForeground,
    sidebarAccent: sidebarAccent ?? this.sidebarAccent,
    sidebarAccentForeground:
        sidebarAccentForeground ?? this.sidebarAccentForeground,
    sidebarBorder: sidebarBorder ?? this.sidebarBorder,
    sidebarRing: sidebarRing ?? this.sidebarRing,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitColors && listEquals(_fields, other._fields));

  @override
  int get hashCode => Object.hashAll(_fields);
}
