import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../primitives/mono_text_scale.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// One row in a [MonoListGroup]: leading icon, title, optional subtitle,
/// optional trailing control.
///
/// Rows are wells between hairlines, not bordered boxes: a single-line row
/// sits at the 48 rhythm, a two-line row at 64, and press/hover paint the
/// transient fill. A [selected] row carries the brand-as-ink treatment on its
/// title — pair it with a trailing check for a non-colour signal.
class MonoListRow extends StatelessWidget {
  const MonoListRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final MonoIconData? icon;
  final String title;
  final String? subtitle;
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
    final minHeight = twoLine
        ? theme.spacing.giant + theme.spacing.lg
        : theme.spacing.giant;

    Widget content(BuildContext context, Set<MonoState> states) {
      final transient =
          states.contains(MonoState.hovered) ||
          states.contains(MonoState.pressed);
      return ColoredBox(
        color: transient ? colors.fill : colors.page.withValues(alpha: 0),
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
                    color: selected ? colors.tint : colors.foreground,
                  ),
                  SizedBox(width: theme.spacing.md),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: theme.typography.bodyMedium.copyWith(
                          color: selected ? colors.tint : colors.foreground,
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
                            color: colors.foregroundMuted,
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
    final line = BorderSide(color: theme.colors.separator);
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
                  color: theme.colors.foregroundMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
