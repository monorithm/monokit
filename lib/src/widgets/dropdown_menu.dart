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

/// Placement for a [MonoDropdownMenu] relative to its trigger.
enum MonoDropdownMenuPlacement { bottomStart, bottomEnd, topStart, topEnd }

/// A selectable item inside [MonoDropdownMenu].
class MonoDropdownMenuItem<T> {
  MonoDropdownMenuItem({
    required this.value,
    Widget? label,
    Widget? child,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
    this.semanticLabel,
    this.onSelected,
  }) : assert(
         label != null || child != null,
         'Provide label or child for a menu item.',
       ),
       assert(
         label == null || child == null,
         'Specify label or child, not both.',
       ),
       child = child ?? label!;

  /// Convenience text-only item constructor.
  MonoDropdownMenuItem.text({
    required this.value,
    required String label,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
    this.semanticLabel,
    this.onSelected,
  }) : child = Text(label);

  final T value;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool destructive;
  final String? semanticLabel;
  final ValueChanged<T>? onSelected;
}

/// Alias for [MonoDropdownMenuItem].
typedef MonoDropdownItem<T> = MonoDropdownMenuItem<T>;

/// A composited, keyboard-accessible dropdown menu without Material widgets.
class MonoDropdownMenu<T> extends StatefulWidget {
  const MonoDropdownMenu({
    super.key,
    this.trigger,
    this.child,
    this.items,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.onSelected,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.statesController,
    this.placement = MonoDropdownMenuPlacement.bottomStart,
    this.width,
    this.maxHeight = 280,
  }) : assert(
         trigger != null || child != null,
         'MonoDropdownMenu needs a trigger or child.',
       ),
       assert(
         trigger == null || child == null,
         'Specify trigger or child, not both.',
       ),
       assert(
         items != null && items.length > 0,
         'MonoDropdownMenu needs at least one item.',
       ),
       assert(width == null || width > 0),
       assert(maxHeight > 0);

  /// The trigger widget. [child] is an alias.
  final Widget? trigger;
  final Widget? child;
  final List<MonoDropdownMenuItem<T>>? items;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final ValueChanged<T>? onSelected;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MonoStatesController? statesController;
  final MonoDropdownMenuPlacement placement;
  final double? width;
  final double maxHeight;

  Widget get _trigger => trigger ?? child!;
  List<MonoDropdownMenuItem<T>> get _items => items!;

  @override
  State<MonoDropdownMenu<T>> createState() => _MonoDropdownMenuState<T>();
}

class _MonoDropdownMenuState<T> extends State<MonoDropdownMenu<T>> {
  Rect _anchorRect = Rect.zero;
  OverlayEntry? _entry;
  bool _overlaySyncScheduled = false;
  late final MonoOverlayFocusController _overlayFocus;
  late bool _uncontrolledOpen;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => _isControlled ? widget.open! : _uncontrolledOpen;
  bool get _isEnabled => widget.enabled;
  bool get _isFocused => _statesController.contains(MonoState.focused);

  @override
  void initState() {
    super.initState();
    _assertUniqueValues(widget._items);
    _uncontrolledOpen = widget.defaultOpen;
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
    if (_isOpen) {
      _scheduleOverlaySync();
    }
  }

