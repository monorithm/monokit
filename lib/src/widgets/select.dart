import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_overlay_fade.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_placement.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'mono_icon.dart';

/// A selectable value and its presentation in [MonoSelect].
class MonoSelectOption<T> {
  const MonoSelectOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
    this.semanticLabel,
  });

  /// Convenience constructor for a text-only option.
  MonoSelectOption.text({
    required this.value,
    required String label,
    this.description,
    this.enabled = true,
    this.semanticLabel,
  }) : label = Text(label);

  final T value;
  final Widget label;
  final Widget? description;
  final bool enabled;
  final String? semanticLabel;
}

/// Alias for [MonoSelectOption] for codebases that call options items.
typedef MonoSelectItem<T> = MonoSelectOption<T>;

/// A generic, token-driven select control built without Material widgets.
///
/// Set [value] to use controlled selection, or use [defaultValue] for an
/// internally managed selection. Since nullable values cannot distinguish an
/// omitted value from a deliberate empty controlled value, set [controlled] to
/// true when a controlled select should initially have no selection.
class MonoSelect<T> extends StatefulWidget {
  const MonoSelect({
    super.key,
    this.options,
    this.items,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placeholder,
    this.hint,
    this.enabled = true,
    this.invalid = false,
    this.controlled = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.statesController,
    this.selectedBuilder,
    this.optionBuilder,
    this.menuMaxHeight = 280,
  }) : assert(
         (options?.length ?? 0) > 0 || (items?.length ?? 0) > 0,
         'MonoSelect needs at least one option.',
       ),
       assert(
         options == null || items == null,
         'Specify options or items, not both.',
       ),
       assert(
         placeholder == null || hint == null,
         'Specify placeholder or hint, not both.',
       ),
       assert(menuMaxHeight > 0),
       assert(
         !controlled || defaultValue == null,
         'A controlled select cannot use defaultValue.',
       );

  /// Preferred select option declaration.
  final List<MonoSelectOption<T>>? options;

  /// Alias for [options].
  final List<MonoSelectOption<T>>? items;
  final T? value;
  final T? defaultValue;
  final ValueChanged<T?>? onChanged;

  /// Controlled popup open state. Pair with [onOpenChange].
  final bool? open;

  /// Initial popup open state in uncontrolled mode.
  final bool defaultOpen;

  /// Called when the popup wants to open or close.
  final ValueChanged<bool>? onOpenChange;
  final String? placeholder;
  final String? hint;
  final bool enabled;
  final bool invalid;

  /// Explicitly enables controlled mode when [value] is null.
  final bool controlled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;

  /// Replaces the selected option label in the trigger.
  final Widget Function(BuildContext context, MonoSelectOption<T> option)?
  selectedBuilder;

  /// Replaces an option's presentation in the popup.
  final Widget Function(
    BuildContext context,
    MonoSelectOption<T> option,
    bool selected,
    bool highlighted,
  )?
  optionBuilder;

  /// The popup's maximum vertical extent.
  final double menuMaxHeight;

  List<MonoSelectOption<T>> get _options => options ?? items!;

  @override
  State<MonoSelect<T>> createState() => _MonoSelectState<T>();
}

class _MonoSelectState<T> extends State<MonoSelect<T>> {
  OverlayEntry? _entry;
  Rect _anchorRect = Rect.zero;
  bool _overlaySyncScheduled = false;
  late final MonoOverlayFocusController _overlayFocus;
  late T? _uncontrolledValue;
  late bool _uncontrolledOpen;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  List<MonoSelectOption<T>> get _options => widget._options;
  bool get _isControlled => widget.controlled || widget.value != null;
  T? get _selectedValue => _isControlled ? widget.value : _uncontrolledValue;
  bool get _isOpenControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;
  bool get _isEnabled => widget.enabled;
  bool get _isFocused => _statesController.contains(MonoState.focused);
  bool get _isFocusVisible =>
      _statesController.contains(MonoState.focusVisible);
  bool get _isHovered => _statesController.contains(MonoState.hovered);

