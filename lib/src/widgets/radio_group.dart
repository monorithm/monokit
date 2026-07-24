import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';

/// A group of mutually exclusive [MonoRadio] controls.
///
/// A non-null [value] makes the group controlled. Omit it to let the group
/// keep its own selection, optionally seeded by [defaultValue].
class MonoRadioGroup<T> extends StatefulWidget {
  const MonoRadioGroup({
    super.key,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.children = const <Widget>[],
    this.options,
    this.enabled = true,
    this.direction = Axis.vertical,
    this.spacing,
    this.semanticLabel,
  }) : assert(
         value == null || defaultValue == null,
         'Specify value or defaultValue, not both.',
       ),
       assert(
         options == null || children.length == 0,
         'Specify options or children, not both.',
       );

  final T? value;
  final T? defaultValue;
  final ValueChanged<T?>? onChanged;

  /// Usually a list of [MonoRadio] widgets. Arbitrary layout widgets may be
  /// used when they contain radios below them.
  final List<Widget> children;

  /// Convenience data API for simple radio lists.
  final List<MonoRadioOption<T>>? options;
  final bool enabled;
  final Axis direction;
  final double? spacing;
  final String? semanticLabel;

  @override
  State<MonoRadioGroup<T>> createState() => _MonoRadioGroupState<T>();
}

class _MonoRadioGroupState<T> extends State<MonoRadioGroup<T>> {
  late T? _uncontrolledValue;

  bool get _isControlled => widget.value != null;
  T? get _value => _isControlled ? widget.value : _uncontrolledValue;

  @override
  void initState() {
    super.initState();
    _uncontrolledValue = widget.defaultValue;
  }

  @override
  void didUpdateWidget(covariant MonoRadioGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isControlled && oldWidget.defaultValue != widget.defaultValue) {
      _uncontrolledValue = widget.defaultValue;
    }
  }

  void _select(T value) {
    if (!widget.enabled || value == _value) {
      return;
    }
    if (!_isControlled) {
      setState(() => _uncontrolledValue = value);
    }
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final List<Widget> resolvedChildren =
        widget.options
            ?.map(
              (MonoRadioOption<T> option) => MonoRadio<T>(
                value: option.value,
                label: option.label,
                description: option.description,
                enabled: option.enabled,
                semanticLabel: option.semanticLabel,
              ),
            )
            .toList(growable: false) ??
        widget.children;
    final double gap = widget.spacing ?? theme.spacing.sm;
    final Widget layout = widget.direction == Axis.horizontal
        ? Wrap(spacing: gap, runSpacing: gap, children: resolvedChildren)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _spaceVertically(resolvedChildren, gap),
          );

    return _MonoRadioGroupScope<T>(
      value: _value,
      enabled: widget.enabled,
      select: _select,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        child: FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: layout,
        ),
      ),
    );
  }
}

/// Data model used by [MonoRadioGroup.options].
class MonoRadioOption<T> {
  const MonoRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
    this.semanticLabel,
  });

  final T value;
  final Widget label;
  final Widget? description;
  final bool enabled;
  final String? semanticLabel;
}

/// An individual radio choice. It can live inside [MonoRadioGroup] or be used
/// on its own with [groupValue] and [onChanged].
class MonoRadio<T> extends StatefulWidget {
  const MonoRadio({
    super.key,
    required this.value,
    this.groupValue,
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

  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final Widget? label;
  final Widget? child;
  final Widget? description;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;

  @override
  State<MonoRadio<T>> createState() => _MonoRadioState<T>();
}

class _MonoRadioState<T> extends State<MonoRadio<T>> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  _MonoRadioGroupScope<T>? _scope;

  bool get _isSelected => (_scope?.value ?? widget.groupValue) == widget.value;
  bool get _isEnabled =>
      widget.enabled &&
      (_scope?.enabled ?? true) &&
      (_scope != null || widget.onChanged != null);
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
    _statesController.addListener(_handleStatesChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = _MonoRadioGroupScope.maybeOf<T>(context);
    _syncFixedStates();
  }

  @override
  void didUpdateWidget(covariant MonoRadio<T> oldWidget) {
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
    _statesController.update(MonoState.checked, _isSelected);
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

  void _select() {
    if (!_isEnabled || _isSelected) {
      return;
    }
    final _MonoRadioGroupScope<T>? scope = _scope;
    if (scope != null) {
      scope.select(widget.value);
    } else {
      widget.onChanged?.call(widget.value);
    }
  }

  void _moveFocus({required bool forward}) {
    if (forward) {
      _focusNode.nextFocus();
    } else {
      _focusNode.previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final Widget? resolvedLabel = widget.label ?? widget.child;
    final Color foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final Color borderColor = _isSelected
        ? theme.colors.primary
        : _isHovered && _isEnabled
        ? theme.colors.foreground
        : theme.colors.input;

    final Widget marker = AnimatedContainer(
      duration: theme.motion.reduced(context, theme.motion.duration),
      curve: theme.motion.curve,
      width: theme.spacing.xl,
      height: theme.spacing.xl,
      padding: EdgeInsets.all(theme.spacing.xs),
      decoration: BoxDecoration(
        color: theme.colors.background.withAlpha(0),
        border: Border.all(color: borderColor),
        shape: BoxShape.circle,
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
      child: AnimatedScale(
        scale: _isSelected ? (_isPressed ? 0.86 : 1) : 0,
        duration: theme.motion.reduced(context, theme.motion.duration),
        curve: theme.motion.curve,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        marker,
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
        SingleActivator(LogicalKeyboardKey.arrowDown): _MonoRadioNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _MonoRadioNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MonoRadioPreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft):
            _MonoRadioPreviousIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _select();
            return null;
          },
        ),
        _MonoRadioNextIntent: CallbackAction<_MonoRadioNextIntent>(
          onInvoke: (_MonoRadioNextIntent intent) {
            _moveFocus(forward: true);
            return null;
          },
        ),
        _MonoRadioPreviousIntent: CallbackAction<_MonoRadioPreviousIntent>(
          onInvoke: (_MonoRadioPreviousIntent intent) {
            _moveFocus(forward: false);
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
        checked: _isSelected,
        inMutuallyExclusiveGroup: true,
        focusable: _isEnabled,
        focused: _isFocused,
        label: widget.semanticLabel,
        onTap: _isEnabled ? _select : null,
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
          onTap: _isEnabled ? _select : null,
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

class _MonoRadioGroupScope<T> extends InheritedWidget {
  const _MonoRadioGroupScope({
    required this.value,
    required this.enabled,
    required this.select,
    required super.child,
  });

  final T? value;
  final bool enabled;
  final ValueChanged<T> select;

  static _MonoRadioGroupScope<T>? maybeOf<T>(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_MonoRadioGroupScope<T>>();
  }

  @override
  bool updateShouldNotify(covariant _MonoRadioGroupScope<T> oldWidget) {
    return value != oldWidget.value ||
        enabled != oldWidget.enabled ||
        select != oldWidget.select;
  }
}

class _MonoRadioNextIntent extends Intent {
  const _MonoRadioNextIntent();
}

class _MonoRadioPreviousIntent extends Intent {
  const _MonoRadioPreviousIntent();
}

List<Widget> _spaceVertically(List<Widget> children, double spacing) {
  if (children.length < 2) {
    return children;
  }
  final List<Widget> result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    if (index > 0) {
      result.add(SizedBox(height: spacing));
    }
    result.add(children[index]);
  }
  return result;
}
