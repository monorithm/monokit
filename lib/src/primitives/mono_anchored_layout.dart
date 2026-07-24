import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'mono_placement.dart';

/// Positions an anchored overlay (menu, popover, tooltip, context menu) next
/// to its trigger so that it can never render outside the visible viewport.
///
/// This replaces the previous `CompositedTransformFollower` approach, which
/// applied a layer transform with no knowledge of screen bounds. The delegate
/// receives the overlay's full size plus the safe-area and keyboard insets, so
/// it can do what a follower cannot:
///
/// * cap the child's size to the space actually available beside the anchor,
/// * flip to the opposite side when the preferred side would overflow using the
///   child's *measured* size (not an estimate),
/// * clamp the final position on both axes into the safe rect, and
/// * avoid the status bar, notches, and the software keyboard
///   (`padding.deflateRect(viewInsets.deflateRect(screen))`).
class MonoAnchoredLayoutDelegate extends SingleChildLayoutDelegate {
  MonoAnchoredLayoutDelegate({
    required this.anchorRect,
    required this.placement,
    required this.textDirection,
    required this.padding,
    required this.viewInsets,
    this.gap = 0,
    this.margin = 8,
    this.matchAnchorWidth = false,
  });

  /// The trigger's rect in the overlay's coordinate space (global for a
  /// root-overlay entry).
  final Rect anchorRect;

  /// The preferred side and alignment; the delegate may flip to [placement]'s
  /// opposite when the preferred side cannot fit the measured child.
  final MonoPlacement placement;

  final TextDirection textDirection;

  /// `MediaQuery.padding` — status bar, notch, and navigation insets.
  final EdgeInsets padding;

  /// `MediaQuery.viewInsets` — the software keyboard.
  final EdgeInsets viewInsets;

  /// Space between the anchor and the overlay along the placement axis.
  final double gap;

  /// Minimum distance kept from every safe-rect edge.
  final double margin;

  /// When true the child's width is pinned to the anchor's width (select,
  /// dropdown, combobox); otherwise the child sizes itself up to the safe rect.
  final bool matchAnchorWidth;

  Rect _safeRect(Size size) {
    final Rect screen = Offset.zero & size;
    return padding.deflateRect(viewInsets.deflateRect(screen)).deflate(margin);
  }

  bool get _isVertical => switch (placement) {
    MonoPlacement.top ||
    MonoPlacement.topStart ||
    MonoPlacement.topEnd ||
    MonoPlacement.bottom ||
    MonoPlacement.bottomStart ||
    MonoPlacement.bottomEnd => true,
    _ => false,
  };

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final Rect safe = _safeRect(constraints.biggest);
    if (_isVertical) {
      final double below = safe.bottom - anchorRect.bottom - gap;
      final double above = anchorRect.top - safe.top - gap;
      final double maxHeight = math.max(0.0, math.max(below, above));
      if (matchAnchorWidth) {
        final double width = math.min(anchorRect.width, safe.width);
        return BoxConstraints(
          minWidth: width,
          maxWidth: width,
          maxHeight: maxHeight,
        );
      }
      return BoxConstraints(maxWidth: safe.width, maxHeight: maxHeight);
    }
    final double right = safe.right - anchorRect.right - gap;
    final double left = anchorRect.left - safe.left - gap;
    final double maxWidth = math.max(0.0, math.max(right, left));
    return BoxConstraints(maxWidth: maxWidth, maxHeight: safe.height);
  }

  Offset _idealFor(MonoPlacement resolved, Size childSize) {
    final MonoPlacementAnchors anchors = MonoPlacementAnchors.resolve(
      resolved,
      textDirection,
    );
    final Offset targetPoint = anchors.target.withinRect(anchorRect);
    final Offset childAnchor = anchors.follower.alongSize(childSize);
    final Offset gapOffset = switch (resolved) {
      MonoPlacement.bottom ||
      MonoPlacement.bottomStart ||
      MonoPlacement.bottomEnd => Offset(0, gap),
      MonoPlacement.top ||
      MonoPlacement.topStart ||
      MonoPlacement.topEnd => Offset(0, -gap),
      MonoPlacement.right ||
      MonoPlacement.rightStart ||
      MonoPlacement.rightEnd => Offset(gap, 0),
      MonoPlacement.left ||
      MonoPlacement.leftStart ||
      MonoPlacement.leftEnd => Offset(-gap, 0),
    };
    return targetPoint - childAnchor + gapOffset;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Rect safe = _safeRect(size);
    Offset position = _idealFor(placement, childSize);

    // Flip to the opposite side when the measured child overflows the
    // preferred side and the opposite side can actually hold it.
    if (_isVertical) {
      final bool overflowsBottom = position.dy + childSize.height > safe.bottom;
      final bool overflowsTop = position.dy < safe.top;
      if (overflowsBottom || overflowsTop) {
        final Offset flipped = _idealFor(placement.opposite, childSize);
        final bool flippedFits =
            flipped.dy >= safe.top &&
            flipped.dy + childSize.height <= safe.bottom;
        if (flippedFits) {
          position = flipped;
        }
      }
    } else {
      final bool overflowsRight = position.dx + childSize.width > safe.right;
      final bool overflowsLeft = position.dx < safe.left;
      if (overflowsRight || overflowsLeft) {
        final Offset flipped = _idealFor(placement.opposite, childSize);
        final bool flippedFits =
            flipped.dx >= safe.left &&
            flipped.dx + childSize.width <= safe.right;
        if (flippedFits) {
          position = flipped;
        }
      }
    }

    // Clamp both axes so the child never leaves the safe rect, even when
    // neither side fully fits.
    final double x = position.dx.clamp(
      safe.left,
      math.max(safe.left, safe.right - childSize.width),
    );
    final double y = position.dy.clamp(
      safe.top,
      math.max(safe.top, safe.bottom - childSize.height),
    );
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(covariant MonoAnchoredLayoutDelegate oldDelegate) {
    return anchorRect != oldDelegate.anchorRect ||
        placement != oldDelegate.placement ||
        textDirection != oldDelegate.textDirection ||
        padding != oldDelegate.padding ||
        viewInsets != oldDelegate.viewInsets ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin ||
        matchAnchorWidth != oldDelegate.matchAnchorWidth;
  }
}

/// Convenience wrapper that reads the ambient [MediaQuery] and [Directionality]
/// and lays [child] out beside [anchorRect] with viewport-aware flip and clamp.
///
/// Place it as a full-area child of the overlay's root `Stack`; taps outside
/// the child fall through to the dismiss barrier behind it.
class MonoAnchoredOverlay extends StatelessWidget {
  const MonoAnchoredOverlay({
    super.key,
    required this.anchorRect,
    required this.placement,
    required this.child,
    this.gap = 0,
    this.margin = 8,
    this.matchAnchorWidth = false,
  });

  final Rect anchorRect;
  final MonoPlacement placement;
  final Widget child;
  final double gap;
  final double margin;
  final bool matchAnchorWidth;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return CustomSingleChildLayout(
      delegate: MonoAnchoredLayoutDelegate(
        anchorRect: anchorRect,
        placement: placement,
        textDirection: Directionality.of(context),
        padding: media.padding,
        viewInsets: media.viewInsets,
        gap: gap,
        margin: margin,
        matchAnchorWidth: matchAnchorWidth,
      ),
      // Contain overlay repaints (highlight/hover ticks) so they don't dirty
      // the page painted behind the overlay.
      child: RepaintBoundary(child: child),
    );
  }
}
