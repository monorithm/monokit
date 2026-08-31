import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../primitives/mono_field_skin.dart';
import '../primitives/mono_focus_ring.dart';
import '../theme/monokit_theme.dart';

/// A multi-cell one-time-password input built from [EditableText] controls.
///
/// It handles typing, paste, backspace, left/right navigation, focus movement,
/// and completion without depending on Material's text-field widgets.
class MonoInputOtp extends StatefulWidget {
  const MonoInputOtp({
    super.key,
    required this.length,
    this.value,
    this.defaultValue,
    this.controlled = false,
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.invalid = false,
    this.autofocus = false,
    this.focusNode,
    this.semanticLabel,
    this.statesController,
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters = const <TextInputFormatter>[],
    this.numeric = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.cellSize,
    this.spacing,
    this.dismissKeyboardOnTapOutside,
  }) : assert(length > 0),
       assert(
         !controlled || defaultValue == null,
         'A controlled OTP input cannot use defaultValue.',
       ),
       assert(cellSize == null || cellSize > 0),
       assert(spacing == null || spacing >= 0);

  /// Number of cells in the code.
  final int length;

  /// A controlled code value. Set [controlled] for a controlled empty value.
  final String? value;
  final String? defaultValue;
  final bool controlled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final bool invalid;
  final bool autofocus;

  /// Whether tapping outside the code drops focus and the software keyboard.
  /// Defaults to `MonokitFocus.dismissKeyboardOnTapOutside`. Moving between
  /// cells is never "outside" — every cell shares one tap region group.
  final bool? dismissKeyboardOnTapOutside;

  /// Optional focus node for the first cell.
  final FocusNode? focusNode;
  final String? semanticLabel;
  final MonoStatesController? statesController;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter> inputFormatters;

  /// Adds a digit-only formatter before [inputFormatters].
  final bool numeric;
  final bool obscureText;
  final String obscuringCharacter;
  final double? cellSize;
  final double? spacing;

  @override
  State<MonoInputOtp> createState() => _MonoInputOtpState();
}

class _MonoInputOtpState extends State<MonoInputOtp> {
  final List<TextEditingController> _controllers = <TextEditingController>[];
  final List<FocusNode> _focusNodes = <FocusNode>[];
  final List<VoidCallback> _focusListeners = <VoidCallback>[];
  late MonoStatesController _statesController;
  late bool _ownsStatesController;
  late bool _ownsFirstFocusNode;
  bool _applyingValue = false;
  String? _lastCompletedValue;

