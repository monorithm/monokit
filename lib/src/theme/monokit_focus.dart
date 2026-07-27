import 'package:flutter/widgets.dart';

/// Token group describing Monokit's keyboard focus ring geometry.
///
/// The ring color already comes from `MonokitColors.ring`; this group carries
/// the stroke width, the gap between the focused widget and the ring, and the
/// ring's opacity so all three can be tuned by theme or density instead of
/// being hardcoded per component.
///
/// The shadcn web reference paints its focus ring as a 3px band at 50% of the
/// ring color (`ring/50`), so [ringWidth] defaults to 3 and [ringAlpha] to 0.5.
@immutable
class MonokitFocus {
  const MonokitFocus({
    this.ringWidth = 3,
    this.ringOffset = 2,
    this.ringAlpha = 0.5,
  }) : assert(ringAlpha >= 0 && ringAlpha <= 1);

  /// Stroke width of the focus ring, in logical pixels.
  final double ringWidth;

  /// Gap between the focused widget's bounds and the ring, in logical pixels.
  final double ringOffset;

  /// Opacity applied to `MonokitColors.ring` when painting the focus ring,
  /// as a 0–1 fraction. Matches the reference's `ring/50`.
  final double ringAlpha;

  /// Builds the focus/validation ring as a solid outset band, so every control
  /// draws the ring identically from these tokens instead of hardcoding the
  /// color, spread, and opacity per widget.
  ///
  /// [color] is normally `MonokitColors.ring`; pass `MonokitColors.destructive`
  /// with [alpha] `0.2` for the invalid-state ring (the reference's
  /// `ring-destructive/20`). [alpha] defaults to [ringAlpha].
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
  }) => MonokitFocus(
    ringWidth: ringWidth ?? this.ringWidth,
    ringOffset: ringOffset ?? this.ringOffset,
    ringAlpha: ringAlpha ?? this.ringAlpha,
  );

  @override
  bool operator ==(Object other) =>
      other is MonokitFocus &&
      ringWidth == other.ringWidth &&
      ringOffset == other.ringOffset &&
      ringAlpha == other.ringAlpha;

  @override
  int get hashCode => Object.hash(ringWidth, ringOffset, ringAlpha);
}
