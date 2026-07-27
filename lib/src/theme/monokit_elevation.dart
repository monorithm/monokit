import 'package:flutter/widgets.dart';

/// Semantic surface depth.
///
/// Three tiers, because there are only three behaviours. The previous
/// `MonoElevationTier` declared five (`e0`..`e4`) of which `e0`≡`e1` and
/// `e3`≡`e4` resolved to identical shadows — five names for three results,
/// and `MonoCard`'s default `e1` silently rendered no shadow at all.
///
/// Under the **grouped** surface model [flat] is the common case: depth comes
/// from the `page` → `card` luminance step, not from a shadow. Reach for
/// [raised] and [floating] only when something genuinely floats above the
/// page — a menu, a popover, a dialog, a sheet.
enum MonoElevation {
  /// No shadow. The surface's own colour does the separating.
  flat,

  /// Sits just above the page — anchored overlays, a lifted card.
  raised,

  /// Genuinely floating and modal-adjacent — dialogs, sheets, drawers.
  floating,
}

@immutable
final class MonokitElevation {
  const MonokitElevation({required this.shadowColor});

  /// Derived from the theme rather than fixed. The old implementation hardcoded
  /// `0x29090B0C` in both modes, so dark-mode shadows were a translucent
  /// near-black over an already-dark ground and read as nothing.
  final Color shadowColor;

  factory MonokitElevation.light() =>
      const MonokitElevation(shadowColor: Color(0x1A090B0C));

  factory MonokitElevation.dark() =>
      const MonokitElevation(shadowColor: Color(0x66000000));

  List<BoxShadow> resolve(MonoElevation elevation) => switch (elevation) {
    MonoElevation.flat => const <BoxShadow>[],
    MonoElevation.raised => <BoxShadow>[
      BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 4)),
    ],
    MonoElevation.floating => <BoxShadow>[
      BoxShadow(
        color: shadowColor,
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ],
  };

  static MonokitElevation lerp(
    MonokitElevation a,
    MonokitElevation b,
    double t,
  ) => MonokitElevation(
    shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
  );

  MonokitElevation copyWith({Color? shadowColor}) =>
      MonokitElevation(shadowColor: shadowColor ?? this.shadowColor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitElevation && shadowColor == other.shadowColor);

  @override
  int get hashCode => shadowColor.hashCode;
}
