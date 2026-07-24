import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// The direction in which a [MonoTabs] control lays out its tab triggers.
enum MonoTabsOrientation { horizontal, vertical }

/// The visual treatment used by [MonoTabs].
///
/// [MonoTabsVariant.defaultStyle] is a compact segmented control. [line] uses
/// an underline (or a leading line in vertical layouts) to mark the active
/// tab.
enum MonoTabsVariant { defaultStyle, line }

/// A single tab declaration for [MonoTabs].
///
/// Values must be unique within a tabs control. [content] is kept mounted only
/// while this tab is selected, which prevents inactive controls from receiving
/// focus or semantics.
class MonoTab {
  MonoTab({
    required this.value,
    required this.label,
    Widget? content,
    this.child,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
  }) : assert(
         content != null || child != null,
         'Provide either content or child for a MonoTab.',
       ),
       content = content ?? child!;

  /// A convenience constructor for text-only tab labels.
  MonoTab.text({
    required this.value,
    required String label,
    Widget? content,
    this.child,
    this.icon,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
  }) : assert(
         content != null || child != null,
         'Provide either content or child for a MonoTab.',
       ),
       label = Text(label),
       content = content ?? child!;

  /// A stable identifier for this tab.
  final String value;

  /// The visible label rendered in the tab trigger.
  final Widget label;

  /// The panel rendered when this tab is selected.
  final Widget content;

  /// Alias for [content], useful in widget-tree style declarations.
  final Widget? child;

  /// An optional leading icon.
  final Widget? icon;

  /// Whether this tab can be selected or focused.
  final bool enabled;

  /// An optional, concise accessibility label for the tab and its panel.
  final String? semanticLabel;

  /// An optional pointer-device tooltip for the trigger.
  final String? tooltip;
}

/// Backwards-friendly name for a [MonoTab] declaration.
typedef MonoTabsItem = MonoTab;

/// A compact, accessible tab switcher with controlled and uncontrolled modes.
///
/// Use [value] with [onChanged] for a controlled tabs control, or
/// [defaultValue] for an uncontrolled one. Index-based counterparts are also
/// available when stable string values are inconvenient. If no initial value is
/// supplied, the first enabled tab is selected.
class MonoTabs extends StatefulWidget {
  const MonoTabs({
    super.key,
    this.tabs = const <MonoTab>[],
    this.children,
    this.value,
    this.defaultValue,
    this.onChanged,
    this.selectedIndex,
    this.initialIndex,
    this.onIndexChanged,
    this.orientation = MonoTabsOrientation.horizontal,
    this.variant = MonoTabsVariant.defaultStyle,
    this.padding,
    this.duration,
    this.curve,
    this.semanticLabel,
  }) : assert(
         tabs.length > 0 || children != null,
         'MonoTabs needs at least one MonoTab.',
       );

  /// Tab declarations. Prefer this over [children] in new code.
  final List<MonoTab> tabs;

  /// Alias for [tabs], provided for widget-tree consistency.
  final List<MonoTab>? children;

  /// The selected tab value in controlled mode.
  final String? value;

  /// The initially selected tab value in uncontrolled mode.
  final String? defaultValue;

  /// Called when a user selects a tab value.
  final ValueChanged<String>? onChanged;

  /// The selected tab index in controlled mode.
  ///
  /// [value] takes precedence when both are supplied.
  final int? selectedIndex;

  /// The initially selected tab index in uncontrolled mode.
  ///
  /// [defaultValue] takes precedence when both are supplied.
  final int? initialIndex;

  /// Called alongside [onChanged] when a user selects a tab.
  final ValueChanged<int>? onIndexChanged;

  final MonoTabsOrientation orientation;
  final MonoTabsVariant variant;

  /// Optional padding around the entire control and its selected panel.
  final EdgeInsetsGeometry? padding;

  /// Overrides the token motion duration.
  final Duration? duration;

  /// Overrides the token motion curve.
  final Curve? curve;

  /// An accessibility label for the group of tab triggers.
  final String? semanticLabel;

  List<MonoTab> get _tabs => tabs.isNotEmpty ? tabs : children!;

  @override
  State<MonoTabs> createState() => _MonoTabsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('value', value, defaultValue: null))
      ..add(IntProperty('selectedIndex', selectedIndex, defaultValue: null))
      ..add(EnumProperty<MonoTabsOrientation>('orientation', orientation))
      ..add(EnumProperty<MonoTabsVariant>('variant', variant))
      ..add(IntProperty('tabs', _tabs.length));
  }
}

