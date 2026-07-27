import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Monokit's semantic colour roles.
///
/// The palette is **emerald on mist**, and the surface model is **grouped**:
/// one thing is in focus at a time, and surfaces separate by *luminance step*
/// rather than by hairline. That is why there is a [page] → [card] → [elevated]
/// ladder and no `border` role — [separator] exists to divide content *within*
/// a surface, not to outline the surface itself.
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
  ];

  static MonokitColors lerp(MonokitColors a, MonokitColors b, double t) =>
      MonokitColors(
        page: Color.lerp(a.page, b.page, t)!,
        card: Color.lerp(a.card, b.card, t)!,
        elevated: Color.lerp(a.elevated, b.elevated, t)!,
        foreground: Color.lerp(a.foreground, b.foreground, t)!,
        foregroundMuted: Color.lerp(a.foregroundMuted, b.foregroundMuted, t)!,
        foregroundSubtle: Color.lerp(
          a.foregroundSubtle,
          b.foregroundSubtle,
          t,
        )!,
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
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitColors && listEquals(_fields, other._fields));

  @override
  int get hashCode => Object.hashAll(_fields);
}
