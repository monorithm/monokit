import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
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
  MonoOverlayFocusController({
    this.triggerFocusNode,
    this.restoreTextInputFocus = false,
  });

  /// Whether closing the overlay may return focus to a **text input** on a
  /// touch-primary platform, which also re-opens the software keyboard.
  ///
  /// Restoring focus is a keyboard-navigation contract: the user tabbed to a
  /// control, opened something over it, and expects to land back where they
  /// were. On a phone there is no tab order to preserve, and returning focus to
  /// a field means the keyboard springs back up unasked after every sheet,
  /// drawer, menu and popover close. So by default a touch platform restores to
  /// [triggerFocusNode] instead of back into the field.
  ///
  /// Desktop and web always restore fully — this flag does not apply there.
  /// Set true to restore into the field on touch as well.
  final bool restoreTextInputFocus;

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

    if (previous != null && _wouldReopenKeyboard(previous)) {
      _declineRestore(previous);
      return;
    }

    final usable =
        previous != null &&
        previous.context != null &&
        previous.canRequestFocus;
    final target = usable ? previous : triggerFocusNode?.call();
    target?.requestFocus();
  }

  /// Steers focus away from [previous] instead of back onto it.
  ///
  /// Simply *not* restoring is not enough. The enclosing scope still remembers
  /// [previous] as its most recently focused child, and when the modal's own
  /// focus node is disposed it unfocuses with
  /// [UnfocusDisposition.previouslyFocusedChild] — replaying exactly the
  /// restoration this controller just declined, a frame or two later. The
  /// scope's memory is what has to change, not just this controller's mind.
  void _declineRestore(FocusNode previous) {
    final fallback = triggerFocusNode?.call();
    if (fallback != null && fallback.canRequestFocus) {
      // Making the trigger the most recent focused child is enough: the
      // framework's own replay will then land there rather than on the field.
      fallback.requestFocus();
      return;
    }
    // With no trigger to hand off to, clear the record instead. `unfocus` is a
    // no-op on a node that is not currently focused — and the modal still holds
    // focus here — so claim it for a moment first. Both calls resolve in one
    // batch, so the field never actually gains focus and never opens the IME;
    // what survives is `UnfocusDisposition.scope` having cleared the scope's
    // focused-children list.
    previous.requestFocus();
    previous.unfocus();
  }

  /// Whether refocusing [node] would pop the software keyboard back up.
  ///
  /// True only for a text-input node on a touch-primary platform, and only when
  /// [restoreTextInputFocus] has not opted back in. The web is excluded because
  /// a browser tab is keyboard-first even on a touch device.
  bool _wouldReopenKeyboard(FocusNode node) {
    if (restoreTextInputFocus || kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return _isTextInput(node);
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return false;
    }
  }

  /// Whether [node] is the focus node of an [EditableText].
  ///
  /// Asked of the node's own element rather than tracked by the components,
  /// because the captured node is whatever held focus in the page behind the
  /// overlay — arbitrary host widgets included, not just Monokit's own fields.
  static bool _isTextInput(FocusNode node) {
    final context = node.context;
    if (context == null || !context.mounted) return false;
    return context.findAncestorWidgetOfExactType<EditableText>() != null;
  }
}
