import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';

/// A widgets-only interaction primitive with hover, focus, press and keyboard
/// activation support.
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

  @override
  State<MonoPressable> createState() => _MonoPressableState();
}

class _MonoPressableState extends State<MonoPressable> {
  late MonoStatesController _controller;
  late bool _ownsController;

  bool get _enabled => widget.enabled && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _setController(widget.statesController);
  }

  @override
  void didUpdateWidget(covariant MonoPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statesController != widget.statesController) {
      _detachController();
      _setController(widget.statesController);
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

  @override
  void dispose() {
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
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        mouseCursor:
            widget.mouseCursor ??
            (_enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden),
        onShowHoverHighlight: (hovered) {
          _controller.update(MonoState.hovered, hovered);
        },
        onShowFocusHighlight: (focused) {
          _controller
            ..update(MonoState.focused, focused)
            ..update(MonoState.focusVisible, focused);
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
          child: widget.child(context, _controller.states),
        ),
      ),
    );
  }
}
