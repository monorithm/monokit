import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// A compact selectable capsule: filters, single-choice options, facets.
///
/// Selection is expressed in the brand's soft/on-soft pair - `primarySoft`
/// under `primaryText` - which is the grammar the colour standard assigns to
/// exactly this job: "`primary`/`primarySoft` follow the same solid/soft
/// grammar for brand emphasis (selected chips, active filters, highlighted
/// rows)".
///
/// It used to invert instead, swapping to the foreground fill with
/// page-coloured text, on the reasoning that a chip row is selection rather
/// than intent and so should not spend the brand colour. That reasoning does
/// not survive contact with the standard, which had already decided: soft
/// brand emphasis IS how this system says "this one", and inversion is a
/// weight the rest of the kit reserves for nothing else. A selected chip
/// reading as a solid black pill also outranked the primary button beside
/// it, which is the opposite of the intended hierarchy.
///
/// Selection stays legible without colour: the label thickens to
/// [FontWeight.w500] and the chip carries `Semantics(selected: true)`, so
/// neither a monochrome display nor a screen reader depends on the fill.
/// Unselected chips sit on the de-emphasis well and darken on hover/press
/// like every other transient fill.
class MonoChip extends StatelessWidget {
  const MonoChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onPressed,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
    this.statesController,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  /// Optional leading icon at the label scale.
  final MonoIconData? icon;

  final bool enabled;
  final String? semanticLabel;
  final MonoStatesController? statesController;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final colors = theme.colors;
    final radius = BorderRadius.circular(theme.radii.full);

    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: MonoPressable(
          onPressed: onPressed,
          enabled: enabled && onPressed != null,
          semanticLabel: semanticLabel ?? label,
          statesController: statesController,
          focusRing: true,
          focusRingBorderRadius: radius,
          child: (context, states) {
            final hovered = states.contains(MonoState.hovered);
            final pressed = states.contains(MonoState.pressed);
            final ink = selected ? colors.primaryText : colors.foreground;
            var background = selected ? colors.primarySoft : colors.muted;
            if (hovered || pressed) {
              // Both weights now darken toward their own ink, which is what
              // every other transient fill in the kit does. While selection
              // inverted, this had to lerp toward the background instead -
              // the one place in the kit where a press LIGHTENED a surface.
              background = Color.lerp(background, ink, pressed ? 0.1 : 0.05)!;
            }
            return Opacity(
              opacity: enabled ? 1 : 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: radius,
                ),
                constraints: BoxConstraints(
                  minHeight: theme.spacing.md + theme.spacing.xxl,
                ),
                padding: EdgeInsets.symmetric(horizontal: theme.spacing.md + 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      MonoIcon(icon!, size: theme.spacing.lg, color: ink),
                      SizedBox(width: theme.spacing.xs + 2),
                    ],
                    Text(
                      label,
                      style: theme.typography.labelLarge.copyWith(
                        color: ink,
                        fontWeight: selected
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
