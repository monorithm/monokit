import 'package:flutter/widgets.dart';

/// Token group describing Monokit's focus ring geometry **and** its focus
/// dismissal policy.
///
/// The ring color already comes from `MonokitColors.ring`; this group carries
/// the stroke width, the gap between the focused widget and the ring, and the
/// ring's opacity so all three can be tuned by theme or density instead of
/// being hardcoded per component.
///
/// `contract/interaction.json` has carried these numbers since it was written:
/// a `focusRing` group of width 2 and offset 2, *"painted OUTSIDE the
/// control's bounds so it never shifts layout, and bound to focus-visible
/// only."* All three clauses went unimplemented - the width was 3, the offset
/// was applied by nothing, and every control showed the ring on pointer focus.
///
/// It is an outline with a transparent gap, not a translucent band sitting on
/// the edge: the gap is what separates the ring from the control it marks, and
/// a ring that starts at the border box reads as a thicker border instead.
///
/// [dismissKeyboardOnTapOutside] is the one behavioral token here. It lives
/// alongside the ring on purpose: this group is the system's answer to "what
/// does focus do", and for a long time it only answered "what does focus look
/// like" — which is how tap-away-to-dismiss ended up with no owner at all.
@immutable
class MonokitFocus {
  const MonokitFocus({
    this.ringWidth = 2,
    this.ringOffset = 2,
    this.ringAlpha = 1.0,
    this.dismissKeyboardOnTapOutside = true,
  }) : assert(ringAlpha >= 0 && ringAlpha <= 1);

  /// Stroke width of the focus ring, in logical pixels.
  final double ringWidth;

  /// Gap between the focused widget's bounds and the ring, in logical pixels.
  final double ringOffset;

  /// Opacity applied to `MonokitColors.ring` when painting the focus ring,
  /// as a 0–1 fraction. Matches the reference's `ring/50`.
  final double ringAlpha;

  /// Whether a pointer-down outside a focused text field drops its focus, and
  /// with it the software keyboard.
  ///
  /// Flutter's own default only does this on desktop, on the web, or for a
  /// non-touch pointer — on native Android/iOS a finger tap outside a field is
  /// deliberately ignored by the framework, which leaves the keyboard up until
  /// something else takes focus. Monokit opts in by default, because a design
  /// system that pads its screens around `viewInsets` should also be able to
  /// put the keyboard away.
  ///
  /// "Outside" is computed by the framework's `TextFieldTapRegion` grouping, so
  /// moving between two fields, or tapping a combobox/command-palette panel,
  /// never counts as outside. Set false to restore Flutter's default, or
  /// override a single field with `MonoInput.dismissKeyboardOnTapOutside`.
  final bool dismissKeyboardOnTapOutside;

  /// Builds the focus/validation ring as a solid outset band, so every control
  /// draws the ring identically from these tokens instead of hardcoding the
  /// color, spread, and opacity per widget.
  ///
  /// [color] is normally `MonokitColors.ring`; pass `MonokitColors.destructive`
  /// with [alpha] `0.2` for the invalid-state ring (the reference's
  /// `ring-destructive/20`). [alpha] defaults to [ringAlpha].
  ///
  /// **This form cannot honour [ringOffset].** A `BoxShadow`'s spread starts at
  /// the border box, so the band always touches the control and the gap the
  /// Atlas specifies is unrepresentable. Controls that need the gap wrap
  /// themselves in `MonoFocusRingOverlay`, which paints outside the bounds
  /// without taking part in layout. This stays for controls whose ring sits
  /// flush, and so the token plumbing does not break underneath them.
  List<BoxShadow> ringShadow(Color color, {double? alpha}) => <BoxShadow>[
    BoxShadow(
      color: color.withValues(alpha: alpha ?? ringAlpha),
      blurRadius: 0,
      spreadRadius: ringWidth,
    ),
  ];

  MonokitFocus copyWith({
    double? ringWidth,
    double? ringOffset,
    double? ringAlpha,
    bool? dismissKeyboardOnTapOutside,
  }) => MonokitFocus(
    ringWidth: ringWidth ?? this.ringWidth,
    ringOffset: ringOffset ?? this.ringOffset,
    ringAlpha: ringAlpha ?? this.ringAlpha,
    dismissKeyboardOnTapOutside:
        dismissKeyboardOnTapOutside ?? this.dismissKeyboardOnTapOutside,
  );

  @override
  bool operator ==(Object other) =>
      other is MonokitFocus &&
      ringWidth == other.ringWidth &&
      ringOffset == other.ringOffset &&
      ringAlpha == other.ringAlpha &&
      dismissKeyboardOnTapOutside == other.dismissKeyboardOnTapOutside;

  @override
  int get hashCode => Object.hash(
    ringWidth,
    ringOffset,
    ringAlpha,
    dismissKeyboardOnTapOutside,
  );
}
