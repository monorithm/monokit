import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// A short run of segments marking progress through a bounded flow —
/// onboarding steps, a wizard, a capture sequence.
///
/// This is discrete progress: [MonoProgress] answers "how much", this answers
/// "which step of how many". Completed segments carry the brand fill (the
/// user is acting; that is what emerald is for), remaining segments the
/// hairline ink. The whole strip announces as one progress semantic — the
/// segments are presentation, not stops.
class MonoStepProgress extends StatelessWidget {
  const MonoStepProgress({
    super.key,
    required this.length,
    required this.value,
    this.semanticLabel,
  }) : assert(length > 0),
       assert(value >= 0 && value <= length, 'value is completed steps.');

  /// Total steps in the flow.
  final int length;

  /// Completed steps, 0 to [length].
  final int value;

  final String? semanticLabel;

  static const double _segmentWidth = 20;
  static const double _segmentHeight = 3;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Step $value of $length',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var i = 0; i < length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: theme.spacing.xs),
            Container(
              width: _segmentWidth,
              height: _segmentHeight,
              decoration: BoxDecoration(
                color: i < value ? theme.colors.primary : theme.colors.border,
                borderRadius: BorderRadius.circular(theme.radii.sm / 3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
