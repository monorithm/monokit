import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../primitives/mono_text_scale.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// One destination in a [MonoBottomNav].
class MonoBottomNavItem {
  const MonoBottomNavItem({
    required this.icon,
    required this.label,
    this.enabled = true,
    this.tooltip,
  });

  final MonoIconData icon;

  /// The accessibility name for this destination — the bar renders icons
  /// only, so this is what assistive tech announces.
  final String label;
  final bool enabled;
  final String? tooltip;
}

/// An icon-only bottom navigation bar.
///
/// Controlled-only: the host (typically a router shell) owns [selectedIndex]
/// and receives every tap through [onSelected] — including taps on the
/// already-selected destination, so hosts can implement "re-tap resets the
/// stack". (This deliberately differs from [MonoTabs.onIndexChanged], which
/// fires only when the index changes: the bar owns no content panels, so it
/// has no change to gate on.)
///
/// Each destination announces label, button and selected state to assistive
/// tech, and the bar pads itself clear of the bottom system inset.
class MonoBottomNav extends StatelessWidget {
  const MonoBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    this.iconSize = 24,
    this.semanticLabel = 'Primary navigation',
  });

  final List<MonoBottomNavItem> items;
  final int selectedIndex;

  /// Called with the tapped destination's index. When null the whole bar is
  /// non-interactive.
  final ValueChanged<int>? onSelected;
  final double iconSize;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty, 'MonoBottomNav needs at least one item.');
    assert(
      selectedIndex >= 0 && selectedIndex < items.length,
      'selectedIndex is out of range.',
    );
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Semantics(
          container: true,
          label: semanticLabel,
          child: Row(
            children: <Widget>[
              for (var index = 0; index < items.length; index++)
                Expanded(child: _buildItem(context, index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final theme = MonokitTheme.of(context);
    final item = items[index];
    final selected = index == selectedIndex;
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        tooltip: item.tooltip,
        child: MonoPressable(
          enabled: item.enabled,
          onPressed: onSelected == null ? null : () => onSelected!(index),
          semanticLabel: item.label,
          focusRing: true,
          child: (context, states) {
            final hovered = states.contains(MonoState.hovered);
            final foreground = selected
                ? theme.colors.primary
                : hovered
                ? theme.colors.foreground
                : theme.colors.mutedForeground;
            final disableAnimations =
                MediaQuery.maybeOf(context)?.disableAnimations ?? false;
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: monoScaledExtent(
                  context,
                  theme.density.minimumTarget,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
                // heightFactor pins the item to its content height — a plain
                // Center would expand into whatever loose height the host
                // gives the bar (unbounded inside a Column).
                child: Center(
                  heightFactor: 1,
                  child: Opacity(
                    opacity: item.enabled ? 1 : 0.5,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: foreground),
                      duration: disableAnimations
                          ? Duration.zero
                          : theme.motion.fast,
                      curve: theme.motion.curve,
                      builder: (context, color, _) {
                        // The icon's own semantics node would merge with the
                        // pressable's label and double-announce; the item
                        // label is the one source of truth.
                        return ExcludeSemantics(
                          child: MonoIcon(
                            item.icon,
                            size: iconSize,
                            color: color ?? foreground,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
