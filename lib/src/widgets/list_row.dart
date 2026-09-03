import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../primitives/mono_text_scale.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// One row in a [MonoListGroup]: leading icon, title, optional subtitle,
/// optional trailing control.
///
/// Rows are wells between hairlines, not bordered boxes. The height comes off
/// the density row ladder — 48/64/88 at touch, 40/56/76 at pointer — chosen by
/// how many lines the row actually carries, and press/hover paint the
/// transient fill. A [selected] row carries the muted wash **and** the
/// brand-as-ink treatment on its title, so selection never rests on colour
/// alone — the weight steps up with it.
///
/// Before 4.3.0 the height was `spacing.giant`, a fixed 48 that never moved:
/// a list on a desktop rendered at touch metrics, because nothing in the
/// package read the ladder the density group had been publishing since 3.2.0.
class MonoListRow extends StatelessWidget {
  const MonoListRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.overline,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final MonoIconData? icon;
  final String title;
  final String? subtitle;

  /// A third line above the title — a group, a date, a sender. Its presence is
  /// what takes the row to the media rhythm (`row3`).
  final String? overline;

  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final colors = theme.colors;
    final twoLine = subtitle != null;
    final threeLine = overline != null;
    final density = theme.density;
    final minHeight = threeLine
        ? density.row3
        : twoLine
        ? density.row2
        : density.row1;

    Widget content(BuildContext context, Set<MonoState> states) {
      final transient =
          states.contains(MonoState.hovered) ||
          states.contains(MonoState.pressed);
      // A selected row wears the wash, not just the ink. Both the list-row and
      // drawer boards draw the current row on `muted`; before 4.8.0 selection
      // was carried by the title colour alone, and the row it was in looked
      // exactly like its neighbours.
      return ColoredBox(
        color: transient || selected
            ? colors.muted
            : colors.background.withValues(alpha: 0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: monoScaledExtent(context, minHeight),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.lg,
              vertical: theme.spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  MonoIcon(
                    icon!,
                    size: theme.spacing.xl,
                    color: selected ? colors.primaryText : colors.foreground,
                  ),
                  SizedBox(width: theme.spacing.md),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (threeLine) ...<Widget>[
                        // Above the title, and quieter than the subtitle
                        // below it: the overline says which set this row
                        // belongs to, not what it says.
                        Text(
                          overline!,
                          style: theme.typography.labelMedium.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        title,
                        style: theme.typography.bodyMedium.copyWith(
                          color: selected
                              ? colors.primaryText
                              : colors.foreground,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      if (twoLine) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.typography.labelMedium.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...<Widget>[
                  SizedBox(width: theme.spacing.md),
                  ?trailing,
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (onPressed == null) {
      return Semantics(
        label: semanticLabel,
        selected: selected ? true : null,
        child: content(context, const <MonoState>{}),
      );
    }
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: MonoPressable(
          onPressed: onPressed,
          enabled: enabled,
          semanticLabel: semanticLabel ?? title,
          child: content,
        ),
      ),
    );
  }
}

/// A run of [MonoListRow]s between collapsed hairlines, with an optional
/// muted footer.
///
/// Hairlines are structure: one above the group, one between rows, one below
/// — shared edges are collapsed so two stacked hairlines never read as a
/// seam. The [footer] is the group's fine print, in the muted ink.
class MonoListGroup extends StatelessWidget {
  const MonoListGroup({
    super.key,
    required this.children,
    this.footer,
    this.semanticLabel,
  });

  final List<Widget> children;

  /// Fine print rendered under the group (e.g. what a choice implies).
  final String? footer;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final line = BorderSide(color: theme.colors.border);
    return Semantics(
      container: semanticLabel != null,
      label: semanticLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var i = 0; i < children.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: line,
                  bottom: i == children.length - 1 ? line : BorderSide.none,
                ),
              ),
              child: children[i],
            ),
          if (footer != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.lg,
                theme.spacing.sm,
                theme.spacing.lg,
                0,
              ),
              child: Text(
                footer!,
                style: theme.typography.labelMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
