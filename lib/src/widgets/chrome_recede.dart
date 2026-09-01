import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// How chrome behaves over media on a given screen.
///
/// **Chosen up front, per screen, never per component.** Every control on one
/// surface recedes together or not at all; a rail that stays while a bar
/// leaves is two policies on one screen, and the user cannot learn either.
enum MonoChromePolicy {
  /// Always visible. Live viewing, and calls in a grid — it never auto-hides,
  /// not even on a long watch.
  persistent,

  /// Hides after the idle delay, returns on intent. The feed, the single
  /// player, the gallery, the reader, a full-screen call.
  ///
  /// **The feed is Resting**, which diverges from the specification: that
  /// files feed browsing under [persistent]. Recorded rather than silently
  /// followed.
  resting,

  /// Absent until summoned. Camera pre-roll, screening, preview.
  hidden,
}

/// The edge a chrome layer belongs to, and therefore the direction a *timed*
/// recede travels as it fades.
enum MonoChromeEdge { top, bottom, start, end }

/// Why chrome is not currently showing.
enum MonoChromeCause {
  /// It is showing.
  none,

  /// The idle delay elapsed. Fades **and translates** toward its edge.
  timed,

  /// The viewer is holding the media. Fades **without moving at all**, so on
  /// release every control is exactly where the thumb left it.
  ///
  /// That is a deliberate divergence: the specification gives recede a small
  /// translation toward the edge. A momentary peek keeps its position, because
  /// the finger is still on the glass and about to lift.
  held,

  /// The policy is [MonoChromePolicy.hidden] and nothing has summoned it.
  unsummoned,
}

/// The resolved chrome state, read by [MonoChrome].
@immutable
class MonoChromeVisibility {
  const MonoChromeVisibility({required this.visible, required this.cause});

  final bool visible;
  final MonoChromeCause cause;

  @override
  bool operator ==(Object other) =>
      other is MonoChromeVisibility &&
      visible == other.visible &&
      cause == other.cause;

  @override
  int get hashCode => Object.hash(visible, cause);
}

/// Owns the recede policy for one media surface, and the gesture that clears
/// it.
///
/// **Hold to clear is a sustain, not a toggle.** The screen is clear only
/// while the finger is down and the chrome is back on release. That keeps
/// long-press inside its two sanctioned meanings — content opens a context
/// menu, a held control sustains an action — and does not invent a third.
///
/// One capability, three idioms:
///
/// * **Touch** — hold anywhere on the media. Everything goes invisible while
///   held and returns on release. An accelerator for a control that already
///   exists, never the only path.
/// * **Pointer** — no hold at all. Chrome rests on its own after the idle
///   delay and returns on pointer movement: the same clearing, ambient rather
///   than asked for.
/// * **Keyboard** — a hold has no keyboard shape, because a held key repeats.
///   It becomes a toggle on the control that already exists, and while chrome
///   is hidden the first key returns it and is consumed.
class MonoChromeScope extends StatefulWidget {
  const MonoChromeScope({
    super.key,
    required this.child,
    this.policy = MonoChromePolicy.resting,
    this.idleDelay = const Duration(seconds: 10),
    this.subject,
    this.inhibited = false,
    this.summoned = false,
  });

  final Widget child;
  final MonoChromePolicy policy;

  /// How long the viewer must linger before chrome rests.
  ///
  /// Defaults to the ten seconds an immersive item holds, and that is not a
  /// coincidence: chrome holds for the item's whole clock and rests only when
  /// the viewer stays past it, so the delay never cuts an item short. The meta
  /// line depends on it — its two facts need the full ten seconds, and a rest
  /// at three would bury the second one.
  final Duration idleDelay;

  /// Identifies the current item. **Changing it resets the timer**: advancing
  /// is a new subject, and a new subject arrives with its chrome.
  final Object? subject;

  /// Holds chrome visible regardless of policy.
  ///
  /// Pass true while any of these is true, all of which the board names:
  /// paused or buffering, an overlay is open, a field in chrome has focus, or
  /// a pointer hovers a control. Assistive technology is handled here rather
  /// than by the caller — when it is active the policy is persistent, full
  /// stop.
  final bool inhibited;

  /// For [MonoChromePolicy.hidden]: whether chrome has been summoned.
  final bool summoned;

  static MonoChromeVisibility of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_MonoChromeScopeData>()
          ?.visibility ??
      const MonoChromeVisibility(visible: true, cause: MonoChromeCause.none);

  @override
  State<MonoChromeScope> createState() => _MonoChromeScopeState();
}

