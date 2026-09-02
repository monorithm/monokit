import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_overlay_fade.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_placement.dart';
import '../theme/monokit_layout.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_elevation.dart';
import '../primitives/mono_field_skin.dart';
import '../primitives/mono_focus_ring.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'mono_icon.dart';

/// A searchable value declaration for [MonoCombobox].
class MonoComboboxOption<T> {
  const MonoComboboxOption({
    required this.value,
    required this.label,
    this.description,
    this.searchText,
    this.enabled = true,
    this.semanticLabel,
  });

  MonoComboboxOption.text({
    required this.value,
    required String label,
    this.description,
    this.enabled = true,
    this.semanticLabel,
  }) : label = Text(label),
       searchText = label;

  final T value;
  final Widget label;
  final Widget? description;
  final String? searchText;
  final bool enabled;
  final String? semanticLabel;

  String get _filterText =>
      '${searchText ?? ''} ${semanticLabel ?? ''}'.toLowerCase();
}

/// Alias for teams that call selectable options items.
typedef MonoComboboxItem<T> = MonoComboboxOption<T>;

/// A searchable, anchored select control built from Widgets primitives.
class MonoCombobox<T> extends StatefulWidget {
  const MonoCombobox({
    super.key,
    this.options,
    this.items,
    this.value,
    this.defaultValue,
    this.controlled = false,
    this.onChanged,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placeholder = 'Select an option',
    this.searchPlaceholder = 'Search options…',
    this.size = MonoInputSize.medium,
    this.enabled = true,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.statesController,
    this.selectedBuilder,
    this.optionBuilder,
    this.menuMaxHeight = 280,
  }) : assert(
         (options?.length ?? 0) > 0 || (items?.length ?? 0) > 0,
         'MonoCombobox needs at least one option.',
       ),
       assert(
         options == null || items == null,
         'Specify options or items, not both.',
       ),
       assert(
         !controlled || defaultValue == null,
         'A controlled combobox cannot use defaultValue.',
       ),
       assert(menuMaxHeight > 0);

  final List<MonoComboboxOption<T>>? options;
  final List<MonoComboboxOption<T>>? items;
  final T? value;
  final T? defaultValue;
  final bool controlled;
  final ValueChanged<T?>? onChanged;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final String placeholder;
  final String searchPlaceholder;

  /// Which of the three field heights this control takes. Shared with
  /// [MonoInput] so a combobox and an input in the same form line up.
  final MonoInputSize size;

  final bool enabled;
  final bool invalid;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;
  final Widget Function(BuildContext context, MonoComboboxOption<T> option)?
  selectedBuilder;
  final Widget Function(
    BuildContext context,
    MonoComboboxOption<T> option,
    bool selected,
    bool highlighted,
  )?
  optionBuilder;
  final double menuMaxHeight;

  List<MonoComboboxOption<T>> get _options => options ?? items!;

  @override
  State<MonoCombobox<T>> createState() => _MonoComboboxState<T>();
}

class _MonoComboboxState<T> extends State<MonoCombobox<T>> {
  Rect _anchorRect = Rect.zero;
  OverlayEntry? _entry;
  bool _overlaySyncScheduled = false;
  late final MonoOverlayFocusController _overlayFocus;
  late T? _uncontrolledValue;
  late bool _uncontrolledOpen;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  List<MonoComboboxOption<T>> get _options => widget._options;
  bool get _isValueControlled => widget.controlled || widget.value != null;
  bool get _isOpenControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;
  T? get _selectedValue =>
      _isValueControlled ? widget.value : _uncontrolledValue;
  bool get _isEnabled => widget.enabled;

