import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// A compact selectable capsule: filters, single-choice options, facets.
///
/// Selection is expressed by inversion — the selected chip swaps to the
/// foreground fill with page-coloured text — so the chosen option reads
/// without relying on the brand colour (colour is information, and a chip
/// row is selection, not intent). Unselected chips sit on the de-emphasis
/// well and darken on hover/press like every other transient fill.
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
            var background = selected ? colors.foreground : colors.fill;
            if (hovered || pressed) {
              background = Color.lerp(
                background,
                selected ? colors.page : colors.foreground,
                pressed ? 0.1 : 0.05,
              )!;
            }
            final ink = selected ? colors.page : colors.foreground;
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
