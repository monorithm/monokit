import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

const double _kHandleSize = 22.0;
const double _kToolbarGap = 8.0;

/// Engine-neutral text-selection handles, painted from Monokit tokens.
///
/// Material's handle controls (`materialTextSelectionHandleControls`) live in
/// `package:flutter/material.dart`, which Monokit does not depend on, so the
/// selection handles are drawn here instead. Pair with [monoContextMenuBuilder]
/// for the cut/copy/paste toolbar.
class MonoTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  MonoTextSelectionControls();

  @override
  Size getHandleSize(double textLineHeight) =>
      const Size(_kHandleSize, _kHandleSize);

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    return switch (type) {
      TextSelectionHandleType.collapsed => const Offset(_kHandleSize / 2, -4),
      TextSelectionHandleType.left => const Offset(_kHandleSize, 0),
      TextSelectionHandleType.right => Offset.zero,
    };
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final MonokitThemeData? theme = MonokitTheme.maybeOf(context);
    final Color color = theme?.colors.primary ?? const Color(0xFF10B981);
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: CustomPaint(painter: _MonoHandlePainter(color)),
    );
    // The left/right handles are mirror images pointing at the selection edge.
    return switch (type) {
      TextSelectionHandleType.left => Transform.rotate(
        angle: 1.5707963267948966, // pi/2
        child: handle,
      ),
      TextSelectionHandleType.right => Transform.rotate(
        angle: 3.141592653589793, // pi
        child: handle,
      ),
      TextSelectionHandleType.collapsed => Transform.rotate(
        angle: 0.7853981633974483, // pi/4
        child: handle,
      ),
    };
  }

  // The toolbar is provided through `contextMenuBuilder`; the
  // TextSelectionHandleControls mixin routes the legacy buildToolbar there.
}

class _MonoHandlePainter extends CustomPainter {
  _MonoHandlePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Paint paint = Paint()..color = color;
    // A teardrop: a full circle with a square filling the top-left quadrant so
    // the handle visually points at the text line.
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawRect(Rect.fromLTWH(0, 0, radius, radius), paint);
  }

  @override
  bool shouldRepaint(_MonoHandlePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// An engine-neutral text magnifier configuration (drag-to-select loupe) built
/// on the framework's [RawMagnifier], since the Material/Cupertino magnifiers
/// live outside `package:flutter/widgets.dart`.
final TextMagnifierConfiguration monoMagnifierConfiguration =
    TextMagnifierConfiguration(
      magnifierBuilder:
          (
            BuildContext context,
            MagnifierController controller,
            ValueNotifier<MagnifierInfo> magnifierInfo,
          ) {
            return _MonoTextMagnifier(magnifierInfo: magnifierInfo);
          },
    );

class _MonoTextMagnifier extends StatelessWidget {
  const _MonoTextMagnifier({required this.magnifierInfo});

  final ValueNotifier<MagnifierInfo> magnifierInfo;

  static const Size _size = Size(100, 48);
  static const double _verticalOffset = 60;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    return ValueListenableBuilder<MagnifierInfo>(
      valueListenable: magnifierInfo,
      builder: (BuildContext context, MagnifierInfo info, Widget? child) {
        // Center the loupe horizontally over the touch point and float it above.
        final Offset focal = info.globalGesturePosition;
        return Positioned(
          left: focal.dx - _size.width / 2,
          top: focal.dy - _verticalOffset - _size.height,
          child: child!,
        );
      },
      child: RawMagnifier(
        size: _size,
        magnificationScale: 1.5,
        decoration: MagnifierDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(theme.radii.md),
            side: BorderSide(color: theme.colors.border),
          ),
        ),
      ),
    );
  }
}

/// Builds Monokit's token-styled selection toolbar for an [EditableText].
///
/// Pass as `EditableText.contextMenuBuilder`; it renders the platform-provided
/// cut/copy/paste/select-all actions (`editableTextState.contextMenuButtonItems`)
/// in a floating surface anchored at the selection.
Widget monoContextMenuBuilder(
  BuildContext context,
  EditableTextState editableTextState,
) {
  return MonoTextSelectionToolbar(
    anchor: editableTextState.contextMenuAnchors.primaryAnchor,
    buttonItems: editableTextState.contextMenuButtonItems,
  );
}

/// A floating cut/copy/paste toolbar styled from Monokit tokens.
class MonoTextSelectionToolbar extends StatelessWidget {
  const MonoTextSelectionToolbar({
    super.key,
    required this.anchor,
    required this.buttonItems,
  });

  /// The point (global) the toolbar should sit above.
  final Offset anchor;
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    if (buttonItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final MonokitThemeData theme = MonokitTheme.of(context);
    // Cap the toolbar to the viewport width so a long button list — Android
    // adds every PROCESS_TEXT app (Share, translators, etc.) to
    // contextMenuButtonItems — scrolls horizontally instead of overflowing off
    // the screen edge.
    final double maxWidth =
        (MediaQuery.of(context).size.width - theme.spacing.lg * 2).clamp(
          0.0,
          double.infinity,
        );
    final Widget toolbar = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.popover,
          borderRadius: BorderRadius.circular(theme.radii.md),
          border: Border.all(color: theme.colors.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colors.foreground.withValues(alpha: 0.12),
              blurRadius: theme.spacing.lg,
              offset: Offset(0, theme.spacing.xs),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radii.md),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(theme.spacing.xs / 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final ContextMenuButtonItem item in buttonItems)
                  _MonoToolbarButton(
                    label: _labelFor(item, theme),
                    onPressed: item.onPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return CustomSingleChildLayout(
      delegate: _MonoToolbarLayoutDelegate(anchor: anchor, gap: _kToolbarGap),
      child: toolbar,
    );
  }

  String _labelFor(ContextMenuButtonItem item, MonokitThemeData theme) {
    if (item.label != null) {
      return item.label!;
    }
    return switch (item.type) {
      ContextMenuButtonType.cut => 'Cut',
      ContextMenuButtonType.copy => 'Copy',
      ContextMenuButtonType.paste => 'Paste',
      ContextMenuButtonType.selectAll => 'Select all',
      ContextMenuButtonType.delete => 'Delete',
      ContextMenuButtonType.lookUp => 'Look up',
      ContextMenuButtonType.searchWeb => 'Search',
      ContextMenuButtonType.share => 'Share',
      ContextMenuButtonType.liveTextInput => 'Scan text',
      ContextMenuButtonType.custom => '',
    };
  }
}

class _MonoToolbarButton extends StatelessWidget {
  const _MonoToolbarButton({required this.label, this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          child: Text(
            label,
            style: theme.typography.labelMedium.copyWith(
              color: theme.colors.popoverForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Positions the toolbar centered above [anchor], flipping below and clamping
/// horizontally so it always stays on screen.
class _MonoToolbarLayoutDelegate extends SingleChildLayoutDelegate {
  _MonoToolbarLayoutDelegate({required this.anchor, required this.gap});
  final Offset anchor;
  final double gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(constraints.biggest);

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x = anchor.dx - childSize.width / 2;
    x = x.clamp(
      8.0,
      (size.width - childSize.width - 8.0).clamp(8.0, size.width),
    );
    double y = anchor.dy - childSize.height - gap;
    if (y < 8.0) {
      y = anchor.dy + gap; // not enough room above: drop below the selection
    }
    y = y.clamp(
      8.0,
      (size.height - childSize.height - 8.0).clamp(8.0, size.height),
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MonoToolbarLayoutDelegate oldDelegate) =>
      anchor != oldDelegate.anchor || gap != oldDelegate.gap;
}
