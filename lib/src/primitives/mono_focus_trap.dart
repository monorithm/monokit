import 'package:flutter/widgets.dart';

/// Traps keyboard focus traversal inside a modal overlay.
///
/// Monokit's modals (dialog, sheet, drawer, command palette) are built from
/// [OverlayEntry]s rather than [Navigator] routes, so Flutter does not
/// automatically confine Tab traversal to them — pressing Tab from the last
/// control walks focus out into the page behind the scrim. Wrapping the modal
/// content in a [MonoFocusTrap] makes Tab / Shift+Tab wrap around the scope
/// edges instead, keeping keyboard focus within the modal until it is closed.
///
/// Drop it in where a bare `FocusScope` used to wrap the modal content; it
/// keeps the same [autofocus] behavior and simply adds the wrap-around policy.
/// Use it only for true modal surfaces — non-modal overlays (popover, menus,
/// hover card) should let Tab move on.
class MonoFocusTrap extends StatelessWidget {
  const MonoFocusTrap({
    required this.child,
    this.autofocus = true,
    this.node,
    super.key,
  });

  final Widget child;

  /// Whether the scope should claim focus when it first appears.
  final bool autofocus;

  /// Optional scope node, forwarded to the inner [FocusScope].
  final FocusScopeNode? node;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: node,
      autofocus: autofocus,
      child: FocusTraversalGroup(
        policy: _WrapAroundReadingOrderPolicy(),
        child: child,
      ),
    );
  }
}

/// Reading-order traversal whose next/previous wrap around the scope's edges,
/// so Tab past the last focusable returns to the first and Shift+Tab before the
/// first jumps to the last. This is what turns a [FocusScope] into a trap.
class _WrapAroundReadingOrderPolicy extends ReadingOrderTraversalPolicy {
  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    final scope = currentNode.nearestScope;
    if (scope == null) return super.inDirection(currentNode, direction);
    final ordered = sortDescendants(
      scope.traversalDescendants,
      currentNode,
    ).toList();
    if (ordered.isEmpty) return super.inDirection(currentNode, direction);

    final forward =
        direction == TraversalDirection.down ||
        direction == TraversalDirection.right;
    if (forward && currentNode == ordered.last) {
      ordered.first.requestFocus();
      return true;
    }
    if (!forward && currentNode == ordered.first) {
      ordered.last.requestFocus();
      return true;
    }
    return super.inDirection(currentNode, direction);
  }
}