class _MonoTabsState extends State<MonoTabs> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  final Map<String, MonoStatesController> _stateControllers =
      <String, MonoStatesController>{};
  String? _uncontrolledValue;

  List<MonoTab> get _tabs => widget._tabs;

  bool get _isControlled =>
      widget.value != null || widget.selectedIndex != null;

  String? get _controlledValue {
    if (widget.value != null) {
      return widget.value;
    }
    final index = widget.selectedIndex;
    if (index == null || index < 0 || index >= _tabs.length) {
      return null;
    }
    return _tabs[index].value;
  }

  String? get _selectedValue =>
      _isControlled ? _controlledValue : _uncontrolledValue;

  @override
  void initState() {
    super.initState();
    _assertDistinctValues(_tabs);
    _syncFocusNodes();
    _uncontrolledValue = _resolveInitialValue();
  }

  @override
  void didUpdateWidget(covariant MonoTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertDistinctValues(_tabs);
    _syncFocusNodes();

    if (!_isControlled && !_containsEnabledValue(_uncontrolledValue)) {
      _uncontrolledValue = _firstEnabledValue();
    }
  }

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    for (final controller in _stateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _assertDistinctValues(List<MonoTab> tabs) {
    assert(() {
      final values = <String>{};
      for (final tab in tabs) {
        if (!values.add(tab.value)) {
          throw FlutterError(
            'Every MonoTab in one MonoTabs control must have a unique value. '
            'Duplicate value: ${tab.value}',
          );
        }
      }
      return true;
    }());
  }

  void _syncFocusNodes() {
    final values = _tabs.map((tab) => tab.value).toSet();
    final removedValues = _focusNodes.keys
        .where((value) => !values.contains(value))
        .toList(growable: false);

    for (final value in removedValues) {
      _focusNodes.remove(value)?.dispose();
      _stateControllers.remove(value)?.dispose();
    }

    for (final tab in _tabs) {
      _focusNodes.putIfAbsent(
        tab.value,
        () => FocusNode(debugLabel: 'MonoTabs:${tab.value}'),
      );
      _stateControllers.putIfAbsent(tab.value, () {
        final controller = MonoStatesController();
        controller.addListener(_handleStateChange);
        return controller;
      });
    }
  }

  String? _resolveInitialValue() {
    if (_containsEnabledValue(widget.defaultValue)) {
      return widget.defaultValue;
    }

    final initialIndex = widget.initialIndex;
    if (initialIndex != null &&
        initialIndex >= 0 &&
        initialIndex < _tabs.length &&
        _tabs[initialIndex].enabled) {
      return _tabs[initialIndex].value;
    }

    return _firstEnabledValue();
  }

  String? _firstEnabledValue() {
    for (final tab in _tabs) {
      if (tab.enabled) {
        return tab.value;
      }
    }
    return null;
  }

  bool _containsEnabledValue(String? value) {
    if (value == null) {
      return false;
    }
    return _tabs.any((tab) => tab.value == value && tab.enabled);
  }

  int _selectedIndex() {
    final selectedValue = _selectedValue;
    final index = _tabs.indexWhere((tab) => tab.value == selectedValue);
    if (index >= 0 && _tabs[index].enabled) {
      return index;
    }
    return _tabs.indexWhere((tab) => tab.enabled);
  }

  void _selectIndex(int index, {bool requestFocus = false}) {
    if (index < 0 || index >= _tabs.length || !_tabs[index].enabled) {
      return;
    }

    final value = _tabs[index].value;
    final changed = value != _selectedValue;
    if (!_isControlled && changed) {
      setState(() => _uncontrolledValue = value);
    }
    if (changed) {
      widget.onChanged?.call(value);
      widget.onIndexChanged?.call(index);
    }
    if (requestFocus) {
      _focusNodes[value]?.requestFocus();
    }
  }

  void _updateState(String value, MonoState state, bool enabled) {
    _stateControllers[value]?.update(state, enabled);
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  int _nextEnabledIndex(int start, int direction) {
    if (_tabs.isEmpty) {
      return -1;
    }

    for (var step = 1; step <= _tabs.length; step++) {
      final index = (start + (direction * step)) % _tabs.length;
      final normalizedIndex = index < 0 ? index + _tabs.length : index;
      if (_tabs[normalizedIndex].enabled) {
        return normalizedIndex;
      }
    }
    return start;
  }

  int _edgeEnabledIndex({required bool last}) {
    final iterable = last ? _tabs.reversed : _tabs;
    final tab = iterable.cast<MonoTab?>().firstWhere(
      (candidate) => candidate!.enabled,
      orElse: () => null,
    );
    return tab == null ? -1 : _tabs.indexOf(tab);
  }

  KeyEventResult _handleKeyEvent(int currentIndex, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final isHorizontal = widget.orientation == MonoTabsOrientation.horizontal;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    int? targetIndex;

    if (key == LogicalKeyboardKey.home) {
      targetIndex = _edgeEnabledIndex(last: false);
    } else if (key == LogicalKeyboardKey.end) {
      targetIndex = _edgeEnabledIndex(last: true);
    } else if (isHorizontal && key == LogicalKeyboardKey.arrowRight) {
      targetIndex = _nextEnabledIndex(currentIndex, isLtr ? 1 : -1);
    } else if (isHorizontal && key == LogicalKeyboardKey.arrowLeft) {
      targetIndex = _nextEnabledIndex(currentIndex, isLtr ? -1 : 1);
    } else if (!isHorizontal && key == LogicalKeyboardKey.arrowDown) {
      targetIndex = _nextEnabledIndex(currentIndex, 1);
    } else if (!isHorizontal && key == LogicalKeyboardKey.arrowUp) {
      targetIndex = _nextEnabledIndex(currentIndex, -1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _selectIndex(currentIndex);
      return KeyEventResult.handled;
    }

    if (targetIndex != null && targetIndex >= 0) {
      _selectIndex(targetIndex, requestFocus: true);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Duration _duration(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return Duration.zero;
    }
    return widget.duration ?? MonokitTheme.of(context).motion.duration;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final selectedIndex = _selectedIndex();
    final selectedTab = selectedIndex >= 0 ? _tabs[selectedIndex] : null;
    final duration = _duration(context);
    final curve = widget.curve ?? theme.motion.curve;
    final tabsList = _buildTabList(
      context,
      selectedIndex: selectedIndex,
      duration: duration,
      curve: curve,
    );
    final panel = selectedTab == null
        ? const SizedBox.shrink()
        : Semantics(
            container: true,
            label: selectedTab.semanticLabel == null
                ? theme.labels.tabPanel(selectedIndex + 1)
                : '${selectedTab.semanticLabel} panel',
            child: KeyedSubtree(
              key: ValueKey<String>(selectedTab.value),
              child: selectedTab.content,
            ),
          );

    final body = widget.orientation == MonoTabsOrientation.horizontal
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              tabsList,
              SizedBox(height: theme.spacing.md),
              panel,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              tabsList,
              SizedBox(width: theme.spacing.md),
              Flexible(child: panel),
            ],
          );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Semantics(
        container: true,
        label: widget.semanticLabel ?? 'Tabs',
        child: body,
      ),
    );
  }

  Widget _buildTabList(
    BuildContext context, {
    required int selectedIndex,
    required Duration duration,
    required Curve curve,
  }) {
    final theme = MonokitTheme.of(context);
    final triggers = <Widget>[
      for (var index = 0; index < _tabs.length; index++)
        _buildTrigger(
          context,
          index: index,
          tab: _tabs[index],
          selected: index == selectedIndex,
          duration: duration,
          curve: curve,
        ),
    ];

    final triggerRow = widget.orientation == MonoTabsOrientation.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: triggers)
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: triggers,
          );

    final decorated = DecoratedBox(
      decoration: _listDecoration(theme),
      child: Padding(
        padding: widget.variant == MonoTabsVariant.defaultStyle
            ? EdgeInsets.all(theme.spacing.xs)
            : EdgeInsets.zero,
        child: triggerRow,
      ),
    );

    if (widget.orientation == MonoTabsOrientation.vertical) {
      // A [Row] measures its non-flex children with an unbounded horizontal
      // constraint. Resolve the trigger list to its intrinsic width first so
      // the vertical [Column]'s stretch alignment receives a finite width.
      // This also leaves the remaining row width available to the tab panel.
      return IntrinsicWidth(child: decorated);
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      primary: false,
      child: decorated,
    );
  }

  Decoration _listDecoration(MonokitThemeData theme) {
    if (widget.variant == MonoTabsVariant.line) {
      return const BoxDecoration();
    }
    return BoxDecoration(
      color: theme.colors.muted,
      borderRadius: BorderRadius.circular(theme.radii.md),
    );
  }

  Widget _buildTrigger(
    BuildContext context, {
    required int index,
    required MonoTab tab,
    required bool selected,
    required Duration duration,
    required Curve curve,
  }) {
    final theme = MonokitTheme.of(context);
    final states = _stateControllers[tab.value]?.states ?? const <MonoState>{};
    final focusNode = _focusNodes[tab.value]!;
    final style = _MonoTabsTriggerStyle.resolve(
      theme: theme,
      orientation: widget.orientation,
      textDirection: Directionality.of(context),
      variant: widget.variant,
      selected: selected,
      enabled: tab.enabled,
      states: states,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (tab.icon != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(color: style.foreground, size: 16),
            child: tab.icon!,
          ),
          SizedBox(width: theme.spacing.xs),
        ],
        DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(color: style.foreground),
          child: tab.label,
        ),
      ],
    );

    final trigger = Semantics(
      button: true,
      inMutuallyExclusiveGroup: true,
      enabled: tab.enabled,
      selected: selected,
      focusable: tab.enabled,
      focused: focusNode.hasFocus,
      label: tab.semanticLabel,
      tooltip: tab.tooltip,
      onTap: tab.enabled ? () => _selectIndex(index) : null,
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: Focus(
          focusNode: focusNode,
          canRequestFocus: tab.enabled,
          onFocusChange: (focused) {
            _updateState(tab.value, MonoState.focused, focused);
            _updateState(
              tab.value,
              MonoState.focusVisible,
              focused &&
                  FocusManager.instance.highlightMode ==
                      FocusHighlightMode.traditional,
            );
          },
          onKeyEvent: (_, event) => _handleKeyEvent(index, event),
          child: MouseRegion(
            cursor: tab.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            onEnter: (_) => _updateState(tab.value, MonoState.hovered, true),
            onExit: (_) {
              _updateState(tab.value, MonoState.hovered, false);
              _updateState(tab.value, MonoState.pressed, false);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: tab.enabled
                  ? (_) {
                      focusNode.requestFocus();
                      _updateState(tab.value, MonoState.pressed, true);
                    }
                  : null,
              onTapUp: tab.enabled
                  ? (_) => _updateState(tab.value, MonoState.pressed, false)
                  : null,
              onTapCancel: tab.enabled
                  ? () => _updateState(tab.value, MonoState.pressed, false)
                  : null,
              onTap: tab.enabled ? () => _selectIndex(index) : null,
              child: AnimatedContainer(
                duration: duration,
                curve: curve,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.sm,
                  vertical: theme.spacing.xs,
                ),
                decoration: style.decoration,
                child: Opacity(opacity: tab.enabled ? 1 : 0.5, child: content),
              ),
            ),
          ),
        ),
      ),
    );

    return trigger;
  }
}

