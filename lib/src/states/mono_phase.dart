import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';

/// The five visible phases of a command.
///
/// A command has more machine states than this — created, queued, sent,
/// accepted, completed, rejected, exhausted, abandoned. Eight is too many for a
/// person, so they collapse into five, and **a component accepts the phase,
/// never the transport type**. That rule is the whole point: `delivered` and
/// `read` are facts about a pipe, and a user interface that renders them is
/// describing the plumbing rather than the intent.
///
/// `abandoned` maps to no phase at all — the affordance removes silently, with
/// no residue.
enum MonoPhase {
  /// Intent in flight: created, queued or sent. A quiet badge.
  ///
  /// Sub-states within pending must not cause visual churn. Created to queued
  /// to sent happens in milliseconds when online, and a badge that flickers
  /// through three labels reads as instability. One label, one dot.
  pending,

  /// The server has it; the read model is catching up. One shimmer sweep.
  reconciling,

  /// The affordance removes; the entity settles.
  succeeded,

  /// The domain said no. Reason and actions, **in place** — destructive ink.
  rejected,

  /// Transport gave up. Nobody said no, the attempt simply stopped. Warning
  /// ink and a retry: the user decides.
  ///
  /// [rejected] and [stalled] must never look alike. A declined payment and a
  /// dropped connection call for opposite responses, and a user who reads one
  /// as the other either gives up on something that would have worked or
  /// retries something that never will.
  stalled,
}

/// What a phase means for the surface rendering it.
extension MonoPhaseSemantics on MonoPhase {
  /// Whether the command is still in flight.
  bool get isInFlight =>
      this == MonoPhase.pending || this == MonoPhase.reconciling;

  /// Whether the command ended without doing what was asked.
  bool get isUnresolved =>
      this == MonoPhase.rejected || this == MonoPhase.stalled;

  /// Whether the user is the one who has to act next.
  ///
  /// True for [stalled] — a retry is theirs to make. False for [rejected],
  /// where the domain has already decided and the surface owes a reason
  /// instead of a button.
  bool get awaitsUser => this == MonoPhase.stalled;
}

/// The pending badge: neutral ground, muted ink, one dot.
///
/// Deliberately quiet. Pending is the most common phase in a healthy system and
/// the one the user should notice least — it says "in flight", not "wrong".
///
/// The dot pulses, and stops under reduced motion: the phase is carried by the
/// label and the dot's presence, never by the animation, so removing the motion
/// removes nothing.
class MonoPhaseBadge extends StatefulWidget {
  const MonoPhaseBadge({super.key, required this.phase, required this.label});

  final MonoPhase phase;

  /// What this phase is called, in the user's language. Never defaulted to an
  /// English string: a badge is copy, and copy is the host's to write.
  final String label;

  @override
  State<MonoPhaseBadge> createState() => _MonoPhaseBadgeState();
}

class _MonoPhaseBadgeState extends State<MonoPhaseBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MonokitMotion.noAnimation(context) || !widget.phase.isInFlight) {
      _pulse.stop();
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final colors = theme.colors;

    final (Color ground, Color ink) = switch (widget.phase) {
      MonoPhase.pending ||
      MonoPhase.reconciling => (colors.muted, colors.mutedForeground),
      MonoPhase.succeeded => (colors.successSoft, colors.successText),
      MonoPhase.rejected => (colors.destructiveSoft, colors.destructiveText),
      MonoPhase.stalled => (colors.warningSoft, colors.warningText),
    };

    return Semantics(
      container: true,
      label: widget.label,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.sm,
          vertical: theme.spacing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: ground,
          borderRadius: theme.radii.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 1).animate(_pulse),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: ink, shape: BoxShape.circle),
              ),
            ),
            SizedBox(width: theme.spacing.xs + 2),
            Text(
              widget.label,
              style: theme.typography.labelMedium.copyWith(color: ink),
            ),
          ],
        ),
      ),
    );
  }
}