class _MonoChromeScopeState extends State<MonoChromeScope> {
  Timer? _idle;
  bool _rested = false;
  bool _held = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart();
  }

  @override
  void didUpdateWidget(covariant MonoChromeScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subject != widget.subject) {
      // A new subject arrives with its chrome.
      _rested = false;
    }
    if (oldWidget.policy != widget.policy ||
        oldWidget.idleDelay != widget.idleDelay ||
        oldWidget.inhibited != widget.inhibited ||
        oldWidget.subject != widget.subject) {
      _restart();
    }
  }

  @override
  void dispose() {
    _idle?.cancel();
    super.dispose();
  }

  /// True when nothing may auto-hide: assistive technology is active, or the
  /// caller reports a condition that holds chrome up.
  bool get _pinned =>
      widget.inhibited || MediaQuery.accessibleNavigationOf(context);

  void _restart() {
    _idle?.cancel();
    _idle = null;
    if (widget.policy != MonoChromePolicy.resting || _pinned) {
      if (_rested) setState(() => _rested = false);
      return;
    }
    _idle = Timer(widget.idleDelay, () {
      if (mounted) setState(() => _rested = true);
    });
  }

  /// Any intent returns chrome and restarts the clock: a pointer moving, a
  /// tap, a key.
  void _wake() {
    if (_rested) setState(() => _rested = false);
    _restart();
  }

  void _setHeld(bool value) {
    if (_held == value) return;
    setState(() => _held = value);
    if (!value) _restart();
  }

  MonoChromeVisibility get _visibility {
    if (_held) {
      return const MonoChromeVisibility(
        visible: false,
        cause: MonoChromeCause.held,
      );
    }
    if (_pinned) {
      return const MonoChromeVisibility(
        visible: true,
        cause: MonoChromeCause.none,
      );
    }
    return switch (widget.policy) {
      MonoChromePolicy.persistent => const MonoChromeVisibility(
        visible: true,
        cause: MonoChromeCause.none,
      ),
      MonoChromePolicy.hidden => MonoChromeVisibility(
        visible: widget.summoned,
        cause: widget.summoned
            ? MonoChromeCause.none
            : MonoChromeCause.unsummoned,
      ),
      MonoChromePolicy.resting => MonoChromeVisibility(
        visible: !_rested,
        cause: _rested ? MonoChromeCause.timed : MonoChromeCause.none,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final bool isTouch = MonokitTheme.of(context).density.isTouch;
    final MonoChromeVisibility visibility = _visibility;

    Widget surface = widget.child;

    // Touch: the hold. Pointer never learns a gesture.
    if (isTouch) {
      surface = GestureDetector(
        // Opaque: "hold anywhere on the media". deferToChild would mean a
        // press on empty media reaches nothing, and the peek would only work
        // where something happened to be drawn.
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => _setHeld(true),
        onLongPressEnd: (_) => _setHeld(false),
        onLongPressCancel: () => _setHeld(false),
        onTap: _wake,
        child: surface,
      );
    } else {
      // Pointer: ambient. Movement returns chrome; there is no hold.
      surface = MouseRegion(
        onHover: (_) => _wake(),
        onEnter: (_) => _wake(),
        child: surface,
      );
    }

    // Keyboard: while chrome is hidden the first key returns it and is
    // consumed, so the key that woke the screen does not also act on it.
    surface = Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (visibility.visible) return KeyEventResult.ignored;
        _wake();
        return KeyEventResult.handled;
      },
      child: surface,
    );

    return _MonoChromeScopeData(visibility: visibility, child: surface);
  }
}

class _MonoChromeScopeData extends InheritedWidget {
  const _MonoChromeScopeData({required this.visibility, required super.child});

  final MonoChromeVisibility visibility;

  @override
  bool updateShouldNotify(_MonoChromeScopeData oldWidget) =>
      visibility != oldWidget.visibility;
}

/// One chrome layer over media — a bar, a rail, a header.
///
/// Fades on the scope's decision, and *how* it leaves depends on why:
///
/// * a **timed** recede translates toward its own edge as it fades — leaving
///   is polite;
/// * a **held** peek does not move at all — the finger is still on the glass,
///   and on release every control is exactly where the thumb left it.
///
/// Recede accelerates on the way out and return decelerates: leaving is
/// polite, returning is obedient.
///
/// Set [subjectTruth] on anything that is the subject rather than a
/// convenience — captions, the recording dot, an active call timer, the live
/// badge. Those never recede.
class MonoChrome extends StatelessWidget {
  const MonoChrome({
    super.key,
    required this.child,
    this.edge = MonoChromeEdge.bottom,
    this.subjectTruth = false,
    this.travel = 8,
  });

  final Widget child;
  final MonoChromeEdge edge;

  /// Subject truth never auto-hides, whatever the policy says.
  final bool subjectTruth;

  /// How far a timed recede travels toward its edge.
  final double travel;

  @override
  Widget build(BuildContext context) {
    if (subjectTruth) return child;

    final theme = MonokitTheme.of(context);
    final MonoChromeVisibility v = MonoChromeScope.of(context);
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    // A held peek is opacity only. Only a timed recede travels.
    final Offset offset = v.visible || v.cause != MonoChromeCause.timed
        ? Offset.zero
        : switch (edge) {
            MonoChromeEdge.top => Offset(0, -travel),
            MonoChromeEdge.bottom => Offset(0, travel),
            MonoChromeEdge.start => Offset(rtl ? travel : -travel, 0),
            MonoChromeEdge.end => Offset(rtl ? -travel : travel, 0),
          };

    final Duration duration = theme.motion.reduced(
      context,
      v.visible ? theme.motion.enter : theme.motion.state,
    );

    final Curve curve = v.visible
        ? theme.motion.decelerate
        : theme.motion.accelerate;

    // A real pixel translate: AnimatedSlide's offset is a fraction of the
    // child's own size, which would make an 8px travel mean something
    // different for a rail than for a bar.
    return IgnorePointer(
      ignoring: !v.visible,
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(end: offset),
        duration: duration,
        curve: curve,
        builder: (BuildContext context, Offset value, Widget? child) =>
            Transform.translate(offset: value, child: child),
        child: AnimatedOpacity(
          opacity: v.visible ? 1 : 0,
          duration: duration,
          curve: curve,
          // Hidden chrome is gone for assistive technology too — a control
          // nobody can see should not still be in the traversal order.
          child: ExcludeSemantics(excluding: !v.visible, child: child),
        ),
      ),
    );
  }
}