  @override
  void didUpdateWidget(covariant MonoDropdownMenu<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertUniqueValues(widget._items);
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

  void _assertUniqueValues(List<MonoDropdownMenuItem<T>> items) {
    assert(() {
      final Set<T> values = <T>{};
      for (final MonoDropdownMenuItem<T> item in items) {
        if (!values.add(item.value)) {
          throw FlutterError(
            'Every MonoDropdownMenuItem value must be unique.',
          );
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
    _statesController.update(MonoState.open, _isOpen);
  }

  void _setOpen(bool open) {
    if (open == _isOpen || (open && !_isEnabled)) {
      return;
    }
    if (_isControlled) {
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

  MonoPlacement _monoPlacement(MonoDropdownMenuPlacement p) => switch (p) {
    MonoDropdownMenuPlacement.bottomStart => MonoPlacement.bottomStart,
    MonoDropdownMenuPlacement.bottomEnd => MonoPlacement.bottomEnd,
    MonoDropdownMenuPlacement.topStart => MonoPlacement.topStart,
    MonoDropdownMenuPlacement.topEnd => MonoPlacement.topEnd,
  };

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
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
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
          child: _MonoDropdownOverlay<T>(
            anchorRect: _resolveAnchorRect(),
            items: widget._items,
            placement: _monoPlacement(widget.placement),
            width: widget.width,
            maxHeight: widget.maxHeight,
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
    MonoDropdownMenuItem<T>? item;
    for (final MonoDropdownMenuItem<T> candidate in widget._items) {
      if (candidate.value == value) {
        item = candidate;
        break;
      }
    }
    if (item == null || !item.enabled) {
      return;
    }
    item.onSelected?.call(value);
    widget.onSelected?.call(value);
    _setOpen(false);
  }

  @override
  Widget build(BuildContext context) {
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
        SingleActivator(LogicalKeyboardKey.arrowDown):
            _MonoDropdownOpenIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            _setOpen(!_isOpen);
            return null;
          },
        ),
        _MonoDropdownOpenIntent: CallbackAction<_MonoDropdownOpenIntent>(
          onInvoke: (_MonoDropdownOpenIntent intent) {
            _setOpen(true);
            return null;
          },
        ),
      },
      onShowFocusHighlight: (bool visible) {
        _statesController
          ..update(MonoState.focused, visible)
          ..update(MonoState.focusVisible, visible);
      },
      onShowHoverHighlight: (bool hovered) =>
          _statesController.update(MonoState.hovered, hovered),
      child: Semantics(
        container: true,
        button: true,
        enabled: _isEnabled,
        expanded: _isOpen,
        focused: _isFocused,
        label: widget.semanticLabel ?? 'Menu',
        onTap: _isEnabled ? () => _setOpen(!_isOpen) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
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
          child: widget._trigger,
        ),
      ),
    );
  }
}

class _MonoDropdownOpenIntent extends Intent {
  const _MonoDropdownOpenIntent();
}

class _MonoDropdownOverlay<T> extends StatefulWidget {
  const _MonoDropdownOverlay({
    required this.anchorRect,
    required this.items,
    required this.placement,
    required this.width,
    required this.maxHeight,
    required this.onDismiss,
    required this.onSelected,
  });

  final Rect anchorRect;
  final List<MonoDropdownMenuItem<T>> items;
  final MonoPlacement placement;
  final double? width;
  final double maxHeight;
  final VoidCallback onDismiss;
  final ValueChanged<T> onSelected;

  @override
  State<_MonoDropdownOverlay<T>> createState() =>
      _MonoDropdownOverlayState<T>();
}

class _MonoDropdownOverlayState<T> extends State<_MonoDropdownOverlay<T>> {
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = <int, GlobalKey>{};
  late int _highlightedIndex;

  GlobalKey _keyFor(int index) => _itemKeys.putIfAbsent(index, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'MonoDropdownMenu');
    _scrollController = ScrollController();
    _highlightedIndex = _firstEnabledIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  /// Scrolls the highlighted item into view using its real laid-out position
  /// (replaces the previous fixed 44px row estimate).
  ///
  /// Rows outside the viewport are not built yet, so when the highlighted
  /// row's context is missing this first jumps proportionally into the list
  /// and retries once the row exists.
  void _revealHighlighted({bool retry = true}) {
    final BuildContext? itemContext =
        _itemKeys[_highlightedIndex]?.currentContext;
    if (itemContext != null) {
      final MonokitThemeData theme = MonokitTheme.of(context);
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.5,
        duration: theme.motion.fast,
        curve: theme.motion.curve,
      );
      return;
    }
    if (!retry || !_scrollController.hasClients || widget.items.length < 2) {
      return;
    }
    final double estimate =
        _scrollController.position.maxScrollExtent *
        (_highlightedIndex / (widget.items.length - 1));
    _scrollController.jumpTo(
      estimate.clamp(0, _scrollController.position.maxScrollExtent),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _revealHighlighted(retry: false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _firstEnabledIndex() =>
      widget.items.indexWhere((MonoDropdownMenuItem<T> item) => item.enabled);

  int _nextEnabledIndex(int from, int direction) {
    for (int step = 1; step <= widget.items.length; step++) {
      final int rawIndex = (from + direction * step) % widget.items.length;
      final int index = rawIndex < 0
          ? rawIndex + widget.items.length
          : rawIndex;
      if (widget.items[index].enabled) {
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
    if (_highlightedIndex >= 0 && _highlightedIndex < widget.items.length) {
      final MonoDropdownMenuItem<T> item = widget.items[_highlightedIndex];
      if (item.enabled) {
        widget.onSelected(item.value);
      }
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
        final int last = widget.items.lastIndexWhere(
          (MonoDropdownMenuItem<T> item) => item.enabled,
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
          placement: widget.placement,
          gap: theme.spacing.xs,
          matchAnchorWidth: widget.width == null,
          child: SizedBox(
            width: widget.width,
            child: Focus(
              focusNode: _focusNode,
              onKeyEvent: _handleKeyEvent,
              child: Semantics(
                container: true,
                label: theme.labels.menuItems,
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
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(theme.spacing.xs),
                      shrinkWrap: true,
                      itemCount: widget.items.length,
                      itemBuilder: (BuildContext context, int index) =>
                          KeyedSubtree(
                            key: _keyFor(index),
                            child: _MonoDropdownItemTile<T>(
                              item: widget.items[index],
                              highlighted: index == _highlightedIndex,
                              onHover: widget.items[index].enabled
                                  ? (bool hovering) {
                                      if (hovering &&
                                          _highlightedIndex != index) {
                                        setState(
                                          () => _highlightedIndex = index,
                                        );
                                      }
                                    }
                                  : null,
                              onTap: widget.items[index].enabled
                                  ? () => widget.onSelected(
                                      widget.items[index].value,
                                    )
                                  : null,
                            ),
                          ),
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

class _MonoDropdownItemTile<T> extends StatelessWidget {
  const _MonoDropdownItemTile({
    required this.item,
    required this.highlighted,
    this.onTap,
    this.onHover,
  });

  final MonoDropdownMenuItem<T> item;
  final bool highlighted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    final Color foreground = item.destructive
        ? theme.colors.destructive
        : item.enabled
        ? theme.colors.popoverForeground
        : theme.colors.mutedForeground;
    return Semantics(
      button: true,
      enabled: item.enabled,
      label: item.semanticLabel,
      onTap: onTap,
      child: MouseRegion(
        onEnter: onHover == null ? null : (_) => onHover!(true),
        onExit: onHover == null ? null : (_) => onHover!(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: theme.motion.fast,
            curve: theme.motion.curve,
            constraints: BoxConstraints(minHeight: theme.spacing.xxxl),
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.sm,
              vertical: theme.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: highlighted
                  ? theme.colors.accent
                  : theme.colors.popover.withAlpha(0),
              borderRadius: BorderRadius.circular(theme.radii.sm),
            ),
            child: Row(
              children: <Widget>[
                if (item.leading != null) ...<Widget>[
                  item.leading!,
                  SizedBox(width: theme.spacing.sm),
                ],
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: theme.typography.bodyMedium.copyWith(
                      color: foreground,
                    ),
                    child: item.child,
                  ),
                ),
                if (item.trailing != null) ...<Widget>[
                  SizedBox(width: theme.spacing.sm),
                  item.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
