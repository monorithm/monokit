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
    required this.padY,
    required this.radius,
    required this.value,
    required this.placeholder,
  });

  /// Resolves the skin for [size] from the theme's density and type scale.
  ///
  /// [multiline] changes two things a single-line field does not need: the
  /// value takes the body line height instead of the label one, and the box
  /// gains vertical padding. A single-line field is centred inside a fixed
  /// height, so it needs neither; a multi-line one is sized by its own text,
  /// so without them the lines crowd each other and touch the edges.
  factory MonoFieldSkin.of(
    BuildContext context,
    MonoInputSize size, {
    bool multiline = false,
  }) {
    final theme = MonokitTheme.of(context);
    final density = theme.density;

    final double height = switch (size) {
      MonoInputSize.small => density.controlHeight,
      MonoInputSize.medium => density.row1,
      MonoInputSize.large => density.controlHeightLarge,
    };

    // Density, not size: MonoField draws 16 at touch and 12 at pointer, and a
    // field's inset belongs to the same axis as its height. Sizing it off the
    // size axis instead is what left every field at touch inset on desktop.
    final double padX = density.fieldInset;

    // A value the user typed is the content of the screen, not chrome, so it
    // is set loud: 20/600 at large, 14/500 below it.
    final TextStyle base = switch (size) {
      MonoInputSize.large => theme.typography.headlineMedium,
      _ => theme.typography.labelLarge,
    };

    // Both candidate tokens are chrome registers and carry a tight line
    // height. That is right for one centred line and wrong for a paragraph,
    // so prose takes the body leading at the same size and weight.
    final TextStyle value = multiline
        ? base.copyWith(height: theme.typography.bodyMedium.height)
        : base;

    return MonoFieldSkin(
      height: multiline ? density.textareaMin : height,
      padX: padX,
      padY: multiline ? theme.spacing.md : 0,
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

  /// Vertical inset. Zero for a single-line field, which is centred inside
  /// [height] instead.
  final double padY;

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
    bool invalid = false,
  }) {
    final theme = MonokitTheme.of(context);
    // Invalid recolours the well itself - "no second border language". The
    // field does not grow a destructive ring: a ring means focus, and only
    // one of those belongs on screen at a time.
    if (invalid) {
      return BoxDecoration(
        color: theme.colors.destructiveSoft,
        borderRadius: radius,
      );
    }
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

  /// The ink a value takes inside [well]. Invalid carries `destructiveText`,
  /// so the message under the field and the value inside it agree.
  Color ink(BuildContext context, {bool enabled = true, bool invalid = false}) {
    final theme = MonokitTheme.of(context);
    if (invalid) return theme.colors.destructiveText;
    return enabled ? theme.colors.foreground : theme.colors.mutedForeground;
  }

  /// The ink a placeholder takes. On an invalid field this is
  /// `destructiveText` too, not the neutral muted ink: the Atlas sets the
  /// colour on the well's container so everything inside inherits it, and a
  /// grey placeholder on the destructive ground lands near 3.9:1 — under the
  /// floor. Weight, not hue, is what keeps it reading as absent text.
  Color placeholderInk(BuildContext context, {bool invalid = false}) {
    final theme = MonokitTheme.of(context);
    return invalid
        ? theme.colors.destructiveText
        : theme.colors.mutedForeground;
  }

  static FontWeight _oneStepDown(FontWeight? weight) => switch (weight) {
    FontWeight.w700 => FontWeight.w600,
    FontWeight.w600 => FontWeight.w500,
    FontWeight.w500 => FontWeight.w400,
    _ => FontWeight.w400,
  };
}
