import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';

/// The primary axis of a [MonoNavigationMenu].
enum MonoNavigationMenuOrientation { horizontal, vertical }

/// The visual treatment of a [MonoNavigationMenu].
enum MonoNavigationMenuVariant { pill, line }

/// One selectable destination in a [MonoNavigationMenu].
class MonoNavigationMenuItem {
  MonoNavigationMenuItem({
    required this.value,
    Widget? label,
    Widget? child,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.semanticLabel,
    this.onSelected,
  }) : assert(label != null || child != null, 'Provide label or child.'),
       assert(
         label == null || child == null,
         'Specify label or child, not both.',
       ),
       child = child ?? label!;

  MonoNavigationMenuItem.text({
    required this.value,
    required String label,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.semanticLabel,
    this.onSelected,
  }) : child = Text(label);

  final String value;
  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final String? semanticLabel;
  final VoidCallback? onSelected;
}

/// A compact roving-focus navigation menu with controlled and uncontrolled
/// selection modes.
class MonoNavigationMenu extends StatefulWidget {
  const MonoNavigationMenu({
    super.key,
    this.items = const <MonoNavigationMenuItem>[],
    this.children,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.orientation = MonoNavigationMenuOrientation.horizontal,
    this.variant = MonoNavigationMenuVariant.pill,
    this.padding,
    this.semanticLabel = 'Navigation menu',
  }) : assert(
         items.length > 0 || children != null,
         'MonoNavigationMenu needs at least one item.',
       );

  final List<MonoNavigationMenuItem> items;
  final List<MonoNavigationMenuItem>? children;
  final String? value;
  final String? defaultValue;
  final ValueChanged<String>? onChanged;
  final MonoNavigationMenuOrientation orientation;
  final MonoNavigationMenuVariant variant;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  List<MonoNavigationMenuItem> get _items =>
      items.isNotEmpty ? items : children!;

  @override
  State<MonoNavigationMenu> createState() => _MonoNavigationMenuState();
}