class _MonoTabsTriggerStyle {
  const _MonoTabsTriggerStyle({
    required this.foreground,
    required this.decoration,
  });

  final Color foreground;
  final Decoration decoration;

  static _MonoTabsTriggerStyle resolve({
    required MonokitThemeData theme,
    required MonoTabsOrientation orientation,
    required TextDirection textDirection,
    required MonoTabsVariant variant,
    required bool selected,
    required bool enabled,
    required Set<MonoState> states,
  }) {
    final focused = states.contains(MonoState.focusVisible);
    final hovered = states.contains(MonoState.hovered);
    final pressed = states.contains(MonoState.pressed);
    final foreground = !enabled
        ? theme.colors.mutedForeground
        : selected
        ? theme.colors.foreground
        : theme.colors.mutedForeground;

    if (variant == MonoTabsVariant.line) {
      final indicatorColor = selected
          ? theme.colors.primary
          : const Color(0x00000000);
      final line = BorderSide(color: indicatorColor, width: 2);
      final decoration = BoxDecoration(
        color: pressed
            ? theme.colors.accent
            : hovered && !selected
            ? theme.colors.muted
            : const Color(0x00000000),
        border: orientation == MonoTabsOrientation.horizontal
            ? Border(bottom: line)
            : Border(
                left: textDirection == TextDirection.ltr
                    ? line
                    : BorderSide.none,
                right: textDirection == TextDirection.rtl
                    ? line
                    : BorderSide.none,
              ),
        borderRadius: BorderRadius.circular(theme.radii.sm),
        boxShadow: focused
            ? <BoxShadow>[
                BoxShadow(
                  color: theme.colors.ring.withValues(alpha: 0.7),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ]
            : null,
      );
      return _MonoTabsTriggerStyle(
        foreground: selected ? theme.colors.primary : foreground,
        decoration: decoration,
      );
    }

    return _MonoTabsTriggerStyle(
      foreground: foreground,
      decoration: BoxDecoration(
        color: selected
            ? theme.colors.background
            : pressed
            ? theme.colors.accent
            : hovered
            ? theme.colors.accent
            : const Color(0x00000000),
        border: focused ? Border.all(color: theme.colors.ring, width: 2) : null,
        borderRadius: BorderRadius.circular(theme.radii.sm),
      ),
    );
  }
}