  @override
  void initState() {
    super.initState();
    _assertUniqueOptions();
    _uncontrolledValue = widget.defaultValue;
    _uncontrolledOpen = widget.defaultOpen;
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'MonoCombobox');
    _focusNode.addListener(_handleFocusChanged);
    _overlayFocus = MonoOverlayFocusController(
      triggerFocusNode: () => _focusNode,
    );
    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncStates();
    if (_isOpen) {
      _scheduleOverlaySync();
    }
  }

  @override
  void didUpdateWidget(covariant MonoCombobox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertUniqueOptions();
    if (!_isValueControlled && oldWidget.defaultValue != widget.defaultValue) {
      _uncontrolledValue = widget.defaultValue;
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode(debugLabel: 'MonoCombobox');
      _focusNode.addListener(_handleFocusChanged);
    }
    if (oldWidget.statesController != widget.statesController) {
      if (_ownsStatesController) {
        _statesController.dispose();
      }
      _ownsStatesController = widget.statesController == null;
      _statesController = widget.statesController ?? MonoStatesController();
    }
    if (!_isEnabled && _isOpen) {
      _setOpen(false);
    }
    _syncStates();
    _scheduleOverlaySync();
  }

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
    _removeOverlayNow();
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsStatesController) {
      _statesController.dispose();
    }
    super.dispose();
  }

  void _assertUniqueOptions() {
    assert(() {
      final values = <T>{};
      for (final option in _options) {
        if (!values.add(option.value)) {
          throw FlutterError('Every MonoComboboxOption value must be unique.');
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

  void _syncStates() {
    _statesController
      ..update(MonoState.disabled, !_isEnabled)
      ..update(MonoState.invalid, widget.invalid)
      ..update(MonoState.selected, _selectedValue != null)
      ..update(MonoState.open, _isOpen);
  }

  MonoComboboxOption<T>? _selectedOption() {
    for (final option in _options) {
      if (option.value == _selectedValue) {
        return option;
      }
    }
    return null;
  }

  void _setOpen(bool value) {
    if (value == _isOpen || (value && !_isEnabled)) {
      return;
    }
    if (!_isOpenControlled) {
      setState(() => _uncontrolledOpen = value);
    }
    widget.onOpenChange?.call(value);
    _statesController.update(MonoState.open, value);
    if (_isOpenControlled) {
      return;
    }
    if (!value) {
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
  /// when the render box is not laid out.
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
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    assert(
      overlay != null,
      'MonoOverlay: no Overlay ancestor found. Wrap the app in MonokitApp or a Navigator/Overlay.',
    );
    if (overlay == null) {
      return;
    }
    final theme = MonokitTheme.of(context);
    _entry = OverlayEntry(
      builder: (overlayContext) => MonokitTheme(
        data: theme,
        child: MonoOverlayFade(
          visible: _overlayVisible,
          onExited: _onOverlayExited,
          child: _MonoComboboxOverlay<T>(
            anchorRect: _resolveAnchorRect(),
            options: _options,
            selectedValue: _selectedValue,
            searchPlaceholder: widget.searchPlaceholder,
            maxHeight: widget.menuMaxHeight,
            optionBuilder: widget.optionBuilder,
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
    final option = _options.cast<MonoComboboxOption<T>?>().firstWhere(
      (option) => option!.value == value,
      orElse: () => null,
    );
    if (option == null || !option.enabled) {
      return;
    }
    if (!_isValueControlled) {
      setState(() => _uncontrolledValue = value);
    }
    widget.onChanged?.call(value);
    _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final selected = _selectedOption();
    final foreground = _isEnabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final display = selected == null
        ? Text(
            widget.placeholder,
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
      onShowHoverHighlight: (value) =>
          _statesController.update(MonoState.hovered, value),
      onShowFocusHighlight: (value) =>
          _statesController.update(MonoState.focusVisible, value),
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown):
            _MonoComboboxOpenIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _setOpen(!_isOpen);
            return null;
          },
        ),
        _MonoComboboxOpenIntent: CallbackAction<_MonoComboboxOpenIntent>(
          onInvoke: (intent) {
            _setOpen(true);
            return null;
          },
        ),
      },
      // Only this state-consuming leaf rebuilds on hover/press/focus ticks; the
      // FocusableActionDetector above is untouched. The Semantics node lives
      // inside because it carries the interaction-driven `focused` flag.
      child: ListenableBuilder(
        listenable: _statesController,
        builder: (BuildContext context, Widget? _) {
          final focused = _statesController.contains(MonoState.focused);
          final hovered = _statesController.contains(MonoState.hovered);
          final skin = MonoFieldSkin.of(context, widget.size);
          return Semantics(
            container: true,
            button: true,
            enabled: _isEnabled,
            expanded: _isOpen,
            focused: focused,
            label: widget.semanticLabel ?? widget.placeholder,
            value: selected?.semanticLabel ?? selected?.searchText,
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
              child: MonoFocusRingOverlay(
                focused:
                    _statesController.contains(MonoState.focusVisible) ||
                    _isOpen,
                borderRadius: skin.radius,
                child: AnimatedContainer(
                  duration: MonokitMotion.noAnimation(context)
                      ? Duration.zero
                      : theme.motion.duration,
                  curve: theme.motion.curve,
                  constraints: BoxConstraints(minHeight: skin.height),
                  padding: EdgeInsets.symmetric(horizontal: skin.padX),
                  decoration: skin.well(
                    context,
                    enabled: _isEnabled,
                    hovered: hovered && !focused && !_isOpen,
                    invalid: widget.invalid,
                  ),
                  child: DefaultTextStyle.merge(
                    style: skin.value.copyWith(color: foreground),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: display),
                        SizedBox(width: theme.spacing.sm),
                        // An icon, not a Unicode character: U+2303/U+2304 are
                        // not in the bundled Plex and rendered as tofu.
                        AnimatedRotation(
                          turns: _isOpen ? 0.5 : 0,
                          duration: theme.motion.reduced(
                            context,
                            theme.motion.state,
                          ),
                          curve: theme.motion.standard,
                          child: MonoIcon(
                            MonoIcons.chevronDown,
                            color: theme.colors.mutedForeground,
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
            ),
          );
        },
      ),
    );
  }
}

class _MonoComboboxOpenIntent extends Intent {
  const _MonoComboboxOpenIntent();
}

class _MonoComboboxOverlay<T> extends StatefulWidget {
  const _MonoComboboxOverlay({
    required this.anchorRect,
    required this.options,
    required this.selectedValue,
    required this.searchPlaceholder,
    required this.maxHeight,
    required this.optionBuilder,
    required this.onDismiss,
    required this.onSelected,
  });

  final Rect anchorRect;
  final List<MonoComboboxOption<T>> options;
  final T? selectedValue;
  final String searchPlaceholder;
  final double maxHeight;
  final Widget Function(
    BuildContext context,
    MonoComboboxOption<T> option,
    bool selected,
    bool highlighted,
  )?
  optionBuilder;
  final VoidCallback onDismiss;
  final ValueChanged<T> onSelected;

  @override
  State<_MonoComboboxOverlay<T>> createState() =>
      _MonoComboboxOverlayState<T>();
}

class _MonoComboboxOverlayState<T> extends State<_MonoComboboxOverlay<T>> {
  late final TextEditingController _queryController;
  late final FocusNode _queryFocusNode;
  late int _highlightedIndex;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController()..addListener(_onQueryChanged);
    _queryFocusNode = FocusNode(debugLabel: 'MonoComboboxQuery');
    _highlightedIndex = _firstEnabled(_filteredOptions);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _queryFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  List<MonoComboboxOption<T>> get _filteredOptions {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.options;
    }
    return widget.options
        .where((option) => option._filterText.contains(query))
        .toList();
  }

  void _onQueryChanged() {
    setState(() => _highlightedIndex = _firstEnabled(_filteredOptions));
  }

  int _firstEnabled(List<MonoComboboxOption<T>> options) {
    return options.indexWhere((option) => option.enabled);
  }

  int _lastEnabled(List<MonoComboboxOption<T>> options) {
    for (var i = options.length - 1; i >= 0; i--) {
      if (options[i].enabled) return i;
    }
    return -1;
  }

  /// Moves the highlight up to [delta] enabled rows in the sign's direction,
  /// clamping at the first/last enabled option (Page Up / Page Down).
  int _pageMove(List<MonoComboboxOption<T>> options, int delta) {
    if (options.isEmpty) return -1;
    var index = _highlightedIndex < 0 ? 0 : _highlightedIndex;
    final step = delta > 0 ? 1 : -1;
    for (var moved = 0; moved < delta.abs(); moved++) {
      var next = index;
      for (var s = 1; s <= options.length; s++) {
        final candidate = index + step * s;
        if (candidate < 0 || candidate >= options.length) break;
        if (options[candidate].enabled) {
          next = candidate;
          break;
        }
      }
      if (next == index) break;
      index = next;
    }
    return index;
  }

  int _nextEnabled(List<MonoComboboxOption<T>> options, int direction) {
    if (options.isEmpty) {
      return -1;
    }
    var current = _highlightedIndex;
    if (current < 0) {
      current = direction > 0 ? -1 : 0;
    }
    for (var step = 1; step <= options.length; step++) {
      final raw = (current + direction * step) % options.length;
      final index = raw < 0 ? raw + options.length : raw;
      if (options[index].enabled) {
        return index;
      }
    }
    return _highlightedIndex;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final options = _filteredOptions;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlightedIndex = _nextEnabled(options, 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _highlightedIndex = _nextEnabled(options, -1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      setState(() => _highlightedIndex = _firstEnabled(options));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      setState(() => _highlightedIndex = _lastEnabled(options));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageDown) {
      setState(() => _highlightedIndex = _pageMove(options, 5));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.pageUp) {
      setState(() => _highlightedIndex = _pageMove(options, -5));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        _highlightedIndex >= 0 &&
        _highlightedIndex < options.length) {
      widget.onSelected(options[_highlightedIndex].value);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final options = _filteredOptions;
    // The whole panel joins the text field's tap region, so tapping an option,
    // the divider or the padding is not a tap *outside* the search field —
    // otherwise picking an option would drop the query field's focus (and the
    // keyboard) out from under the selection that is still in flight.
    final Widget body = TextFieldTapRegion(
      child: FocusScope(
        autofocus: true,
        child: Focus(
          onKeyEvent: _handleKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildSearch(theme),
              DecoratedBox(
                decoration: BoxDecoration(color: theme.colors.border),
                child: SizedBox(height: theme.spacing.xs / 4),
              ),
              // Flexible lets the list yield to the search field when the
              // whole popup is height-capped by the anchored layout, so the
              // search + divider + list total never exceeds available space.
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  child: options.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(theme.spacing.lg),
                          child: DefaultTextStyle.merge(
                            style: theme.typography.bodyMedium.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            child: const Text('No options found.'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(theme.spacing.xs),
                          itemCount: options.length,
                          itemBuilder: (context, index) => _buildOption(
                            theme,
                            options[index],
                            index == _highlightedIndex,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // "Shape follows density: touch summons the sheet picker; pointer floats
    // the menu." A menu anchored to a field is a cursor's answer — it appears
    // where the pointer already is. Under a thumb the same menu opens near the
    // top of the screen, behind the keyboard, at whatever width the field
    // happened to be. The sheet is the touch answer: full width, bottom edge,
    // in the thumb's reach.
    if (theme.density.isTouch) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Semantics(
            container: true,
            button: true,
            label: theme.labels.close,
            onTap: widget.onDismiss,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismiss,
              child: ColoredBox(color: theme.colors.overlayScrim),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MonokitContainers.sheet),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.popover,
                  // Radius at the top only: the sheet rises from the edge, and
                  // rounding the bottom would float it off a screen it is
                  // attached to.
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(theme.radii.xxl),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _handle(theme),
                      // A full-width sheet needs the inset an anchored panel
                      // never did: at 320 the list hugging both edges reads as
                      // unfinished rather than as edge-to-edge by intent.
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: theme.spacing.sm,
                          ),
                          child: body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onDismiss,
          child: const SizedBox.expand(),
        ),
        MonoAnchoredOverlay(
          anchorRect: widget.anchorRect,
          placement: MonoPlacement.bottomStart,
          gap: theme.spacing.xs,
          matchAnchorWidth: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.popover,
              borderRadius: BorderRadius.circular(theme.radii.lg),
              boxShadow: theme.elevation.resolve(MonoElevation.raised),
            ),
            child: body,
          ),
        ),
      ],
    );
  }

  /// The grab handle. Decorative — the sheet is dismissed by the scrim or by
  /// picking, and the handle is what says "this came from the edge".
  Widget _handle(MonokitThemeData theme) => Padding(
    padding: EdgeInsets.only(top: theme.spacing.sm, bottom: theme.spacing.xs),
    child: ExcludeSemantics(
      child: Container(
        width: theme.spacing.xxxl,
        height: theme.spacing.xs,
        decoration: BoxDecoration(
          color: theme.colors.border,
          borderRadius: theme.radii.borderRadiusFull,
        ),
      ),
    ),
  );

  Widget _buildSearch(MonokitThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.sm),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          if (_queryController.text.isEmpty)
            IgnorePointer(
              child: Text(
                widget.searchPlaceholder,
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          EditableText(
            controller: _queryController,
            focusNode: _queryFocusNode,
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.foreground,
            ),
            cursorColor: theme.colors.foreground,
            backgroundCursorColor: theme.colors.foreground,
            selectionColor: theme.colors.ring.withValues(alpha: 0.25),
            maxLines: 1,
            autofocus: true,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    MonokitThemeData theme,
    MonoComboboxOption<T> option,
    bool highlighted,
  ) {
    final selected = option.value == widget.selectedValue;
    final background = highlighted
        ? theme.colors.primary
        : theme.colors.popover;
    final foreground = highlighted
        ? theme.colors.primaryForeground
        : theme.colors.foreground;
    final custom = widget.optionBuilder?.call(
      context,
      option,
      selected,
      highlighted,
    );
    return Semantics(
      button: true,
      selected: selected,
      enabled: option.enabled,
      label: option.semanticLabel ?? option.searchText,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: option.enabled ? () => widget.onSelected(option.value) : null,
        child: AnimatedContainer(
          duration: MonokitMotion.noAnimation(context)
              ? Duration.zero
              : theme.motion.fast,
          curve: theme.motion.curve,
          // Menu rows are 44 at touch and 36 at pointer — a menu is scanned
          // rather than aimed at, so it tightens further than a control does.
          constraints: BoxConstraints(minHeight: theme.density.menuRow),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radii.md),
          ),
          child: Opacity(
            opacity: option.enabled ? 1 : 0.5,
            child:
                custom ??
                DefaultTextStyle.merge(
                  style: theme.typography.bodyMedium.copyWith(
                    color: foreground,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            option.label,
                            if (option.description != null) ...<Widget>[
                              SizedBox(height: theme.spacing.xs / 2),
                              DefaultTextStyle.merge(
                                style: theme.typography.labelMedium.copyWith(
                                  color: highlighted
                                      ? foreground.withValues(alpha: 0.75)
                                      : theme.colors.mutedForeground,
                                ),
                                child: option.description!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (selected) ...<Widget>[
                        SizedBox(width: theme.spacing.sm),
                        // Also an icon: U+2713 is not in the bundled Plex
                        // either, so "the pick carries the check" was carrying
                        // a tofu box.
                        MonoIcon(MonoIcons.check, color: foreground),
                      ],
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
