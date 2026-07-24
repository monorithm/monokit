import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

/// Shared test host that installs the Monokit theme plus a Navigator/Overlay
/// stack (via [MonokitApp]) without pulling in Material. Use for a11y and focus
/// tests that open overlays or assert semantics.
Widget monokitHost(Widget child, {MonokitThemeData? theme}) {
  return MonokitApp(
    theme: theme ?? MonokitThemeData.light(),
    home: Center(child: child),
  );
}
