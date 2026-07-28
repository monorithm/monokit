import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../primitives/mono_text_scale.dart';
import '../primitives/mono_text_selection.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// A compact, token-driven text input built directly on [EditableText].
///
/// This deliberately does not depend on Material's `TextField`, which makes it
/// safe to use in a widgets-only [MonokitApp]. Supply a [controller] to own the
/// field value, or omit it and use [initialValue] for an internally managed
/// controller.
class MonoInput extends StatefulWidget {
  const MonoInput({
    super.key,
    this.controller,
    this.focusNode,
    this.initialValue,
    this.placeholder,
    this.semanticLabel,
    this.enabled = true,
    this.readOnly = false,
    this.invalid = false,
    this.autofocus = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints = const <String>[],
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.enableInteractiveSelection = true,
    this.textAlign = TextAlign.start,
    this.style,
    this.placeholderStyle,
    this.cursorColor,
    this.selectionColor,
    this.padding,
    this.prefix,
    this.suffix,
    this.mouseCursor,
    this.scrollController,
    this.scrollPhysics,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.onFocusChanged,
    this.statesController,
    this.restorationId,
    this.showCounter = false,
    this.dismissKeyboardOnTapOutside,
  }) : assert(
         controller == null || initialValue == null,
         'Specify either controller or initialValue, not both.',
       ),
       assert(maxLength == null || maxLength >= 0),
       assert(
         !expands || (minLines == null && maxLines == null),
         'minLines and maxLines must be null when expands is true.',
       ),
       assert(
         !obscureText || maxLines == 1,
         'Obscured inputs must be single-line.',
       );

  /// Controls the input value. If omitted, this widget owns its controller.
  final TextEditingController? controller;

  /// Focus node for this field. If omitted, this widget owns a focus node.
  final FocusNode? focusNode;

  /// Initial text for an internally managed [controller].
  final String? initialValue;

  /// Text shown while the input is empty.
  final String? placeholder;

  /// Accessibility label. [placeholder] is used when this is omitted.
  final String? semanticLabel;

  final bool enabled;
  final bool readOnly;
  final bool invalid;
  final bool autofocus;
  final bool obscureText;
  final String obscuringCharacter;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String> autofillHints;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool enableInteractiveSelection;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final Color? cursorColor;
  final Color? selectionColor;
  final EdgeInsetsGeometry? padding;
  final Widget? prefix;
  final Widget? suffix;
  final MouseCursor? mouseCursor;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFocusChanged;

  /// Optional shared state controller for focus, hover, disabled, and invalid
  /// visual state. When omitted, the input creates one for its own lifetime.
  final MonoStatesController? statesController;

  /// Restoration id. When set (and no external [controller] is supplied), the
  /// field's text and selection survive the app being killed and relaunched.
  final String? restorationId;

  /// Shows a `current/max` character counter below the field. Requires
  /// [maxLength]. The count is always exposed to screen readers via
  /// `maxValueLength`/`currentValueLength` regardless of this flag.
  final bool showCounter;

  /// Whether tapping outside this field drops its focus and the software
  /// keyboard. Defaults to `MonokitFocus.dismissKeyboardOnTapOutside`.
  ///
  /// Set false for a field that must survive taps on the surrounding UI — a
  /// chat composer whose message list is tappable, say — which restores
  /// Flutter's platform default (desktop and non-touch pointers still unfocus).
  final bool? dismissKeyboardOnTapOutside;

  @override
  State<MonoInput> createState() => _MonoInputState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('placeholder', placeholder, defaultValue: null))
      ..add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'))
      ..add(FlagProperty('readOnly', value: readOnly, ifTrue: 'readOnly'))
      ..add(FlagProperty('invalid', value: invalid, ifTrue: 'invalid'))
      ..add(FlagProperty('obscureText', value: obscureText, ifTrue: 'obscured'))
      ..add(IntProperty('maxLength', maxLength, defaultValue: null));
  }
}

