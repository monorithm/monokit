import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';

/// A compact, widgets-only binary switch.
class MonoSwitch extends StatefulWidget {
  const MonoSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.child,
    this.description,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.statesController,
  }) : assert(
         label == null || child == null,
         'Specify either label or child, not both.',
       );

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? label;
  final Widget? child;
  final Widget? description;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;

  @override
  State<MonoSwitch> createState() => _MonoSwitchState();
}

class _MonoSwitchState extends State<MonoSwitch> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  bool get _isEnabled => widget.enabled && widget.onChanged != null;
  bool get _isFocused => _statesController.contains(MonoState.focused);
  bool get _isFocusVisible =>
      _statesController.contains(MonoState.focusVisible);
  bool get _isHovered => _statesController.contains(MonoState.hovered);
  bool get _isPressed => _statesController.contains(MonoState.pressed);

  @override
  void initState() {
    super.initState();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);

    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncFixedStates();
    _statesController.addListener(_handleStatesChanged);
  }

  @override
  void didUpdateWidget(covariant MonoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChanged);
    }
    if (oldWidget.statesController != widget.statesController) {
      _statesController.removeListener(_handleStatesChanged);
      if (_ownsStatesController) {
        _statesController.dispose();
      }
      _ownsStatesController = widget.statesController == null;
      _statesController = widget.statesController ?? MonoStatesController();
      _syncFixedStates();
      _statesController.addListener(_handleStatesChanged);
    }
    if (!_isEnabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _syncFixedStates();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _statesController.removeListener(_handleStatesChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsStatesController) {
      _statesController.dispose();
    }
    super.dispose();
  }

  void _syncFixedStates() {
    _statesController.update(MonoState.disabled, !_isEnabled);
    _statesController.update(MonoState.checked, widget.value);
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    _statesController.update(MonoState.focused, _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      _statesController.update(MonoState.focusVisible, false);
    }
  }

  void _toggle() {
    if (_isEnabled) {
      widget.onChanged?.call(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final Widget? resolvedLabel = widget.label ?? widget.child;
    final Color foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final Color trackColor = widget.value
        ? theme.colors.primary
        : _isEnabled
        ? theme.colors.muted
        : theme.colors.muted.withAlpha(150);
    final Color trackBorder = widget.value
        ? theme.colors.primary
        : _isHovered && _isEnabled
        ? theme.colors.foreground
        : theme.colors.input;
    final Color thumbColor = widget.value
        ? theme.colors.primaryForeground
        : theme.colors.card;

    final Widget toggle = AnimatedContainer(
      duration: theme.motion.reduced(context, theme.motion.base),
      curve: theme.motion.curve,
      width: theme.spacing.huge,
      height: theme.spacing.xl,
      decoration: BoxDecoration(
        color: trackColor,
        border: Border.all(color: trackBorder),
        borderRadius: BorderRadius.circular(theme.radii.full),
        boxShadow: _isFocusVisible
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.colors.ring.withAlpha(72),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: AnimatedAlign(
        duration: theme.motion.reduced(context, theme.motion.base),
        curve: theme.motion.curve,
        alignment: widget.value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.xs / 2),
          child: Transform.scale(
            scale: _isPressed ? 0.9 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: thumbColor,
                borderRadius: BorderRadius.circular(theme.radii.full),
              ),
              child: SizedBox(
                width: theme.spacing.lg,
                height: theme.spacing.lg,
              ),
            ),
          ),
        ),
      ),
    );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        toggle,
        if (resolvedLabel != null || widget.description != null) ...<Widget>[
          SizedBox(width: theme.spacing.sm),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (resolvedLabel != null)
                  DefaultTextStyle.merge(
                    style: theme.typography.bodyMedium.copyWith(
                      color: foreground,
                    ),
                    child: resolvedLabel,
                  ),
                if (widget.description != null) ...<Widget>[
                  if (resolvedLabel != null) SizedBox(height: theme.spacing.xs),
                  DefaultTextStyle.merge(
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    child: widget.description!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );

    return FocusableActionDetector(
      enabled: _isEnabled,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      includeFocusSemantics: false,
      mouseCursor: _isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _toggle();
            return null;
          },
        ),
      },
      onShowFocusHighlight: (bool visible) =>
          _statesController.update(MonoState.focusVisible, visible),
      onShowHoverHighlight: (bool hovered) =>
          _statesController.update(MonoState.hovered, hovered),
      child: Semantics(
        container: true,
        enabled: _isEnabled,
        toggled: widget.value,
        focusable: _isEnabled,
        focused: _isFocused,
        label: widget.semanticLabel,
        onTap: _isEnabled ? _toggle : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _isEnabled
              ? (_) => _statesController.update(MonoState.pressed, true)
              : null,
          onTapUp: _isEnabled
              ? (_) => _statesController.update(MonoState.pressed, false)
              : null,
          onTapCancel: _isEnabled
              ? () => _statesController.update(MonoState.pressed, false)
              : null,
          onTap: _isEnabled ? _toggle : null,
          child: AnimatedOpacity(
            duration: theme.motion.fast,
            opacity: _isEnabled ? 1 : 0.55,
            child: content,
          ),
        ),
      ),
    );
  }
}
