import 'package:flutter/widgets.dart';

/// Owns the "restore focus when the overlay closes" contract shared by every
/// anchored/floating overlay in Monokit — combobox, select, dropdown menu,
/// context menu, hover card, popover, sheet, and drawer.
///
/// Before this controller, each of those components hand-rolled the same state
/// machine with subtly different field names, method names, and restore
/// behavior. Three families had emerged:
///
/// * re-focus the component's own trigger node (combobox/select/dropdown),
/// * capture [FocusManager.primaryFocus] on open and restore it (context menu/
///   hover card/popover/sheet/drawer),
/// * restore nothing.
///
/// This controller unifies them on the most correct behavior: capture whoever
/// held focus before the overlay opened, and on a user-driven close return
/// focus to that node — falling back to [triggerFocusNode] when the captured
/// node is gone (unmounted or no longer focusable).
///
/// Usage mirrors the existing lifecycle hooks:
///
/// ```dart
/// // just before Overlay.insert(entry):
/// _overlayFocus.captureForOpen();
///
/// // wherever the component decides a close should return focus
/// // (Esc, tap-away, item selection) — replaces `restoreFocus: true`:
/// _overlayFocus.requestRestoreOnClose();
///
/// // after the exit animation completes and the entry is removed:
/// _overlayFocus.restoreIfRequested(mounted: mounted, enabled: _isEnabled);
/// ```
class MonoOverlayFocusController {
  MonoOverlayFocusController({this.triggerFocusNode});

  /// Resolves the overlay's own trigger node (combobox field, select button, …),
  /// used as the restore fallback when the previously focused node can no longer
  /// take focus. A callback rather than a stored node so components that swap
  /// their [FocusNode] in `didUpdateWidget` always fall back to the current one.
  /// May be null for overlays without a state-level trigger node
  /// (popover/sheet/drawer), in which case restore is best-effort.
  final ValueGetter<FocusNode?>? triggerFocusNode;

  FocusNode? _focusBeforeOpen;
  bool _restoreOnClose = false;

  /// Whether the current pending close has been marked to restore focus.
  bool get willRestoreOnClose => _restoreOnClose;

  /// Records the currently focused node. Call immediately before inserting the
  /// overlay entry, so the node captured is the one that had focus in the page
  /// behind the overlay.
  void captureForOpen() {
    _focusBeforeOpen = FocusManager.instance.primaryFocus;
  }

  /// Marks the pending close as user-driven (Esc / tap-away / selection) so that
  /// [restoreIfRequested] returns focus. Idempotent — safe to call more than
  /// once for a single close, matching the `flag |= restoreFocus` accumulation
  /// the components used before.
  void requestRestoreOnClose() {
    _restoreOnClose = true;
  }

  /// Clears any pending restore request without moving focus. Call when a close
  /// should explicitly *not* restore (e.g. dispose).
  void cancelRestore() {
    _restoreOnClose = false;
    _focusBeforeOpen = null;
  }

  /// Restores focus if [requestRestoreOnClose] was called for this close.
  ///
  /// Call after the exit animation completes and the overlay entry has been
  /// removed. [mounted] and [enabled] mirror the guards the components applied
  /// inline (skip restoration for an unmounted or disabled trigger). Resets the
  /// pending state regardless of whether focus actually moved.
  void restoreIfRequested({required bool mounted, bool enabled = true}) {
    final shouldRestore = _restoreOnClose;
    final previous = _focusBeforeOpen;
    _restoreOnClose = false;
    _focusBeforeOpen = null;
    if (!shouldRestore || !mounted || !enabled) return;
    final target =
        (previous != null &&
            previous.context != null &&
            previous.canRequestFocus)
        ? previous
        : triggerFocusNode?.call();
    target?.requestFocus();
  }
}