class _MonoInputState extends State<MonoInput>
    with RestorationMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  /// The owned controller, present only when no external [MonoInput.controller]
  /// is supplied. Registered for state restoration.
  RestorableTextEditingController? _localController;
  TextEditingController get _controller =>
      widget.controller ?? _localController!.value;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_localController != null) {
      _registerController();
    }
  }

  void _registerController() {
    registerForRestoration(_localController!, 'controller');
    _localController!.value.removeListener(_handleTextChanged);
    _localController!.value.addListener(_handleTextChanged);
  }

  void _createLocalController([TextEditingValue? value]) {
    _localController = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();
  late final TextSelectionGestureDetectorBuilder _selectionGestureBuilder =
      TextSelectionGestureDetectorBuilder(delegate: this);
  final MonoTextSelectionControls _selectionControls =
      MonoTextSelectionControls();

  // A raw EditableText keeps selection handles hidden unless the host toggles
  // `showSelectionHandles` (Material's TextField manages this; we must too).
  // Without it the drag handles never appear even though selection works.
  bool _showSelectionHandles = false;

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    final bool willShow = _shouldShowSelectionHandles(cause);
    if (willShow != _showSelectionHandles) {
      setState(() => _showSelectionHandles = willShow);
    }
  }

  bool _shouldShowSelectionHandles(SelectionChangedCause? cause) {
    if (!_selectionGestureBuilder.shouldShowSelectionToolbar) return false;
    if (cause == SelectionChangedCause.keyboard) return false;
    if (widget.readOnly && _controller.selection.isCollapsed) return false;
    if (cause == SelectionChangedCause.longPress ||
        cause == SelectionChangedCause.stylusHandwriting) {
      return true;
    }
    return _controller.text.isNotEmpty;
  }

  // TextSelectionGestureDetectorBuilderDelegate.
  @override
  GlobalKey<EditableTextState> get editableTextKey => _editableTextKey;
  @override
  bool get forcePressEnabled => true;
  @override
  bool get selectionEnabled => widget.enableInteractiveSelection && _isEnabled;

  bool get _isEnabled => widget.enabled;
  bool get _isFocused => _statesController.contains(MonoState.focused);
  bool get _isHovered => _statesController.contains(MonoState.hovered);

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController(
        widget.initialValue == null
            ? null
            : TextEditingValue(text: widget.initialValue!),
      );
    } else {
      widget.controller!.addListener(_handleTextChanged);
    }

    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);

    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncFixedStates();
  }

  @override
  void didUpdateWidget(covariant MonoInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller == null && oldWidget.controller != null) {
      // External controller removed → adopt an owned restorable one seeded with
      // the last value.
      oldWidget.controller!.removeListener(_handleTextChanged);
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      // External controller supplied → drop the owned one.
      unregisterFromRestoration(_localController!);
      _localController!.value.removeListener(_handleTextChanged);
      _localController!.dispose();
      _localController = null;
      widget.controller!.addListener(_handleTextChanged);
    } else if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChanged);
      widget.controller?.addListener(_handleTextChanged);
    } else if (widget.controller == null &&
        oldWidget.initialValue != widget.initialValue) {
      _controller.value = _controller.value.copyWith(
        text: widget.initialValue ?? '',
        selection: TextSelection.collapsed(
          offset: (widget.initialValue ?? '').length,
        ),
        composing: TextRange.empty,
      );
    }

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
      if (_ownsStatesController) {
        _statesController.dispose();
      }
      _ownsStatesController = widget.statesController == null;
      _statesController = widget.statesController ?? MonoStatesController();
      _syncFixedStates();
    }

    if (!_isEnabled && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _syncFixedStates();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _focusNode.removeListener(_handleFocusChanged);
    _localController?.dispose();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsStatesController) {
      _statesController.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChanged() {
    _setState(MonoState.focused, _focusNode.hasFocus);
    _setState(MonoState.focusVisible, _focusNode.hasFocus);
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  void _syncFixedStates() {
    _statesController.update(MonoState.disabled, !_isEnabled);
    _statesController.update(MonoState.invalid, widget.invalid);
  }

  void _setState(MonoState state, bool value) =>
      _statesController.update(state, value);

  void _handleHover(bool hovered) {
    _setState(MonoState.hovered, hovered);
  }

  void _requestFocus() {
    if (!_isEnabled) {
      return;
    }
    _focusNode.requestFocus();
    widget.onTap?.call();
  }

  /// Handles a screen-reader activation (VoiceOver/TalkBack double-tap).
  ///
  /// [TextSelectionGestureDetector] builds with `excludeFromSemantics: true`,
  /// so the pointer gestures below contribute no semantics action at all —
  /// without this the field advertises `textField: true` with an empty action
  /// set and assistive technology has no way to put the caret in it. Material's
  /// `TextField` compensates the same way.
  void _handleSemanticsTap() {
    if (!_isEnabled) {
      return;
    }
    if (!_controller.selection.isValid) {
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
    _editableTextKey.currentState?.requestKeyboard();
    widget.onTap?.call();
  }

  /// Whether a pointer-down outside this field should drop focus. Per-field
  /// override first, then the theme token.
  bool _dismissesOnTapOutside(MonokitThemeData theme) =>
      widget.dismissKeyboardOnTapOutside ??
      theme.focus.dismissKeyboardOnTapOutside;

  /// Wraps the field body in the text-selection gesture detector (tap to place
  /// the caret, double-tap/long-press to select, drag to extend, secondary tap
  /// for the context menu) when selection is enabled; otherwise a plain
  /// tap-to-focus detector.
  Widget _wrapWithGestures(Widget child) {
    if (selectionEnabled) {
      final Widget detector = _selectionGestureBuilder.buildGestureDetector(
        behavior: HitTestBehavior.opaque,
        child: child,
      );
      // Route the tap-to-focus side effect (onTap callback) without disturbing
      // the selection gestures.
      return Listener(
        onPointerUp: (_) => widget.onTap?.call(),
        child: detector,
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _isEnabled ? _requestFocus : null,
      child: child,
    );
  }

  List<TextInputFormatter>? _resolvedInputFormatters() {
    if (widget.maxLength == null) {
      return widget.inputFormatters;
    }
    return <TextInputFormatter>[
      ...?widget.inputFormatters,
      LengthLimitingTextInputFormatter(widget.maxLength),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final bool hasText = _controller.text.isNotEmpty;
    final Color foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.foregroundMuted;
    final Color background = _isEnabled
        ? theme.colors.page.withAlpha(0)
        : theme.colors.fill.withAlpha(150);
    final Color resolvedSelectionColor =
        widget.selectionColor ?? theme.colors.ring.withAlpha(80);
    final EdgeInsetsGeometry resolvedPadding =
        widget.padding ??
        EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        );
    final TextStyle inputStyle = (widget.style ?? theme.typography.bodyMedium)
        .copyWith(color: foreground);
    final TextStyle hintStyle =
        (widget.placeholderStyle ?? theme.typography.bodyMedium).copyWith(
          color: theme.colors.foregroundMuted,
        );

    final Widget editable = Stack(
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        if (!hasText && widget.placeholder != null)
          IgnorePointer(
            child: Text(
              widget.placeholder!,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
              style: hintStyle,
              textAlign: widget.textAlign,
            ),
          ),
        EditableText(
          key: _editableTextKey,
          controller: _controller,
          focusNode: _focusNode,
          restorationId: 'editable',
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          style: inputStyle,
          cursorColor: widget.cursorColor ?? theme.colors.foreground,
          backgroundCursorColor: theme.colors.foreground,
          selectionColor: resolvedSelectionColor,
          selectionControls: widget.enableInteractiveSelection
              ? _selectionControls
              : null,
          showSelectionHandles: _showSelectionHandles,
          onSelectionChanged: _handleSelectionChanged,
          contextMenuBuilder: widget.enableInteractiveSelection
              ? monoContextMenuBuilder
              : null,
          magnifierConfiguration: monoMagnifierConfiguration,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: _resolvedInputFormatters(),
          autofillHints: widget.autofillHints,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          expands: widget.expands,
          autofocus: widget.autofocus,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          textAlign: widget.textAlign,
          scrollController: widget.scrollController,
          scrollPhysics: widget.scrollPhysics,
          rendererIgnoresPointer: true,
          mouseCursor: widget.mouseCursor ?? SystemMouseCursors.text,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          // Flutter's default ignores touch taps on native Android/iOS, which
          // leaves the software keyboard up with no way to put it away. Passing
          // a handler replaces that default outright; passing null restores it.
          // Which pointers reach here is already decided by the framework's
          // TextFieldTapRegion grouping, so a tap on another field — or on a
          // combobox/command-palette panel — never lands in this callback.
          onTapOutside: _dismissesOnTapOutside(theme)
              ? (PointerDownEvent event) => _focusNode.unfocus()
              : null,
        ),
      ],
    );

    final int? currentLength = widget.maxLength == null
        ? null
        : _controller.text.characters.length;
    final Widget field = Semantics(
      container: true,
      textField: true,
      enabled: _isEnabled,
      readOnly: widget.readOnly,
      label: widget.semanticLabel ?? widget.placeholder,
      maxValueLength: widget.maxLength,
      currentValueLength: currentLength,
      onTap: widget.readOnly ? null : _handleSemanticsTap,
      child: MouseRegion(
        cursor:
            widget.mouseCursor ??
            (_isEnabled
                ? SystemMouseCursors.text
                : SystemMouseCursors.forbidden),
        onEnter: _isEnabled ? (_) => _handleHover(true) : null,
        onExit: _isEnabled ? (_) => _handleHover(false) : null,
        // Only the bordered container's decoration reads interaction state, so
        // hover/focus ticks rebuild just that box — the EditableText and its Row
        // are passed through untouched as the builder's `child`.
        child: _wrapWithGestures(
          ListenableBuilder(
            listenable: _statesController,
            child: Padding(
              padding: resolvedPadding,
              child: Row(
                crossAxisAlignment: widget.maxLines == 1
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.prefix != null) ...<Widget>[
                    IconTheme.merge(
                      data: IconThemeData(color: theme.colors.foregroundMuted),
                      child: widget.prefix!,
                    ),
                    SizedBox(width: theme.spacing.sm),
                  ],
                  Expanded(child: editable),
                  if (widget.suffix != null) ...<Widget>[
                    SizedBox(width: theme.spacing.sm),
                    IconTheme.merge(
                      data: IconThemeData(color: theme.colors.foregroundMuted),
                      child: widget.suffix!,
                    ),
                  ],
                ],
              ),
            ),
            builder: (BuildContext context, Widget? child) {
              final Color borderColor = widget.invalid
                  ? theme.colors.danger
                  : _isFocused
                  ? theme.colors.ring
                  : _isHovered && _isEnabled
                  ? theme.colors.foreground
                  : theme.colors.separator;
              return AnimatedContainer(
                duration: theme.motion.duration,
                curve: theme.motion.curve,
                constraints: BoxConstraints(
                  minHeight: monoScaledExtent(context, theme.spacing.huge),
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(theme.radii.lg),
                  border: Border.all(color: borderColor),
                  boxShadow: widget.invalid
                      ? theme.focus.ringShadow(theme.colors.danger, alpha: 0.2)
                      : _isFocused
                      ? theme.focus.ringShadow(theme.colors.ring)
                      : null,
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );

    final Widget decorated = !widget.showCounter || widget.maxLength == null
        ? field
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              field,
              Padding(
                padding: EdgeInsets.only(top: theme.spacing.xs),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: ExcludeSemantics(
                    child: Text(
                      '$currentLength/${widget.maxLength}',
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

    // Everything the user reads as "the field" joins the tap region, not just
    // the EditableText's own box: border, padding, prefix, suffix, counter.
    // Without this a click on the field's own padding counts as a tap *outside*
    // it — on desktop and the web that unfocuses and then immediately refocuses
    // via the selection gestures, flickering the ring and tearing down the IME
    // connection for no reason. Material's TextField wraps the same way.
    return TextFieldTapRegion(child: decorated);
  }
}
