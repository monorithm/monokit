import 'package:flutter/widgets.dart';

/// Marks its [child] as a navigable heading for screen readers.
///
/// Screen-reader users navigate a screen by its headings (VoiceOver's rotor,
/// TalkBack's heading gesture). Wrap the title of a dialog, alert, card, sheet,
/// drawer, or screen chrome in a [MonoHeading] so those titles show up in the
/// heading list instead of being read as plain text.
///
/// [level] is advisory today — Flutter's semantics expose only a boolean
/// `header` flag, not a heading level — but it records intent and future-proofs
/// for per-level support without an API change.
class MonoHeading extends StatelessWidget {
  const MonoHeading(this.child, {this.level = 2, super.key})
    : assert(level >= 1 && level <= 6, 'Heading level must be 1..6');

  final Widget child;

  /// The intended heading level (1 is the most prominent). Advisory only.
  final int level;

  @override
  Widget build(BuildContext context) {
    return Semantics(header: true, child: child);
  }
}