  @override
  void initState() {
    super.initState();
    _assertUniqueOptions(_options);
    _uncontrolledValue = widget.defaultValue;
    _uncontrolledOpen = widget.defaultOpen;
    if (_isOpen) {
      _scheduleOverlaySync();
    }
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
    _overlayFocus = MonoOverlayFocusController(
      triggerFocusNode: () => _focusNode,
    );
    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncFixedStates();
    _statesController.addListener(_handleStatesChanged);
  }

  @override
  void didUpdateWidget(covariant MonoSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertUniqueOptions(_options);
    if (!_isControlled && oldWidget.defaultValue != widget.defaultValue) {
      _uncontrolledValue = widget.defaultValue;
    }
    if (!_options.any(
      (MonoSelectOption<T> option) => option.value == _selectedValue,
    )) {
      _uncontrolledValue = null;
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
      _statesController.removeListener(_handleStatesChanged);
      if (_ownsStatesController) {
        _statesController.dispose();
      }
      _ownsStatesController = widget.statesController == null;
      _statesController = widget.statesController ?? MonoStatesController();
      _syncFixedStates();
      _statesController.addListener(_handleStatesChanged);
    }
    if (!_isEnabled && _isOpen) {
      _setOpen(false);
    }
    // Controlled open transitioning to closed should restore focus.
    if (oldWidget.open != null &&
        widget.open != null &&
        oldWidget.open! &&
        !widget.open!) {
      _overlayFocus.requestRestoreOnClose();
    }
    _syncFixedStates();
    _scheduleOverlaySync();
  }

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
    _removeOverlayNow();
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

  void _assertUniqueOptions(List<MonoSelectOption<T>> options) {
    assert(() {
      final Set<T> values = <T>{};
      for (final MonoSelectOption<T> option in options) {
        if (!values.add(option.value)) {
          throw FlutterError('Every MonoSelectOption value must be unique.');
        }
      }
      return true;
    }());
  }

