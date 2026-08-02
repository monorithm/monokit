import 'package:flutter/widgets.dart';

/// Shared motion tokens: *"physics for moments, curves for chrome."*
///
/// Chrome, color, and opacity animate on **curves** (default [standard] /
/// [monoOut]); genuine expressive moments — a confirmed outcome, going live —
/// animate on **springs** ([spatial] / [effect] / [celebrate]).
/// Components should pull from here rather than hand-rolling durations.
@immutable
class MonokitMotion {
  const MonokitMotion({
    this.instant = const Duration(milliseconds: 50),
    this.fast = const Duration(milliseconds: 100),
    this.base = const Duration(milliseconds: 150),
    this.moderate = const Duration(milliseconds: 220),
    this.slow = const Duration(milliseconds: 300),
    this.slower = const Duration(milliseconds: 400),
    this.slowest = const Duration(milliseconds: 600),
    this.standard = _standard,
    this.monoOut = _monoOut,
    this.decelerate = _decelerate,
    this.accelerate = _accelerate,
    this.emphasized = _emphasized,
    this.linear = Curves.linear,
  });

  // --- Durations (canonical ladder) ------------------------------------------
  final Duration instant;
  final Duration fast;
  final Duration base;
  final Duration moderate;
  final Duration slow;
  final Duration slower;
  final Duration slowest;

  // --- Curves ----------------------------------------------------------------
  /// Neutral standard easing for most chrome.
  final Curve standard;

  /// The signature Monokit deceleration — `Cubic(0.23, 1, 0.32, 1)`.
  final Curve monoOut;

  /// Enters: strong deceleration.
  final Curve decelerate;

  /// Exits: acceleration (run one step shorter than the matching enter).
  final Curve accelerate;

  /// Emphasized in-out for larger coordinated moves.
  final Curve emphasized;

  final Curve linear;

  static const Curve _standard = Cubic(0.2, 0, 0, 1);
  static const Curve _monoOut = Cubic(0.23, 1, 0.32, 1);
  static const Curve _decelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve _accelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const Curve _emphasized = Curves.easeInOutCubic;

  // --- Springs ---------------------------------------------------------------
  //
  // These were previously non-overridable getters with zero call sites — the
  // doctrine was documented but never implemented. They are now constructor
  // fields, so a host can retune them, and `MonoSpringController` consumes
  // them for every spatial animation in the library.

  /// Position, scale and offset — sheets, drawers, pushes, indicators.
  /// The default for anything that moves in space.
  SpringDescription get spatial => _spring(stiffness: 700, ratio: 0.9);

  /// Snappier, critically damped — toggles and small pops that should land
  /// without any visible settle.
  SpringDescription get effect => _spring(stiffness: 1600, ratio: 1);

  /// The one under-damped spring in the system. Reserved for a confirmed
  /// outcome; it is the only place an overshoot is allowed.
  SpringDescription get celebrate => _spring(stiffness: 550, ratio: 0.75);

  static SpringDescription _spring({
    required double stiffness,
    required double ratio,
  }) => SpringDescription.withDampingRatio(
    mass: 1,
    stiffness: stiffness,
    ratio: ratio,
  );

  // --- Loop durations --------------------------------------------------------
  Duration get spinnerLoop => const Duration(milliseconds: 800);
  Duration get shimmerLoop => const Duration(milliseconds: 1200);
  Duration get progressLoop => const Duration(milliseconds: 1200);
  Duration get pulseLoop => const Duration(milliseconds: 2000);

  // --- Reduced motion --------------------------------------------------------
  //
  // This is THE accessibility contract, and it must be the only path. It used
  // to be honoured at 6 sites while ~25 others re-implemented
  // `MediaQuery.maybeOf(context)?.disableAnimations ?? false` inline, and most
  // implicit animations ignored it entirely. A source test now fails the build
  // if `disableAnimations` is referenced anywhere outside this file.

  /// Whether the platform has asked for reduced motion.
  static bool noAnimation(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  /// Collapses [d] to [Duration.zero] under reduced motion.
  Duration reduced(BuildContext context, Duration d) =>
      noAnimation(context) ? Duration.zero : d;

  /// Returns `null` under reduced motion. [MonoSpringController] treats a null
  /// spring as "jump to the target", so passing this through is all a component
  /// needs to do to honour the setting.
  SpringDescription? reducedSpring(
    BuildContext context,
    SpringDescription spring,
  ) => noAnimation(context) ? null : spring;

  // --- Semantic aliases ------------------------------------------------------
  Duration get pressFeedback => fast;
  Duration get enter => base;
  Duration get exit => fast;
  Duration get modalEnter => moderate;
  Duration get modalExit => base;
  Duration get indicator => base;
  Duration get disclosure => base;

  // --- Convenience aliases (kept for ergonomic call sites) --------------------
  Duration get duration => base;
  Curve get curve => standard;
  Curve get emphasizedCurve => emphasized;

  MonokitMotion copyWith({
    Duration? instant,
    Duration? fast,
    Duration? base,
    Duration? moderate,
    Duration? slow,
    Duration? slower,
    Duration? slowest,
    Curve? standard,
    Curve? monoOut,
    Curve? decelerate,
    Curve? accelerate,
    Curve? emphasized,
    Curve? linear,
  }) {
    return MonokitMotion(
      instant: instant ?? this.instant,
      fast: fast ?? this.fast,
      base: base ?? this.base,
      moderate: moderate ?? this.moderate,
      slow: slow ?? this.slow,
      slower: slower ?? this.slower,
      slowest: slowest ?? this.slowest,
      standard: standard ?? this.standard,
      monoOut: monoOut ?? this.monoOut,
      decelerate: decelerate ?? this.decelerate,
      accelerate: accelerate ?? this.accelerate,
      emphasized: emphasized ?? this.emphasized,
      linear: linear ?? this.linear,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MonokitMotion &&
      instant == other.instant &&
      fast == other.fast &&
      base == other.base &&
      moderate == other.moderate &&
      slow == other.slow &&
      slower == other.slower &&
      slowest == other.slowest &&
      standard == other.standard &&
      monoOut == other.monoOut &&
      decelerate == other.decelerate &&
      accelerate == other.accelerate &&
      emphasized == other.emphasized &&
      linear == other.linear;

  @override
  int get hashCode => Object.hash(
    instant,
    fast,
    base,
    moderate,
    slow,
    slower,
    slowest,
    standard,
    monoOut,
    decelerate,
    accelerate,
    emphasized,
    linear,
  );
}