class _MonoNavigationMenuState extends State<MonoNavigationMenu> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  String? _uncontrolledValue;

  List<MonoNavigationMenuItem> get _items => widget._items;
  bool get _isControlled => widget.value != null;
  String? get _selectedValue => widget.value ?? _uncontrolledValue;

  @override
  void initState() {
    super.initState();
    _assertUniqueValues();
    _syncFocusNodes();
    _uncontrolledValue = _resolveInitialValue();
  }

  @override
  void didUpdateWidget(covariant MonoNavigationMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertUniqueValues();
    _syncFocusNodes();
    if (!_isControlled && !_containsEnabled(_uncontrolledValue)) {
      _uncontrolledValue = _firstEnabledValue();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _assertUniqueValues() {
    assert(() {
      final values = <String>{};
      for (final item in _items) {
        if (!values.add(item.value)) {
          throw FlutterError(
            'Every MonoNavigationMenu item needs a unique value.',
          );
        }
      }
      return true;
    }());
  }

  void _syncFocusNodes() {
    final values = _items.map((item) => item.value).toSet();
    final removed = _focusNodes.keys
        .where((value) => !values.contains(value))
        .toList(growable: false);
    for (final value in removed) {
      _focusNodes.remove(value)?.dispose();
    }
    for (final item in _items) {
      _focusNodes.putIfAbsent(
        item.value,
        () => FocusNode(debugLabel: 'MonoNavigationMenu:${item.value}'),
      );
    }
  }

  bool _containsEnabled(String? value) {
    return value != null &&
        _items.any((item) => item.value == value && item.enabled);
  }

  String? _firstEnabledValue() {
    for (final item in _items) {
      if (item.enabled) {
        return item.value;
      }
    }
    return null;
  }

  String? _resolveInitialValue() {
    if (_containsEnabled(widget.defaultValue)) {
      return widget.defaultValue;
    }
    return _firstEnabledValue();
  }

  int _selectedIndex() {
    final index = _items.indexWhere((item) => item.value == _selectedValue);
    return index >= 0 && _items[index].enabled
        ? index
        : _items.indexWhere((item) => item.enabled);
  }

  void _selectIndex(int index, {bool requestFocus = false}) {
    if (index < 0 || index >= _items.length || !_items[index].enabled) {
      return;
    }
    final item = _items[index];
    final changed = item.value != _selectedValue;
    if (!_isControlled && changed) {
      setState(() => _uncontrolledValue = item.value);
    }
    if (changed) {
      widget.onChanged?.call(item.value);
    }
    item.onSelected?.call();
    if (requestFocus) {
      _focusNodes[item.value]?.requestFocus();
    }
  }

  int _nextEnabledIndex(int start, int direction) {
    if (_items.isEmpty) {
      return -1;
    }
    for (var step = 1; step <= _items.length; step++) {
      final raw = (start + direction * step) % _items.length;
      final index = raw < 0 ? raw + _items.length : raw;
      if (_items[index].enabled) {
        return index;
      }
    }
    return start;
  }

  int _edgeEnabledIndex({required bool last}) {
    final iterable = last ? _items.reversed : _items;
    for (final item in iterable) {
      if (item.enabled) {
        return _items.indexOf(item);
      }
    }
    return -1;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final current = _focusNodes.entries
        .where((entry) => entry.value.hasFocus)
        .map((entry) => _items.indexWhere((item) => item.value == entry.key))
        .firstOrNull;
    final currentIndex = current ?? _selectedIndex();
    if (currentIndex < 0) {
      return KeyEventResult.ignored;
    }
    final isHorizontal =
        widget.orientation == MonoNavigationMenuOrientation.horizontal;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final key = event.logicalKey;
    int? target;
    if (key == LogicalKeyboardKey.home) {
      target = _edgeEnabledIndex(last: false);
    } else if (key == LogicalKeyboardKey.end) {
      target = _edgeEnabledIndex(last: true);
    } else if (isHorizontal && key == LogicalKeyboardKey.arrowRight) {
      target = _nextEnabledIndex(currentIndex, isLtr ? 1 : -1);
    } else if (isHorizontal && key == LogicalKeyboardKey.arrowLeft) {
      target = _nextEnabledIndex(currentIndex, isLtr ? -1 : 1);
    } else if (!isHorizontal && key == LogicalKeyboardKey.arrowDown) {
      target = _nextEnabledIndex(currentIndex, 1);
    } else if (!isHorizontal && key == LogicalKeyboardKey.arrowUp) {
      target = _nextEnabledIndex(currentIndex, -1);
    }
    if (target != null && target >= 0) {
      _selectIndex(target, requestFocus: true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final selectedIndex = _selectedIndex();
    final items = <Widget>[
      for (var index = 0; index < _items.length; index++)
        _buildItem(context, _items[index], index == selectedIndex),
    ];
    final menu = widget.orientation == MonoNavigationMenuOrientation.horizontal
        ? Wrap(
            spacing: theme.spacing.xs,
            runSpacing: theme.spacing.xs,
            children: items,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: items,
          );
    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        child: Padding(padding: widget.padding ?? EdgeInsets.zero, child: menu),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    MonoNavigationMenuItem item,
    bool selected,
  ) {
    final theme = MonokitTheme.of(context);
    return MonoPressable(
      focusNode: _focusNodes[item.value],
      enabled: item.enabled,
      onPressed: () => _selectIndex(_items.indexOf(item)),
      semanticLabel: item.semanticLabel ?? item.value,
      child: (context, states) {
        final highlighted =
            states.contains(MonoState.hovered) ||
            states.contains(MonoState.focused);
        final pressed = states.contains(MonoState.pressed);
        final active = selected || pressed;
        final background =
            widget.variant == MonoNavigationMenuVariant.pill && active
            ? theme.colors.primary
            : highlighted
            ? theme.colors.accent
            : theme.colors.background.withValues(alpha: 0);
        final foreground =
            widget.variant == MonoNavigationMenuVariant.pill && active
            ? theme.colors.primaryForeground
            : highlighted
            ? theme.colors.accentForeground
            : theme.colors.foreground;
        final border =
            widget.variant == MonoNavigationMenuVariant.line && selected
            ? BorderDirectional(
                bottom: BorderSide(
                  color: theme.colors.primary,
                  width: theme.spacing.xs / 2,
                ),
              )
            : null;
        return AnimatedContainer(
          duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
              ? Duration.zero
              : theme.motion.fast,
          curve: theme.motion.curve,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radii.md),
            border: border,
            boxShadow: states.contains(MonoState.focusVisible)
                ? <BoxShadow>[
                    BoxShadow(
                      color: theme.colors.ring.withValues(alpha: 0.35),
                      spreadRadius: theme.components.button.focusRingWidth,
                    ),
                  ]
                : null,
          ),
          child: DefaultTextStyle.merge(
            style: theme.typography.labelLarge.copyWith(color: foreground),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (item.leading != null) ...<Widget>[
                  item.leading!,
                  SizedBox(width: theme.spacing.sm),
                ],
                item.child,
                if (item.trailing != null) ...<Widget>[
                  SizedBox(width: theme.spacing.sm),
                  item.trailing!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

extension on Iterable<int> {
  int? get firstOrNull {
    for (final value in this) {
      return value;
    }
    return null;
  }
}
