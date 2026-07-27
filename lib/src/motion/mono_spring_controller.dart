import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Drives a single value on a spring, preserving velocity across retargets.
///
/// This is the difference between an animation that *looks* physical and one
/// that *is*. A `CurvedAnimation` re-entered mid-flight restarts its curve from
/// the current value with zero velocity, which is the classic
/// ease-in-from-a-moving-value artifact. [animateTo] instead seeds the running
/// [velocity] into the new simulation, so a sheet grabbed halfway through its
/// dismissal keeps moving in the direction your finger was already carrying it.
///
/// Typical use is drag-then-release:
///
/// ```dart
/// void onDragUpdate(DragUpdateDetails d) =>
///     controller.jumpTo(controller.value - d.primaryDelta! / extent);
///
/// void onDragEnd(DragEndDetails d) {
///   final v = -d.velocity.pixelsPerSecond.dy / extent;
///   controller.animateTo(
///     nearestDetent(monoProject(controller.value, v)),
///     withVelocity: v,
///     spring: theme.motion.spatial,
///   );
/// }
/// ```
///
/// Pass a null `spring` to jump — that is how reduced motion is honoured
/// (see `MonokitMotion.reducedSpring`).
class MonoSpringController extends ChangeNotifier {
  MonoSpringController({
    required TickerProvider vsync,
    double value = 0,
    this.lowerBound = double.negativeInfinity,
    this.upperBound = double.infinity,
  }) : _controller = AnimationController.unbounded(vsync: vsync, value: value) {
    _controller.addListener(notifyListeners);
  }

  final AnimationController _controller;

  /// Soft bounds used by [animateTo] targets; the controller itself is
  /// unbounded so a drag can rubber-band past them.
  final double lowerBound;
  final double upperBound;

  /// The current value.
  double get value => _controller.value;

  /// Velocity carried over from a [stop] so the next [animateTo] can resume
  /// from it. `AnimationController.velocity` reads 0 once stopped, so without
  /// this a re-grab would restart from rest.
  double _retainedVelocity = 0;

  /// The current velocity, in value-units per second.
  ///
  /// Live while animating; after [stop] it reports the velocity the motion was
  /// carrying, so a gesture handler can hand it straight back to [animateTo].
  double get velocity =>
      _controller.isAnimating ? _controller.velocity : _retainedVelocity;

  bool get isAnimating => _controller.isAnimating;

  /// Exposed for driving transitions and `AnimatedBuilder`.
  Animation<double> get animation => _controller.view;

  /// Sets the value with no animation. Use while a drag is in progress.
  ///
  /// Clears the retained velocity: once a finger is driving the value, whatever
  /// the spring was doing beforehand is no longer relevant.
  void jumpTo(double newValue) {
    _retainedVelocity = 0;
    _controller.value = newValue;
  }

  /// Stops in place, retaining velocity for the next [animateTo] — which is
  /// what makes grabbing a moving sheet feel continuous rather than sticky.
  void stop() {
    _retainedVelocity = _controller.isAnimating ? _controller.velocity : 0;
    _controller.stop();
  }

  /// Springs to [target].
  ///
  /// [withVelocity] seeds the simulation; when omitted the current [velocity]
  /// carries over. A null [spring] jumps instead of animating, which is how
  /// reduced motion is honoured.
  TickerFuture animateTo(
    double target, {
    double? withVelocity,
    SpringDescription? spring,
  }) {
    final seed = withVelocity ?? velocity;
    _retainedVelocity = 0;
    if (spring == null) {
      _controller.stop();
      _controller.value = target;
      return TickerFuture.complete();
    }
    return _controller.animateWith(
      SpringSimulation(spring, _controller.value, target, seed),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    _controller.dispose();
    super.dispose();
  }
}

/// Where a fling would come to rest.
///
/// Used to pick a detent, a page, or whether a dismissal completes: decide
/// against the *projected* position rather than the position at the instant the
/// finger lifted. Releasing a sheet at 55% while flicking hard downward should
/// dismiss it, not snap it back up to the nearest stop.
///
/// [decelerationRate] is seconds of travel to project; 0.12 approximates a
/// natural flick.
double monoProject(
  double position,
  double velocity, {
  double decelerationRate = 0.12,
}) => position + velocity * decelerationRate;

/// Resistance applied when dragging past a bound.
///
/// Returns the *displayed* overshoot for a raw [overshoot], asymptotically
/// approaching [dimension] so the surface never runs away from the finger.
/// This is what makes an over-dragged sheet or an over-scrolled list feel
/// attached rather than clamped.
double monoRubberBand(
  double overshoot,
  double dimension, {
  double coefficient = 0.55,
}) {
  if (overshoot == 0 || dimension <= 0) return 0;
  final magnitude = overshoot.abs();
  final resisted =
      (1 - (1 / (magnitude * coefficient / dimension + 1))) * dimension;
  return overshoot.isNegative ? -resisted : resisted;
}

/// The element of [candidates] closest to [target].
double monoNearest(Iterable<double> candidates, double target) {
  var best = candidates.first;
  var bestDistance = (best - target).abs();
  for (final candidate in candidates.skip(1)) {
    final distance = (candidate - target).abs();
    if (distance < bestDistance) {
      bestDistance = distance;
      best = candidate;
    }
  }
  return best;
}
