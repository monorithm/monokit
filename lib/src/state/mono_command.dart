import 'package:flutter/widgets.dart';

import '../components/badge.dart';
import '../theme/monokit_theme.dart';

/// The command lifecycle — *design vocabulary, not plumbing.* Monokit imports
/// Monorithm's CQRS command phases as design law: the interface never renders a
/// success it hasn't earned.
///
/// `created → queued → sent → accepted → completed | rejected`
enum MonoCommandPhase {
  created,
  queued, // in the local outbox, not yet transmitted
  sent,
  accepted,
  completed,
  rejected,
  exhausted, // retries exhausted; the user decides
}

extension MonoCommandPhaseX on MonoCommandPhase {
  /// In flight — a pending badge belongs on the surface.
  bool get isPending =>
      this == MonoCommandPhase.queued ||
      this == MonoCommandPhase.sent ||
      this == MonoCommandPhase.accepted;

  /// The ONLY phase that earns celebration and success copy. `accepted` is not
  /// success.
  bool get isTerminalSuccess => this == MonoCommandPhase.completed;

  bool get isTerminalFailure =>
      this == MonoCommandPhase.rejected ||
      this == MonoCommandPhase.exhausted;

  bool get isTerminal => isTerminalSuccess || isTerminalFailure;

  /// Short human label.
  String get label => switch (this) {
    MonoCommandPhase.created => 'Draft',
    MonoCommandPhase.queued => 'Pending',
    MonoCommandPhase.sent => 'Sent',
    MonoCommandPhase.accepted => 'Processing',
    MonoCommandPhase.completed => 'Completed',
    MonoCommandPhase.rejected => 'Rejected',
    MonoCommandPhase.exhausted => 'Needs attention',
  };

  MonoBadgeVariant get badgeVariant => switch (this) {
    MonoCommandPhase.created => MonoBadgeVariant.secondary,
    MonoCommandPhase.queued => MonoBadgeVariant.warning,
    MonoCommandPhase.sent => MonoBadgeVariant.info,
    MonoCommandPhase.accepted => MonoBadgeVariant.info,
    MonoCommandPhase.completed => MonoBadgeVariant.success,
    MonoCommandPhase.rejected => MonoBadgeVariant.destructive,
    MonoCommandPhase.exhausted => MonoBadgeVariant.destructive,
  };
}

/// Marketplace availability — visually distinct states; a terminal state
/// ([fulfilled]/[closed]/[expired]) is *not* actionable, so its surface must
/// disable the primary action. *"Stale availability is never left actionable."*
enum MonoAvailability { available, reserved, fulfilled, closed, expired }

extension MonoAvailabilityX on MonoAvailability {
  String get label => switch (this) {
    MonoAvailability.available => 'Available',
    MonoAvailability.reserved => 'Reserved',
    MonoAvailability.fulfilled => 'Sold',
    MonoAvailability.closed => 'Closed',
    MonoAvailability.expired => 'Expired',
  };

  /// Whether the primary outcome action should remain enabled.
  bool get isActionable =>
      this == MonoAvailability.available || this == MonoAvailability.reserved;

  MonoBadgeVariant get badgeVariant => switch (this) {
    MonoAvailability.available => MonoBadgeVariant.success,
    MonoAvailability.reserved => MonoBadgeVariant.warning,
    MonoAvailability.fulfilled => MonoBadgeVariant.secondary,
    MonoAvailability.closed => MonoBadgeVariant.outline,
    MonoAvailability.expired => MonoBadgeVariant.outline,
  };
}

/// A pending badge for an in-flight command. Reads the phase and, while pending,
/// wraps itself in a looping [MonoReconcile] shimmer.
class MonoPending extends StatelessWidget {
  const MonoPending({super.key, required this.phase, this.label});

  final MonoCommandPhase phase;

  /// Overrides the default phase label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final badge = MonoBadge(
      variant: phase.badgeVariant,
      child: Text(label ?? phase.label),
    );
    return MonoReconcile(settled: !phase.isPending, child: badge);
  }
}

/// The reconciling shimmer: **one sweep = settled, looping = still loading.**
/// Sweeps a soft highlight across [child] while unsettled; when [settled] flips
/// true it plays one final pass and rests. Honors reduced-motion.
class MonoReconcile extends StatefulWidget {
  const MonoReconcile({super.key, required this.settled, required this.child});

  final bool settled;
  final Widget child;

  @override
  State<MonoReconcile> createState() => _MonoReconcileState();
}

class _MonoReconcileState extends State<MonoReconcile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _finalPass = false;

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = MonokitTheme.of(context).motion.shimmerLoop;
    _sync();
  }

  @override
  void didUpdateWidget(covariant MonoReconcile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settled != widget.settled) {
      _sync();
    }
  }

  void _sync() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.stop();
      return;
    }
    if (!widget.settled) {
      _finalPass = false;
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else if (_controller.isAnimating && !_finalPass) {
      // Let the current sweep finish, then rest.
      _finalPass = true;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _finalPass) {
      _controller.stop();
      _finalPass = false;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final highlight = theme.colors.foreground.withValues(alpha: 0.14);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        if (!_controller.isAnimating) return child!;
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              const Color(0x00FFFFFF),
              highlight,
              const Color(0x00FFFFFF),
            ],
            stops: <double>[
              (t - 0.3).clamp(0.0, 1.0),
              t.clamp(0.0, 1.0),
              (t + 0.3).clamp(0.0, 1.0),
            ],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}

/// An optimistic toggle with a **mandatory rollback story** — bookmark, follow.
///
/// The value flips immediately and [commit] runs; if it throws, the value rolls
/// back to where it started and [onError] fires. Reserve this for reversible,
/// low-stakes toggles — publication, checkout, moderation, and destructive
/// actions are *never* optimistic.
class MonoOptimistic<T> extends StatefulWidget {
  const MonoOptimistic({
    super.key,
    required this.value,
    required this.commit,
    required this.builder,
    this.onError,
  });

  /// The confirmed value from the source of truth.
  final T value;

  /// Persists [next]; its resolved value becomes the new confirmed value. If it
  /// throws, the widget rolls back.
  final Future<T> Function(T next) commit;

  /// `set` applies an optimistic value and kicks off [commit].
  final Widget Function(
    BuildContext context,
    T value,
    bool pending,
    ValueChanged<T> set,
  )
  builder;

  final void Function(Object error)? onError;

  @override
  State<MonoOptimistic<T>> createState() => _MonoOptimisticState<T>();
}

class _MonoOptimisticState<T> extends State<MonoOptimistic<T>> {
  late T _value = widget.value;
  bool _pending = false;

  @override
  void didUpdateWidget(covariant MonoOptimistic<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pending && oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  Future<void> _set(T next) async {
    final previous = _value;
    setState(() {
      _value = next;
      _pending = true;
    });
    try {
      final settled = await widget.commit(next);
      if (!mounted) return;
      setState(() {
        _value = settled;
        _pending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _value = previous; // roll back
        _pending = false;
      });
      widget.onError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _value, _pending, _set);
}
