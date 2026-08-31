import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// The three heights a text control takes.
///
/// The Atlas draws exactly three and never anything between them: the screen's
/// own purpose at [large], a field inside a form at [medium], and a field
/// sharing its row with something else at [small].
enum MonoInputSize {
  /// `density.controlHeight` — 44 touch, 36 pointer. A field beside other
  /// controls in one row, such as the query in a results header.
  small,

  /// `density.row1` — 48 touch, 40 pointer. The default: a field among other
  /// fields.
  medium,

  /// `density.controlHeightLarge` — 56 touch, 48 pointer. The field the screen
  /// exists for. One per screen; a form of these is a form with no hierarchy.
  large,
}

/// The resolved look of a text control, in one place for all four of them.
///
/// `MonoInput`, `MonoInputOtp`, `MonoSelect` and `MonoCombobox` used to carry
/// four copies of the same decoration, which is how they drifted from the
/// design together and then from each other. They now read it from here, so a
/// change lands on all four or on none.
///
/// The shape is a **well**: a filled recess with no border. What the user typed
/// is the loudest thing in it, and the field itself is quiet. A bordered box
/// inverts that — the container draws a rectangle around content that is
/// usually lighter than the line enclosing it.
@immutable
class MonoFieldSkin {
  const MonoFieldSkin({
    required this.height,
    required this.padX,
    required this.radius,
    required this.value,
    required this.placeholder,
  });

  /// Resolves the skin for [size] from the theme's density and type scale.
  factory MonoFieldSkin.of(BuildContext context, MonoInputSize size) {
    final theme = MonokitTheme.of(context);
    final density = theme.density;

    final double height = switch (size) {
      MonoInputSize.small => density.controlHeight,
      MonoInputSize.medium => density.row1,
      MonoInputSize.large => density.controlHeightLarge,
    };

    // The Atlas draws 14 here, which is off the 4pt grid the whole system is
    // built on. 12 is the token next to it and the 2px is not load-bearing;
    // putting a raw 14 in would be the first ungridded number in the kit.
    final double padX = switch (size) {
      MonoInputSize.large => theme.spacing.lg,
      _ => theme.spacing.md,
    };

    // A value the user typed is the content of the screen, not chrome, so it
    // is set loud: 20/600 at large, 14/500 below it.
    final TextStyle value = switch (size) {
      MonoInputSize.large => theme.typography.headlineMedium,
      _ => theme.typography.labelLarge,
    };

    return MonoFieldSkin(
      height: height,
      padX: padX,
      radius: BorderRadius.circular(theme.radii.xl),
      value: value.copyWith(color: theme.colors.foreground),
      // One weight step down and muted: a placeholder has to read as absent
      // text rather than as a short value, and size alone does not do that.
      placeholder: value.copyWith(
        fontWeight: _oneStepDown(value.fontWeight),
        color: theme.colors.mutedForeground,
      ),
    );
  }

  /// The control's height at the ambient density.
  final double height;

  /// Horizontal inset for the content.
  final double padX;

  final BorderRadius radius;

  /// The style for text the user entered.
  final TextStyle value;

  /// The style for placeholder text, and for a fixed prefix such as `+233` or
  /// `@` that the user did not type.
  final TextStyle placeholder;

  /// The well itself. No border in any state — invalidity and focus are both
  /// carried by the ring outside it, which is why they can coexist with the
  /// fill instead of fighting it for the same pixels.
  ///
  /// [hovered] deepens the same ink rather than introducing an edge. With the
  /// border gone the fill is the only surface left to answer a cursor on, and
  /// a pointer user still needs to know which field they are over.
  BoxDecoration well(
    BuildContext context, {
    bool enabled = true,
    bool hovered = false,
  }) {
    final theme = MonokitTheme.of(context);
    final Color base = theme.colors.muted;
    return BoxDecoration(
      // A disabled field keeps its shape and loses its weight, rather than
      // becoming a different component.
      color: switch ((enabled, hovered)) {
        (false, _) => base.withValues(alpha: base.a * 0.5),
        (true, true) => base.withValues(alpha: base.a * 1.6),
        (true, false) => base,
      },
      borderRadius: radius,
    );
  }

  static FontWeight _oneStepDown(FontWeight? weight) => switch (weight) {
    FontWeight.w700 => FontWeight.w600,
    FontWeight.w600 => FontWeight.w500,
    FontWeight.w500 => FontWeight.w400,
    _ => FontWeight.w400,
  };
}
