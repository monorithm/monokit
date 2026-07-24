import 'package:flutter/foundation.dart';

/// Token group describing Monokit's keyboard focus ring geometry.
///
/// The ring color already comes from `MonokitColors.ring`; this group carries
/// the stroke width and the gap between the focused widget and the ring so both
/// can be tuned by theme or density instead of being hardcoded per component.
@immutable
class MonokitFocus {
  const MonokitFocus({this.ringWidth = 2, this.ringOffset = 2});

  /// Stroke width of the focus ring, in logical pixels.
  final double ringWidth;

  /// Gap between the focused widget's bounds and the ring, in logical pixels.
  final double ringOffset;

  MonokitFocus copyWith({double? ringWidth, double? ringOffset}) =>
      MonokitFocus(
        ringWidth: ringWidth ?? this.ringWidth,
        ringOffset: ringOffset ?? this.ringOffset,
      );

  @override
  bool operator ==(Object other) =>
      other is MonokitFocus &&
      ringWidth == other.ringWidth &&
      ringOffset == other.ringOffset;

  @override
  int get hashCode => Object.hash(ringWidth, ringOffset);
}