  void _handleFocusChanged() {
    _statesController.update(MonoState.focused, _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      _statesController.update(MonoState.focusVisible, false);
    }
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncFixedStates() {
    _statesController.update(MonoState.disabled, !_isEnabled);
    _statesController.update(MonoState.invalid, widget.invalid);
    _statesController.update(MonoState.selected, _selectedValue != null);
    _statesController.update(MonoState.open, _isOpen);
  }

  void _setOpen(bool open) {
    if (open == _isOpen) {
      return;
    }
    if (open && !_isEnabled) {
      return;
    }
    if (_isOpenControlled) {
      widget.onOpenChange?.call(open);
      return;
    }
    setState(() => _uncontrolledOpen = open);
    _statesController.update(MonoState.open, open);
    widget.onOpenChange?.call(open);
    if (!open) {
      _overlayFocus.requestRestoreOnClose();
    }
    _scheduleOverlaySync();
  }

  void _scheduleOverlaySync() {
    if (_overlaySyncScheduled || !mounted) {
      return;
    }
    _overlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      if (!mounted) {
        return;
      }
      if (_isOpen) {
        _showOrRefreshOverlay();
      } else {
        _beginClose();
      }
    });
  }

  bool _overlayVisible = false;

  void _showOrRefreshOverlay() {
    _overlayVisible = true;
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    _showOverlayNow();
  }

  /// Reads the trigger's current global rect, keeping the last known value
  /// when the render box is not laid out (so an open overlay never jumps to
  /// the origin mid-transition).
  Rect _resolveAnchorRect() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      _anchorRect = box.localToGlobal(Offset.zero) & box.size;
    }
    return _anchorRect;
  }

  void _showOverlayNow() {
    if (_entry != null || !mounted) {
      return;
    }
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    assert(
      overlay != null,
      'MonoOverlay: no Overlay ancestor found. Wrap the app in MonokitApp or a Navigator/Overlay.',
    );
    if (overlay == null) {
      return;
    }
    final MonokitThemeData theme = MonokitTheme.of(context);
    _entry = OverlayEntry(
      builder: (BuildContext overlayContext) => MonokitTheme(
        data: theme,
        child: MonoOverlayFade(
          visible: _overlayVisible,
          onExited: _onOverlayExited,
          child: _MonoSelectOverlay<T>(
            anchorRect: _resolveAnchorRect(),
            options: _options,
            selectedValue: _selectedValue,
            optionBuilder: widget.optionBuilder,
            maxHeight: widget.menuMaxHeight,
            onDismiss: () => _setOpen(false),
            onSelected: _select,
          ),
        ),
      ),
    );
    _overlayFocus.captureForOpen();
    overlay.insert(_entry!);
  }

  void _beginClose() {
    if (_entry == null) {
      return;
    }
    _overlayVisible = false;
    _entry!.markNeedsBuild();
  }

  void _onOverlayExited() {
    if (_overlayVisible) {
      return;
    }
    _removeOverlayNow();
  }

  void _removeOverlayNow() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
    _overlayFocus.restoreIfRequested(mounted: mounted, enabled: _isEnabled);
  }

  void _select(T value) {
    if (!_options.any(
      (MonoSelectOption<T> option) => option.value == value && option.enabled,
    )) {
      return;
    }
    if (!_isControlled) {
      setState(() => _uncontrolledValue = value);
    }
    _statesController.update(MonoState.selected, true);
    widget.onChanged?.call(value);
    _setOpen(false);
  }

  MonoSelectOption<T>? _selectedOption() {
    for (final MonoSelectOption<T> option in _options) {
      if (option.value == _selectedValue) {
        return option;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    final MonoSelectOption<T>? selected = _selectedOption();
    final Color borderColor = widget.invalid
        ? theme.colors.destructive
        : _isFocused || _isOpen
        ? theme.colors.ring
        : _isHovered && _isEnabled
        ? theme.colors.foreground
        : theme.colors.input;
    final Color foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final Widget value = selected == null
        ? Text(
            widget.placeholder ?? widget.hint ?? 'Select an option',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.mutedForeground,
            ),
          )
        : (widget.selectedBuilder?.call(context, selected) ?? selected.label);

    return FocusableActionDetector(
      enabled: _isEnabled,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      includeFocusSemantics: false,
      mouseCursor: _isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): _MonoSelectOpenIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): _MonoSelectOpenIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _setOpen(!_isOpen);
            return null;
          },
        ),
        _MonoSelectOpenIntent: CallbackAction<_MonoSelectOpenIntent>(
          onInvoke: (_MonoSelectOpenIntent intent) {
            _setOpen(true);
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
        button: true,
        enabled: _isEnabled,
        expanded: _isOpen,
        focusable: _isEnabled,
        focused: _isFocused,
        label: widget.semanticLabel ?? widget.placeholder ?? 'Select',
        value: selected?.semanticLabel,
        onTap: _isEnabled ? () => _setOpen(!_isOpen) : null,
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
          onTap: _isEnabled ? () => _setOpen(!_isOpen) : null,
          child: AnimatedContainer(
            duration: theme.motion.duration,
            curve: theme.motion.curve,
            constraints: BoxConstraints(minHeight: theme.spacing.huge),
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: _isEnabled
                  ? theme.colors.background.withAlpha(0)
                  : theme.colors.muted.withAlpha(150),
              borderRadius: BorderRadius.circular(theme.radii.md),
              border: Border.all(color: borderColor),
              boxShadow: _isFocusVisible || _isOpen
                  ? <BoxShadow>[
                      BoxShadow(
                        color: theme.colors.ring.withAlpha(72),
                        blurRadius: 0,
                        spreadRadius: 3,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: theme.typography.bodyMedium.copyWith(
                      color: foreground,
                    ),
                    child: value,
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: theme.motion.duration,
                  curve: theme.motion.curve,
                  child: MonoIcon(
                    MonoIcons.chevronDown,
                    size: theme.spacing.lg,
                    color: _isEnabled
                        ? theme.colors.mutedForeground
                        : theme.colors.mutedForeground.withAlpha(150),
                    semanticLabel: _isOpen
                        ? theme.labels.closeOptions
                        : theme.labels.openOptions,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonoSelectOpenIntent extends Intent {
  const _MonoSelectOpenIntent();
}

class _MonoSelectOverlay<T> extends StatefulWidget {
  const _MonoSelectOverlay({
    required this.anchorRect,
    required this.options,
    required this.selectedValue,
    required this.maxHeight,
    required this.onDismiss,
    required this.onSelected,
    this.optionBuilder,
  });

  final Rect anchorRect;
  final List<MonoSelectOption<T>> options;
  final T? selectedValue;
  final double maxHeight;
  final VoidCallback onDismiss;
  final ValueChanged<T> onSelected;
  final Widget Function(
    BuildContext context,
    MonoSelectOption<T> option,
    bool selected,
    bool highlighted,
  )?
  optionBuilder;

  @override
  State<_MonoSelectOverlay<T>> createState() => _MonoSelectOverlayState<T>();
}

class _MonoSelectOverlayState<T> extends State<_MonoSelectOverlay<T>> {
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  late int _highlightedIndex;

  GlobalKey _keyFor(int index) => _itemKeys.putIfAbsent(index, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'MonoSelect menu');
    _scrollController = ScrollController();
    _highlightedIndex = _selectedEnabledIndex() ?? _firstEnabledIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        // Open on the selection, not the top of the list.
        _revealHighlighted(animate: false);
      }
    });
  }

  /// Scrolls the highlighted option into view using its real laid-out
  /// position (replaces the previous fixed 44px row estimate).
  ///
  /// Rows outside the viewport are not built yet, so when the highlighted
  /// row's context is missing this first jumps proportionally into the list
  /// and retries, letting [Scrollable.ensureVisible] finish with exact
  /// positioning once the row exists.
  void _revealHighlighted({bool animate = true, bool retry = true}) {
    final BuildContext? itemContext =
        _itemKeys[_highlightedIndex]?.currentContext;
    if (itemContext != null) {
      final MonokitThemeData theme = MonokitTheme.of(context);
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.5,
        duration: animate ? theme.motion.fast : Duration.zero,
        curve: theme.motion.curve,
      );
      return;
    }
    if (!retry || !_scrollController.hasClients || widget.options.length < 2) {
      return;
    }
    final double estimate =
        _scrollController.position.maxScrollExtent *
        (_highlightedIndex / (widget.options.length - 1));
    _scrollController.jumpTo(
      estimate.clamp(0, _scrollController.position.maxScrollExtent),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _revealHighlighted(animate: false, retry: false);
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MonoSelectOverlay<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_highlightedIndex < 0 ||
        _highlightedIndex >= widget.options.length ||
        !widget.options[_highlightedIndex].enabled) {
      _highlightedIndex = _selectedEnabledIndex() ?? _firstEnabledIndex();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int? _selectedEnabledIndex() {
    final int index = widget.options.indexWhere(
      (MonoSelectOption<T> option) =>
          option.enabled && option.value == widget.selectedValue,
    );
    return index < 0 ? null : index;
  }

  int _firstEnabledIndex() {
    return widget.options.indexWhere(
      (MonoSelectOption<T> option) => option.enabled,
    );
  }

  int _nextEnabledIndex(int from, int direction) {
    if (widget.options.isEmpty) {
      return -1;
    }
    for (int step = 1; step <= widget.options.length; step++) {
      final int rawIndex = (from + direction * step) % widget.options.length;
      final int index = rawIndex < 0
          ? rawIndex + widget.options.length
          : rawIndex;
      if (widget.options[index].enabled) {
        return index;
      }
    }
    return from;
  }

  void _moveHighlight(int direction) {
    final int next = _nextEnabledIndex(
      _highlightedIndex < 0 ? 0 : _highlightedIndex,
      direction,
    );
    if (next < 0 || next == _highlightedIndex) {
      return;
    }
    setState(() => _highlightedIndex = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _revealHighlighted();
      }
    });
  }

  void _selectHighlighted() {
    if (_highlightedIndex < 0 || _highlightedIndex >= widget.options.length) {
      return;
    }
    final MonoSelectOption<T> option = widget.options[_highlightedIndex];
    if (option.enabled) {
      widget.onSelected(option.value);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.escape:
        widget.onDismiss();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        _moveHighlight(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _moveHighlight(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        final int first = _firstEnabledIndex();
        if (first >= 0) {
          setState(() => _highlightedIndex = first);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        final int last = widget.options.lastIndexWhere(
          (MonoSelectOption<T> option) => option.enabled,
        );
        if (last >= 0) {
          setState(() => _highlightedIndex = last);
        }
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _selectHighlighted();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ExcludeSemantics(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: const SizedBox.expand(),
          ),
        ),
        MonoAnchoredOverlay(
          anchorRect: widget.anchorRect,
          placement: MonoPlacement.bottomStart,
          gap: theme.spacing.xs,
          matchAnchorWidth: true,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: Semantics(
              container: true,
              label: theme.labels.selectOptions,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.popover,
                  borderRadius: BorderRadius.circular(theme.radii.md),
                  border: Border.all(color: theme.colors.border),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: theme.colors.foreground.withAlpha(38),
                      blurRadius: theme.spacing.lg,
                      offset: Offset(0, theme.spacing.sm / 2),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: RawScrollbar(
                    controller: _scrollController,
                    thumbColor: theme.colors.border,
                    radius: Radius.circular(theme.radii.full),
                    thickness: theme.spacing.xs,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(theme.spacing.xs),
                      shrinkWrap: true,
                      itemCount: widget.options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MonoSelectOption<T> option =
                            widget.options[index];
                        final bool selected =
                            option.value == widget.selectedValue;
                        final bool highlighted = index == _highlightedIndex;
                        final Widget defaultOption = _MonoSelectOptionTile<T>(
                          option: option,
                          selected: selected,
                          highlighted: highlighted,
                          onTap: option.enabled
                              ? () => widget.onSelected(option.value)
                              : null,
                        );
                        if (widget.optionBuilder == null) {
                          return KeyedSubtree(
                            key: _keyFor(index),
                            child: defaultOption,
                          );
                        }
                        return KeyedSubtree(
                          key: _keyFor(index),
                          child: Semantics(
                            button: true,
                            enabled: option.enabled,
                            selected: selected,
                            label: option.semanticLabel,
                            onTap: option.enabled
                                ? () => widget.onSelected(option.value)
                                : null,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: option.enabled
                                  ? () => widget.onSelected(option.value)
                                  : null,
                              onTapDown: option.enabled
                                  ? (_) => setState(
                                      () => _highlightedIndex = index,
                                    )
                                  : null,
                              child: widget.optionBuilder!(
                                context,
                                option,
                                selected,
                                highlighted,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonoSelectOptionTile<T> extends StatelessWidget {
  const _MonoSelectOptionTile({
    required this.option,
    required this.selected,
    required this.highlighted,
    this.onTap,
  });

  final MonoSelectOption<T> option;
  final bool selected;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    final Color foreground = option.enabled
        ? theme.colors.popoverForeground
        : theme.colors.mutedForeground;
    final Color background = selected || highlighted
        ? theme.colors.accent
        : theme.colors.popover.withAlpha(0);
    return Semantics(
      button: true,
      enabled: option.enabled,
      selected: selected,
      label: option.semanticLabel,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: theme.motion.fast,
          curve: theme.motion.curve,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.sm,
            vertical: theme.spacing.sm,
          ),
          constraints: BoxConstraints(minHeight: theme.spacing.xxxl),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radii.sm),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DefaultTextStyle.merge(
                      style: theme.typography.bodyMedium.copyWith(
                        color: foreground,
                      ),
                      child: option.label,
                    ),
                    if (option.description != null) ...<Widget>[
                      SizedBox(height: theme.spacing.xs),
                      DefaultTextStyle.merge(
                        style: theme.typography.labelMedium.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        child: option.description!,
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...<Widget>[
                SizedBox(width: theme.spacing.sm),
                MonoIcon(
                  MonoIcons.check,
                  size: theme.spacing.lg,
                  color: theme.colors.popoverForeground,
                  semanticLabel: 'Selected',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
