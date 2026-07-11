import 'package:flutter/material.dart';

import '../theme/monokit_theme_data.dart';

/// Opt-in bridge that carries Monokit tokens through a Material [ThemeData].
///
/// The core `package:monokit/monokit.dart` library never imports Material;
/// import `package:monokit/material.dart` only in hybrid applications.
class MonokitThemeExtension extends ThemeExtension<MonokitThemeExtension> {
  const MonokitThemeExtension(this.data);

  final MonokitThemeData data;

  @override
  MonokitThemeExtension copyWith({MonokitThemeData? data}) {
    return MonokitThemeExtension(data ?? this.data);
  }

  @override
  MonokitThemeExtension lerp(
    covariant ThemeExtension<MonokitThemeExtension>? other,
    double t,
  ) {
    if (other is! MonokitThemeExtension) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}
