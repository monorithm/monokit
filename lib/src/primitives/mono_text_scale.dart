import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The largest OS text scale Monokit fixed-height controls grow to.
///
/// Mirrors Material's clamp: layouts scale up to 2x, beyond which text keeps
/// growing but chrome stops, preventing unbounded control heights.
const double monoMaxControlTextScale = 2.0;

/// Grows a token-derived control extent with the OS text-scale setting.
///
/// Monokit sizes controls from density/spacing tokens, which do not know about
/// `MediaQuery.textScaler`; at large accessibility font sizes a fixed
/// [tokenExtent] clips its label. This helper scales the *text portion* of the
/// extent (roughly half of a control's height tracks its label, the other half
/// is chrome/padding) and clamps at [monoMaxControlTextScale], following the
/// same shape as Material's button-padding scaling.
///
/// Returns at least [tokenExtent], so layouts at 1.0 scale are unchanged.
double monoScaledExtent(BuildContext context, double tokenExtent) {
  final TextScaler scaler = MediaQuery.textScalerOf(
    context,
  ).clamp(maxScaleFactor: monoMaxControlTextScale);
  return math.max(
    tokenExtent,
    scaler.scale(tokenExtent * 0.5) + tokenExtent * 0.5,
  );
}
