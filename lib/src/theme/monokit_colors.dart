import 'package:flutter/widgets.dart';

/// Semantic color tokens used by every Monokit component.
///
/// The values deliberately use sRGB hex literals so the Flutter package has
/// the same stable palette on every platform.
class MonokitColors {
  const MonokitColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.border,
    required this.input,
    required this.ring,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color border;
  final Color input;
  final Color ring;

  factory MonokitColors.light() => const MonokitColors(
    background: Color(0xFFFAFAFA),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    cardForeground: Color(0xFF09090B),
    popover: Color(0xFFFFFFFF),
    popoverForeground: Color(0xFF09090B),
    primary: Color(0xFF18181B),
    primaryForeground: Color(0xFFFAFAFA),
    secondary: Color(0xFFF4F4F5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717A),
    accent: Color(0xFFF4F4F5),
    accentForeground: Color(0xFF18181B),
    destructive: Color(0xFFEF4444),
    border: Color(0xFFE4E4E7),
    input: Color(0xFFE4E4E7),
    ring: Color(0xFF18181B),
  );

  factory MonokitColors.dark() => const MonokitColors(
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    card: Color(0xFF18181B),
    cardForeground: Color(0xFFFAFAFA),
    popover: Color(0xFF18181B),
    popoverForeground: Color(0xFFFAFAFA),
    primary: Color(0xFFFAFAFA),
    primaryForeground: Color(0xFF18181B),
    secondary: Color(0xFF27272A),
    secondaryForeground: Color(0xFFFAFAFA),
    muted: Color(0xFF27272A),
    mutedForeground: Color(0xFFA1A1AA),
    accent: Color(0xFF27272A),
    accentForeground: Color(0xFFFAFAFA),
    destructive: Color(0xFF7F1D1D),
    border: Color(0xFF27272A),
    input: Color(0xFF27272A),
    ring: Color(0xFFD4D4D8),
  );

  MonokitColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? border,
    Color? input,
    Color? ring,
  }) {
    return MonokitColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
    );
  }

  static MonokitColors lerp(MonokitColors a, MonokitColors b, double t) {
    Color blend(Color first, Color second) => Color.lerp(first, second, t)!;
    return MonokitColors(
      background: blend(a.background, b.background),
      foreground: blend(a.foreground, b.foreground),
      card: blend(a.card, b.card),
      cardForeground: blend(a.cardForeground, b.cardForeground),
      popover: blend(a.popover, b.popover),
      popoverForeground: blend(a.popoverForeground, b.popoverForeground),
      primary: blend(a.primary, b.primary),
      primaryForeground: blend(a.primaryForeground, b.primaryForeground),
      secondary: blend(a.secondary, b.secondary),
      secondaryForeground: blend(a.secondaryForeground, b.secondaryForeground),
      muted: blend(a.muted, b.muted),
      mutedForeground: blend(a.mutedForeground, b.mutedForeground),
      accent: blend(a.accent, b.accent),
      accentForeground: blend(a.accentForeground, b.accentForeground),
      destructive: blend(a.destructive, b.destructive),
      border: blend(a.border, b.border),
      input: blend(a.input, b.input),
      ring: blend(a.ring, b.ring),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonokitColors &&
        background == other.background &&
        foreground == other.foreground &&
        card == other.card &&
        cardForeground == other.cardForeground &&
        popover == other.popover &&
        popoverForeground == other.popoverForeground &&
        primary == other.primary &&
        primaryForeground == other.primaryForeground &&
        secondary == other.secondary &&
        secondaryForeground == other.secondaryForeground &&
        muted == other.muted &&
        mutedForeground == other.mutedForeground &&
        accent == other.accent &&
        accentForeground == other.accentForeground &&
        destructive == other.destructive &&
        border == other.border &&
        input == other.input &&
        ring == other.ring;
  }

  @override
  int get hashCode => Object.hashAll(<Object>[
    background,
    foreground,
    card,
    cardForeground,
    popover,
    popoverForeground,
    primary,
    primaryForeground,
    secondary,
    secondaryForeground,
    muted,
    mutedForeground,
    accent,
    accentForeground,
    destructive,
    border,
    input,
    ring,
  ]);
}
