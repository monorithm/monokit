import 'package:flutter/widgets.dart';

/// Semantic surface depth. Components consume tiers instead of synthesizing
/// shadows from arbitrary numeric values.
enum MonoElevationTier { e0, e1, e2, e3, e4 }

@immutable
class MonokitElevation {
  const MonokitElevation({this.shadowColor = const Color(0x29090B0C)});

  final Color shadowColor;

  List<BoxShadow> resolve(MonoElevationTier tier) => switch (tier) {
    MonoElevationTier.e0 || MonoElevationTier.e1 => const <BoxShadow>[],
    MonoElevationTier.e2 => <BoxShadow>[
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.10),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    MonoElevationTier.e3 || MonoElevationTier.e4 => <BoxShadow>[
      BoxShadow(
        color: shadowColor.withValues(alpha: 0.16),
        blurRadius: 32,
        offset: const Offset(0, 12),
      ),
    ],
  };
}
