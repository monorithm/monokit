import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import 'mono_focus_ring.dart';

/// A widgets-only interaction primitive with hover, focus, press and keyboard
/// activation support.
///
/// Focus is tracked on two axes, per the design language: [MonoState.focused]
/// reflects *any* focus (pointer or keyboard), while [MonoState.focusVisible]
/// is set only for keyboard focus — so a mouse click never paints a focus ring.
/// Set [focusRing] to `true` to have the primitive paint the standard
/// [MonoFocusRing] on keyboard focus instead of styling the ring by hand.
class MonoPressable extends StatefulWidget {
  const MonoPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.expanded,
    this.statesController,
    this.mouseCursor,
    this.focusRing = false,
    this.focusRingBorderRadius,
  });

  /// Built with the current immutable state snapshot.
  final Widget Function(BuildContext context, Set<MonoState> states) child;
  final VoidCallback? onPressed;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  /// Optional expanded/collapsed state announced alongside the button.
  final bool? expanded;
  final MonoStatesController? statesController;
  final MouseCursor? mouseCursor;

  /// When true, wraps the child in a [MonoFocusRing] shown on keyboard focus.
  final bool focusRing;
  final BorderRadius? focusRingBorderRadius;

  @override
  State<MonoPressable> createState() => _MonoPressableState();
}

class _MonoPressableState extends State<MonoPressable> {
  late MonoStatesController _controller;
  late bool _ownsController;
  FocusNode? _internalFocusNode;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _setController(widget.statesController);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant MonoPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statesController != widget.statesController) {
      _detachController();
      _setController(widget.statesController);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          ?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
      _onFocusChanged();
    }
    _controller.update(MonoState.disabled, !_enabled);
  }

  void _setController(MonoStatesController? supplied) {
    _ownsController = supplied == null;
    _controller = supplied ?? MonoStatesController();
    _controller.addListener(_onStatesChanged);
    _controller.update(MonoState.disabled, !_enabled);
  }

  void _detachController() {
    _controller.removeListener(_onStatesChanged);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  void _onStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Raw focus (pointer or keyboard) — distinct from keyboard focus-visible.
  void _onFocusChanged() {
    _controller.update(MonoState.focused, _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      _controller.update(MonoState.focusVisible, false);
    }
  }

  @override
  void dispose() {
    (widget.focusNode ?? _internalFocusNode)?.removeListener(_onFocusChanged);
    _internalFocusNode?.dispose();
    _detachController();
    super.dispose();
  }

  void _activate() {
    if (_enabled) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      expanded: widget.expanded,
      child: FocusableActionDetector(
        enabled: _enabled,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        mouseCursor:
            widget.mouseCursor ??
            (_enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden),
        onShowHoverHighlight: (hovered) {
          _controller.update(MonoState.hovered, hovered);
        },
        // Keyboard focus-visible only (FocusableActionDetector already gates
        // this on the highlight mode, so a mouse click won't trigger it).
        onShowFocusHighlight: (visible) {
          _controller.update(MonoState.focusVisible, visible);
        },
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _enabled ? _activate : null,
          onTapDown: _enabled
              ? (_) => _controller.update(MonoState.pressed, true)
              : null,
          onTapUp: _enabled
              ? (_) => _controller.update(MonoState.pressed, false)
              : null,
          onTapCancel: _enabled
              ? () => _controller.update(MonoState.pressed, false)
              : null,
          child: Builder(
            builder: (context) {
              final states = _controller.states;
              final built = widget.child(context, states);
              if (!widget.focusRing) return built;
              return MonoFocusRing(
                focused: states.contains(MonoState.focusVisible),
                borderRadius: widget.focusRingBorderRadius,
                child: built,
              );
            },
          ),
        ),
      ),
    );
  }
}
