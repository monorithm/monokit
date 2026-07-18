import 'package:flutter/widgets.dart';

/// Shared logical placement vocabulary for anchored surfaces.
enum MonoPlacement {
  top,
  topStart,
  topEnd,
  right,
  rightStart,
  rightEnd,
  bottom,
  bottomStart,
  bottomEnd,
  left,
  leftStart,
  leftEnd,
}

/// Collision-aware placement: flips a placement to the opposite side when the
/// preferred side would overflow the viewport.
extension MonoPlacementCollision on MonoPlacement {
  /// The mirror placement across the trigger (keeping start/end alignment).
  MonoPlacement get opposite => switch (this) {
    MonoPlacement.top => MonoPlacement.bottom,
    MonoPlacement.topStart => MonoPlacement.bottomStart,
    MonoPlacement.topEnd => MonoPlacement.bottomEnd,
    MonoPlacement.bottom => MonoPlacement.top,
    MonoPlacement.bottomStart => MonoPlacement.topStart,
    MonoPlacement.bottomEnd => MonoPlacement.topEnd,
    MonoPlacement.left => MonoPlacement.right,
    MonoPlacement.leftStart => MonoPlacement.rightStart,
    MonoPlacement.leftEnd => MonoPlacement.rightEnd,
    MonoPlacement.right => MonoPlacement.left,
    MonoPlacement.rightStart => MonoPlacement.leftStart,
    MonoPlacement.rightEnd => MonoPlacement.leftEnd,
  };

  bool get _isBottom =>
      this == MonoPlacement.bottom ||
      this == MonoPlacement.bottomStart ||
      this == MonoPlacement.bottomEnd;
  bool get _isTop =>
      this == MonoPlacement.top ||
      this == MonoPlacement.topStart ||
      this == MonoPlacement.topEnd;
  bool get _isRight =>
      this == MonoPlacement.right ||
      this == MonoPlacement.rightStart ||
      this == MonoPlacement.rightEnd;
  bool get _isLeft =>
      this == MonoPlacement.left ||
      this == MonoPlacement.leftStart ||
      this == MonoPlacement.leftEnd;

  /// Returns this placement, or its [opposite], so an overlay of the given
  /// [estimate] extent (along the placement axis) anchored to [target] stays
  /// within [viewport]. Only flips when the preferred side overflows *and* the
  /// opposite side has room, so a cramped viewport keeps the preferred side.
  MonoPlacement resolveWithin(
    Rect target,
    Size viewport, {
    double estimate = 240,
  }) {
    if (_isBottom &&
        target.bottom + estimate > viewport.height &&
        target.top - estimate >= 0) {
      return opposite;
    }
    if (_isTop &&
        target.top - estimate < 0 &&
        target.bottom + estimate <= viewport.height) {
      return opposite;
    }
    if (_isRight &&
        target.right + estimate > viewport.width &&
        target.left - estimate >= 0) {
      return opposite;
    }
    if (_isLeft &&
        target.left - estimate < 0 &&
        target.right + estimate <= viewport.width) {
      return opposite;
    }
    return this;
  }
}

@immutable
class MonoPlacementAnchors {
  const MonoPlacementAnchors(this.target, this.follower);
  final Alignment target;
  final Alignment follower;

  factory MonoPlacementAnchors.resolve(
    MonoPlacement placement,
    TextDirection direction,
  ) {
    final start = direction == TextDirection.ltr ? -1.0 : 1.0;
    final end = -start;
    return switch (placement) {
      MonoPlacement.top => const MonoPlacementAnchors(
        Alignment.topCenter,
        Alignment.bottomCenter,
      ),
      MonoPlacement.topStart => MonoPlacementAnchors(
        Alignment(start, -1),
        Alignment(start, 1),
      ),
      MonoPlacement.topEnd => MonoPlacementAnchors(
        Alignment(end, -1),
        Alignment(end, 1),
      ),
      MonoPlacement.right => const MonoPlacementAnchors(
        Alignment.centerRight,
        Alignment.centerLeft,
      ),
      MonoPlacement.rightStart => const MonoPlacementAnchors(
        Alignment.topRight,
        Alignment.topLeft,
      ),
      MonoPlacement.rightEnd => const MonoPlacementAnchors(
        Alignment.bottomRight,
        Alignment.bottomLeft,
      ),
      MonoPlacement.bottom => const MonoPlacementAnchors(
        Alignment.bottomCenter,
        Alignment.topCenter,
      ),
      MonoPlacement.bottomStart => MonoPlacementAnchors(
        Alignment(start, 1),
        Alignment(start, -1),
      ),
      MonoPlacement.bottomEnd => MonoPlacementAnchors(
        Alignment(end, 1),
        Alignment(end, -1),
      ),
      MonoPlacement.left => const MonoPlacementAnchors(
        Alignment.centerLeft,
        Alignment.centerRight,
      ),
      MonoPlacement.leftStart => const MonoPlacementAnchors(
        Alignment.topLeft,
        Alignment.topRight,
      ),
      MonoPlacement.leftEnd => const MonoPlacementAnchors(
        Alignment.bottomLeft,
        Alignment.bottomRight,
      ),
    };
  }
}