  bool get _isControlled => widget.controlled || widget.value != null;
  bool get _isEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _createFields();
    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncFixedStates();
    _statesController.addListener(_handleStatesChanged);
    _applyValue(_isControlled ? widget.value ?? '' : widget.defaultValue ?? '');
  }

  @override
  void didUpdateWidget(covariant MonoInputOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool fieldsChanged =
        oldWidget.length != widget.length ||
        oldWidget.focusNode != widget.focusNode;
    if (fieldsChanged) {
      _disposeFields();
      _createFields();
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
    if (fieldsChanged || (_isControlled && oldWidget.value != widget.value)) {
      _applyValue(widget.value ?? '');
    } else if (!_isControlled &&
        oldWidget.defaultValue != widget.defaultValue) {
      _applyValue(widget.defaultValue ?? '');
    }
    if (!_isEnabled) {
      for (final FocusNode node in _focusNodes) {
        if (node.hasFocus) {
          node.unfocus();
        }
      }
    }
    _syncFixedStates();
  }

  @override
  void dispose() {
    _disposeFields();
    _statesController.removeListener(_handleStatesChanged);
    if (_ownsStatesController) {
      _statesController.dispose();
    }
    super.dispose();
  }

  void _createFields() {
    _ownsFirstFocusNode = widget.focusNode == null;
    for (int index = 0; index < widget.length; index++) {
      final FocusNode node = index == 0 && widget.focusNode != null
          ? widget.focusNode!
          : FocusNode(debugLabel: 'MonoInputOtp ${index + 1}');
      void listener() => _handleFocusChange(index);
      node.addListener(listener);
      _focusNodes.add(node);
      _focusListeners.add(listener);
      _controllers.add(TextEditingController());
    }
  }

  void _disposeFields() {
    for (int index = 0; index < _focusNodes.length; index++) {
      _focusNodes[index].removeListener(_focusListeners[index]);
      if (index > 0 || _ownsFirstFocusNode) {
        _focusNodes[index].dispose();
      }
      _controllers[index].dispose();
    }
    _focusNodes.clear();
    _focusListeners.clear();
    _controllers.clear();
  }

  void _handleFocusChange(int index) {
    final bool focused = _focusNodes[index].hasFocus;
    if (focused && _controllers[index].text.isNotEmpty) {
      _controllers[index].selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controllers[index].text.length,
      );
    }
    _statesController.update(
      MonoState.focused,
      _focusNodes.any((FocusNode node) => node.hasFocus),
    );
    if (focused) {
      _statesController.update(MonoState.focusVisible, true);
    }
    if (!focused && !_focusNodes.any((FocusNode node) => node.hasFocus)) {
      _statesController.update(MonoState.focusVisible, false);
    }
  }

  void _syncFixedStates() {
    _statesController.update(MonoState.disabled, !_isEnabled);
    _statesController.update(MonoState.invalid, widget.invalid);
    _statesController.update(
      MonoState.checked,
      _value().length == widget.length,
    );
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _value() => _controllers
      .map((TextEditingController controller) => controller.text)
      .join();

  String _normalise(String value) {
    final List<String> characters = value
        .replaceAll(RegExp(r'\s+'), '')
        .split('');
    return characters.take(widget.length).join();
  }

  void _applyValue(String value) {
    final List<String> characters = _normalise(value).split('');
    _applyingValue = true;
    for (int index = 0; index < _controllers.length; index++) {
      final String text = index < characters.length ? characters[index] : '';
      _controllers[index].value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    _applyingValue = false;
    _syncFixedStates();
  }

  List<TextInputFormatter> _formatters() {
    return <TextInputFormatter>[
      if (widget.numeric) FilteringTextInputFormatter.digitsOnly,
      ...widget.inputFormatters,
    ];
  }

  void _handleChanged(int index, String input) {
    if (_applyingValue) {
      return;
    }
    final List<String> characters = input.split('');
    if (characters.length > 1) {
      _applyingValue = true;
      for (
        int offset = 0;
        offset < characters.length && index + offset < _controllers.length;
        offset++
      ) {
        final TextEditingController controller = _controllers[index + offset];
        final String value = characters[offset];
        controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
      }
      _applyingValue = false;
      final int next = (index + characters.length)
          .clamp(0, _controllers.length - 1)
          .toInt();
      _focusNodes[next].requestFocus();
    } else if (characters.isNotEmpty && index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _emitValue();
  }

  void _emitValue() {
    final String value = _value();
    _syncFixedStates();
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      if (_lastCompletedValue != value) {
        _lastCompletedValue = value;
        widget.onCompleted?.call(value);
      }
    } else {
      _lastCompletedValue = null;
    }
  }

  KeyEventResult _handleKeyEvent(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _emitValue();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final skin = MonoFieldSkin.of(context, MonoInputSize.large);
    final double cellSize = widget.cellSize ?? skin.height;
    final double gap = widget.spacing ?? theme.spacing.sm;
    final bool focusVisible = _statesController.contains(
      MonoState.focusVisible,
    );
    final bool dismissOnTapOutside =
        widget.dismissKeyboardOnTapOutside ??
        theme.focus.dismissKeyboardOnTapOutside;
    final List<Widget> fields = <Widget>[];
    for (int index = 0; index < _controllers.length; index++) {
      final bool focused = _focusNodes[index].hasFocus;
      fields.add(
        Focus(
          canRequestFocus: false,
          onKeyEvent: (FocusNode node, KeyEvent event) =>
              _handleKeyEvent(index, node, event),
          child: Semantics(
            container: true,
            textField: true,
            enabled: _isEnabled,
            focused: focused,
            label:
                '${widget.semanticLabel ?? 'One-time code'}, digit ${index + 1} of ${widget.length}',
            value: _controllers[index].text.isEmpty ? 'Empty' : 'Entered',
            currentValueLength: _controllers[index].text.length,
            maxValueLength: 1,
            child: MouseRegion(
              cursor: _isEnabled
                  ? SystemMouseCursors.text
                  : SystemMouseCursors.forbidden,
              child: MonoFocusRingOverlay(
                focused: widget.invalid || (focused && focusVisible),
                borderRadius: skin.radius,
                color: widget.invalid ? theme.colors.destructive : null,
                child: AnimatedContainer(
                  duration: theme.motion.duration,
                  curve: theme.motion.curve,
                  width: cellSize,
                  height: cellSize,
                  alignment: Alignment.center,
                  decoration: skin.well(context, enabled: _isEnabled),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
                    child: EditableText(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      readOnly: !_isEnabled,
                      autofocus: widget.autofocus && index == 0,
                      obscureText: widget.obscureText,
                      obscuringCharacter: widget.obscuringCharacter,
                      style: theme.typography
                          .tabular(skin.value)
                          .copyWith(
                            color: _isEnabled
                                ? theme.colors.foreground
                                : theme.colors.mutedForeground,
                          ),
                      textAlign: TextAlign.center,
                      cursorColor: theme.colors.foreground,
                      backgroundCursorColor: theme.colors.foreground,
                      selectionColor: theme.colors.ring.withAlpha(80),
                      keyboardType: widget.keyboardType,
                      textInputAction: index == _controllers.length - 1
                          ? TextInputAction.done
                          : widget.textInputAction,
                      inputFormatters: _formatters(),
                      maxLines: 1,
                      onChanged: (String value) => _handleChanged(index, value),
                      onSubmitted: (_) {
                        if (index < _focusNodes.length - 1) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                      // Every cell defaults to the same tap region group, so
                      // this only fires for a tap outside the whole code —
                      // hopping between cells never reaches it.
                      onTapOutside: dismissOnTapOutside
                          ? (PointerDownEvent event) =>
                                _focusNodes[index].unfocus()
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      // The gaps between cells belong to the code, not to the page behind it,
      // so the whole row joins the tap region rather than just the cell boxes.
      child: TextFieldTapRegion(
        child: Semantics(
          container: true,
          label: widget.semanticLabel ?? 'One-time code',
          child: Wrap(spacing: gap, runSpacing: gap, children: fields),
        ),
      ),
    );
  }
}
