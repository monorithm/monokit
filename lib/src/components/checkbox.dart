import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';

/// A widgets-only checkbox with optional indeterminate state.
class MonoCheckbox extends StatefulWidget {
  const MonoCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.child,
    this.description,
    this.enabled = true,
    this.tristate = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.statesController,
  }) : assert(
         label == null || child == null,
         'Specify either label or child, not both.',
       ),
       assert(
         value != null || tristate,
         'A null value requires tristate to be true.',
       );

  /// The current value. A null value renders the indeterminate state.
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  /// Text or rich content displayed next to the checkbox.
  final Widget? label;

  /// Alias for [label] for child-oriented composition.
  final Widget? child;
  final Widget? description;
  final bool enabled;
  final bool tristate;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;

  @override
  State<MonoCheckbox> createState() => _MonoCheckboxState();
}

class _MonoCheckboxState extends State<MonoCheckbox> {
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
  void didUpdateWidget(covariant MonoCheckbox oldWidget) {
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
    _statesController.update(MonoState.checked, widget.value == true);
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
    if (!_isEnabled) {
      return;
    }
    final bool? nextValue;
    if (!widget.tristate) {
      nextValue = widget.value != true;
    } else {
      nextValue = switch (widget.value) {
        false => true,
        true => null,
        null => false,
      };
    }
    widget.onChanged?.call(nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final Widget? resolvedLabel = widget.label ?? widget.child;
    final bool isChecked = widget.value == true;
    final bool isMixed = widget.value == null;
    final Color foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final Color borderColor = isChecked || isMixed
        ? theme.colors.primary
        : _isHovered && _isEnabled
        ? theme.colors.foreground
        : theme.colors.input;
    final Color fillColor = isChecked || isMixed
        ? theme.colors.primary
        : theme.colors.background.withAlpha(0);

    final Widget mark = isChecked
        ? CustomPaint(
            painter: _MonoCheckPainter(color: theme.colors.primaryForeground),
            child: const SizedBox.expand(),
          )
        : isMixed
        ? CustomPaint(
            painter: _MonoMinusPainter(color: theme.colors.primaryForeground),
            child: const SizedBox.expand(),
          )
        : const SizedBox.expand();

    final Widget checkbox = AnimatedContainer(
      duration: theme.motion.duration,
      curve: theme.motion.curve,
      width: theme.spacing.xl,
      height: theme.spacing.xl,
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(theme.radii.sm),
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
      child: mark,
    );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Transform.scale(scale: _isPressed ? 0.94 : 1, child: checkbox),
        if (resolvedLabel != null || widget.description != null) ...<Widget>[
          SizedBox(width: theme.spacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
        checked: isChecked,
        mixed: isMixed,
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

class _MonoCheckPainter extends CustomPainter {
  const _MonoCheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.73)
      ..lineTo(size.width * 0.79, size.height * 0.31);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MonoCheckPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _MonoMinusPainter extends CustomPainter {
  const _MonoMinusPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.26, size.height * 0.5),
      Offset(size.width * 0.74, size.height * 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MonoMinusPainter oldDelegate) =>
      color != oldDelegate.color;
}
