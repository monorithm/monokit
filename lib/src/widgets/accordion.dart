import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Whether an accordion permits one or several expanded items.
enum MonoAccordionType { single, multiple }

/// A trigger slot for [MonoAccordionItem].
///
/// The root accordion supplies interaction, semantics, and the default chevron.
/// Use this wrapper when an item needs a custom trailing affordance or a more
/// specific semantic label.
class MonoAccordionTrigger extends StatelessWidget {
  const MonoAccordionTrigger({
    super.key,
    required this.child,
    this.trailing,
    this.semanticLabel,
  });

  final Widget child;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => child;
}

/// A content slot for [MonoAccordionItem].
class MonoAccordionContent extends StatelessWidget {
  const MonoAccordionContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// A declaration for one item in [MonoAccordion].
///
/// [trigger] and [content] are the item's trigger and content slots. [title]
/// and [child] are aliases that make simple declarations read naturally.
class MonoAccordionItem {
  MonoAccordionItem({
    required this.value,
    Widget? trigger,
    this.title,
    Widget? content,
    this.child,
    this.trailing,
    this.enabled = true,
    this.initiallyExpanded = false,
    this.semanticLabel,
  }) : assert(
         trigger != null || title != null,
         'Provide either trigger or title for a MonoAccordionItem.',
       ),
       assert(
         content != null || child != null,
         'Provide either content or child for a MonoAccordionItem.',
       ),
       trigger = trigger ?? title!,
       content = content ?? child!;

  /// A convenience constructor for text-only triggers.
  MonoAccordionItem.text({
    required this.value,
    required String title,
    Widget? content,
    this.child,
    this.trailing,
    this.enabled = true,
    this.initiallyExpanded = false,
    this.semanticLabel,
  }) : assert(
         content != null || child != null,
         'Provide either content or child for a MonoAccordionItem.',
       ),
       trigger = Text(title),
       title = null,
       content = content ?? child!;

  /// A stable identifier for this item. Values must be unique per accordion.
  final String value;

  /// The widget displayed by the interactive header.
  final Widget trigger;

  /// Alias for [trigger].
  final Widget? title;

  /// The widget revealed when the item is expanded.
  final Widget content;

  /// Alias for [content].
  final Widget? child;

  /// Replaces the default animated chevron.
  final Widget? trailing;

  /// Whether the item can be expanded, collapsed, or focused.
  final bool enabled;

  /// Used only when the root is uncontrolled and has no default value.
  final bool initiallyExpanded;

  /// An optional concise label for assistive technologies.
  final String? semanticLabel;
}

/// An accessible accordion with single and multiple expansion modes.
///
/// In [MonoAccordionType.single] mode, use [value], [defaultValue], and
/// [onChanged]. In [MonoAccordionType.multiple] mode, use [values],
/// [defaultValues], and [onValuesChanged]. The complementary callbacks are
/// still notified where meaningful, which makes changing modes straightforward.
class MonoAccordion extends StatefulWidget {
  const MonoAccordion({
    super.key,
    this.items = const <MonoAccordionItem>[],
    this.children,
    this.type = MonoAccordionType.single,
    this.value,
    this.defaultValue,
    this.values,
    this.defaultValues,
    this.onChanged,
    this.onValuesChanged,
    this.collapsible = true,
    this.padding,
    this.duration,
    this.curve,
    this.semanticLabel,
  }) : assert(
         items.length > 0 || children != null,
         'MonoAccordion needs at least one MonoAccordionItem.',
       );

  /// Item declarations. Prefer this over [children] in new code.
  final List<MonoAccordionItem> items;

  /// Alias for [items], provided for slot-oriented widget trees.
  final List<MonoAccordionItem>? children;

  final MonoAccordionType type;

  /// The expanded value in controlled single-expansion mode.
  final String? value;

  /// The initially expanded value in uncontrolled single-expansion mode.
  final String? defaultValue;

  /// The expanded values in controlled multiple-expansion mode.
  final Set<String>? values;

  /// The initially expanded values in uncontrolled multiple-expansion mode.
  final Set<String>? defaultValues;

  /// Called after a user changes a single-expansion accordion.
  final ValueChanged<String?>? onChanged;

  /// Called after a user changes the expanded item set.
  final ValueChanged<Set<String>>? onValuesChanged;

  /// Whether the open item in single-expansion mode may be collapsed.
  final bool collapsible;

  /// Optional padding around the root surface.
  final EdgeInsetsGeometry? padding;

  /// Overrides the token motion duration.
  final Duration? duration;

  /// Overrides the token motion curve.
  final Curve? curve;

  /// An accessibility label for the entire accordion.
  final String? semanticLabel;

  List<MonoAccordionItem> get _items => items.isNotEmpty ? items : children!;

  @override
  State<MonoAccordion> createState() => _MonoAccordionState();
}

class _MonoAccordionState extends State<MonoAccordion> {
  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};
  final Map<String, MonoStatesController> _stateControllers =
      <String, MonoStatesController>{};
  late Set<String> _uncontrolledValues;

  List<MonoAccordionItem> get _items => widget._items;

  bool get _isControlled => widget.value != null || widget.values != null;

  Set<String> get _expandedValues {
    if (!_isControlled) {
      return _uncontrolledValues;
    }

    final supplied = widget.type == MonoAccordionType.single
        ? widget.value == null
              ? widget.values ?? const <String>{}
              : <String>{widget.value!}
        : widget.values ??
              (widget.value == null
                  ? const <String>{}
                  : <String>{widget.value!});
    return _normaliseValues(supplied);
  }

  @override
  void initState() {
    super.initState();
    _assertDistinctValues(_items);
    _syncFocusNodes();
    _uncontrolledValues = _resolveInitialValues();
  }

  @override
  void didUpdateWidget(covariant MonoAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertDistinctValues(_items);
    _syncFocusNodes();

    if (!_isControlled) {
      _uncontrolledValues = _normaliseValues(_uncontrolledValues);
      if (widget.type == MonoAccordionType.single &&
          _uncontrolledValues.length > 1) {
        _uncontrolledValues = <String>{_uncontrolledValues.first};
      }
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

  void _assertDistinctValues(List<MonoAccordionItem> items) {
    assert(() {
      final values = <String>{};
      for (final item in items) {
        if (!values.add(item.value)) {
          throw FlutterError(
            'Every MonoAccordionItem in one MonoAccordion must have a unique '
            'value. Duplicate value: ${item.value}',
          );
        }
      }
      return true;
    }());
  }

  void _syncFocusNodes() {
    final values = _items.map((item) => item.value).toSet();
    final removedValues = _focusNodes.keys
        .where((value) => !values.contains(value))
        .toList(growable: false);
    for (final value in removedValues) {
      _focusNodes.remove(value)?.dispose();
      _stateControllers.remove(value)?.dispose();
    }

    for (final item in _items) {
      _focusNodes.putIfAbsent(
        item.value,
        () => FocusNode(debugLabel: 'MonoAccordion:${item.value}'),
      );
      _stateControllers.putIfAbsent(item.value, () {
        final controller = MonoStatesController();
        controller.addListener(_handleStateChange);
        return controller;
      });
    }
  }

  Set<String> _resolveInitialValues() {
    final supplied = widget.type == MonoAccordionType.single
        ? widget.defaultValue == null
              ? widget.defaultValues ?? const <String>{}
              : <String>{widget.defaultValue!}
        : widget.defaultValues ??
              (widget.defaultValue == null
                  ? const <String>{}
                  : <String>{widget.defaultValue!});
    final normalised = _normaliseValues(supplied);
    if (normalised.isNotEmpty) {
      return normalised;
    }

    final initialValues = _items
        .where((item) => item.initiallyExpanded)
        .map((item) => item.value);
    return _normaliseValues(initialValues);
  }

  Set<String> _normaliseValues(Iterable<String> values) {
    final available = _items.map((item) => item.value).toSet();
    final normalised = values.where(available.contains).toSet();
    if (widget.type == MonoAccordionType.single && normalised.length > 1) {
      return <String>{normalised.first};
    }
    return normalised;
  }

  void _toggle(String value) {
    MonoAccordionItem? item;
    for (final candidate in _items) {
      if (candidate.value == value) {
        item = candidate;
        break;
      }
    }
    if (item == null || !item.enabled) {
      return;
    }

    final currentValues = _expandedValues;
    final isExpanded = currentValues.contains(value);
    if (isExpanded &&
        widget.type == MonoAccordionType.single &&
        !widget.collapsible) {
      return;
    }

    final nextValues = <String>{...currentValues};
    if (isExpanded) {
      nextValues.remove(value);
    } else if (widget.type == MonoAccordionType.single) {
      nextValues
        ..clear()
        ..add(value);
    } else {
      nextValues.add(value);
    }
    _emitValues(nextValues);
  }

  void _emitValues(Set<String> values) {
    final nextValues = _normaliseValues(values);
    if (!_isControlled) {
      setState(() => _uncontrolledValues = nextValues);
    }

    final immutableValues = Set<String>.unmodifiable(nextValues);
    widget.onValuesChanged?.call(immutableValues);
    if (widget.type == MonoAccordionType.single) {
      widget.onChanged?.call(
        immutableValues.isEmpty ? null : immutableValues.first,
      );
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
    if (_items.isEmpty) {
      return -1;
    }
    for (var step = 1; step <= _items.length; step++) {
      final index = (start + (direction * step)) % _items.length;
      final normalised = index < 0 ? index + _items.length : index;
      if (_items[normalised].enabled) {
        return normalised;
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

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    int? nextIndex;
    if (key == LogicalKeyboardKey.arrowDown) {
      nextIndex = _nextEnabledIndex(index, 1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      nextIndex = _nextEnabledIndex(index, -1);
    } else if (key == LogicalKeyboardKey.home) {
      nextIndex = _edgeEnabledIndex(last: false);
    } else if (key == LogicalKeyboardKey.end) {
      nextIndex = _edgeEnabledIndex(last: true);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      _toggle(_items[index].value);
      return KeyEventResult.handled;
    }

    if (nextIndex != null && nextIndex >= 0) {
      _focusNodes[_items[nextIndex].value]?.requestFocus();
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
    final duration = _duration(context);
    final curve = widget.curve ?? theme.motion.curve;
    final expandedValues = _expandedValues;
    final items = <Widget>[
      for (var index = 0; index < _items.length; index++) ...<Widget>[
        if (index > 0)
          ColoredBox(
            color: theme.colors.border,
            child: const SizedBox(height: 1),
          ),
        _buildItem(
          context,
          item: _items[index],
          index: index,
          expanded: expandedValues.contains(_items[index].value),
          duration: duration,
          curve: curve,
        ),
      ],
    ];

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Semantics(
        container: true,
        label: widget.semanticLabel ?? 'Accordion',
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.card,
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(theme.radii.md),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required MonoAccordionItem item,
    required int index,
    required bool expanded,
    required Duration duration,
    required Curve curve,
  }) {
    final theme = MonokitTheme.of(context);
    final itemStates = <MonoState>{
      ...?_stateControllers[item.value]?.states,
      if (expanded) MonoState.expanded,
      if (!item.enabled) MonoState.disabled,
    };
    final triggerSlot = item.trigger is MonoAccordionTrigger
        ? item.trigger as MonoAccordionTrigger
        : null;
    final contentSlot = item.content is MonoAccordionContent
        ? item.content as MonoAccordionContent
        : null;
    final triggerChild = triggerSlot?.child ?? item.trigger;
    final contentChild = contentSlot?.child ?? item.content;
    final semanticLabel = item.semanticLabel ?? triggerSlot?.semanticLabel;
    final trailing = item.trailing ?? triggerSlot?.trailing;
    final focusNode = _focusNodes[item.value]!;
    final style = _MonoAccordionTriggerStyle.resolve(
      theme: theme,
      expanded: expanded,
      enabled: item.enabled,
      states: itemStates,
    );

    final trigger = Semantics(
      button: true,
      enabled: item.enabled,
      expanded: expanded,
      focusable: item.enabled,
      focused: focusNode.hasFocus,
      label: semanticLabel,
      onTap: item.enabled ? () => _toggle(item.value) : null,
      child: FocusTraversalOrder(
        order: NumericFocusOrder(index.toDouble()),
        child: Focus(
          focusNode: focusNode,
          canRequestFocus: item.enabled,
          onFocusChange: (focused) {
            _updateState(item.value, MonoState.focused, focused);
            _updateState(
              item.value,
              MonoState.focusVisible,
              focused &&
                  FocusManager.instance.highlightMode ==
                      FocusHighlightMode.traditional,
            );
          },
          onKeyEvent: (_, event) => _handleKeyEvent(index, event),
          child: MouseRegion(
            cursor: item.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.forbidden,
            onEnter: (_) => _updateState(item.value, MonoState.hovered, true),
            onExit: (_) {
              _updateState(item.value, MonoState.hovered, false);
              _updateState(item.value, MonoState.pressed, false);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: item.enabled
                  ? (_) {
                      focusNode.requestFocus();
                      _updateState(item.value, MonoState.pressed, true);
                    }
                  : null,
              onTapUp: item.enabled
                  ? (_) => _updateState(item.value, MonoState.pressed, false)
                  : null,
              onTapCancel: item.enabled
                  ? () => _updateState(item.value, MonoState.pressed, false)
                  : null,
              onTap: item.enabled ? () => _toggle(item.value) : null,
              child: AnimatedContainer(
                duration: duration,
                curve: curve,
                color: style.background,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.md,
                  vertical: theme.spacing.sm,
                ),
                child: Opacity(
                  opacity: item.enabled ? 1 : 0.5,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: theme.typography.labelMedium.copyWith(
                            color: style.foreground,
                          ),
                          child: triggerChild,
                        ),
                      ),
                      SizedBox(width: theme.spacing.sm),
                      trailing ??
                          _MonoAccordionChevron(
                            expanded: expanded,
                            textStyle: theme.typography.labelLarge.copyWith(
                              color: style.foreground,
                            ),
                            duration: duration,
                            curve: curve,
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DecoratedBox(decoration: style.focusDecoration, child: trigger),
        ClipRect(
          child: AnimatedSize(
            duration: duration,
            curve: curve,
            alignment: Alignment.topCenter,
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: expanded ? 1 : 0,
              child: ExcludeSemantics(
                excluding: !expanded,
                child: IgnorePointer(
                  ignoring: !expanded,
                  child: AnimatedOpacity(
                    duration: duration,
                    curve: curve,
                    opacity: expanded ? 1 : 0,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        theme.spacing.md,
                        0,
                        theme.spacing.md,
                        theme.spacing.md,
                      ),
                      child: DefaultTextStyle.merge(
                        style: theme.typography.bodyMedium.copyWith(
                          color: theme.colors.foreground,
                        ),
                        child: contentChild,
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

class _MonoAccordionChevron extends StatelessWidget {
  const _MonoAccordionChevron({
    required this.expanded,
    required this.textStyle,
    required this.duration,
    required this.curve,
  });

  final bool expanded;
  final TextStyle textStyle;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: expanded ? 0.25 : 0,
      duration: duration,
      curve: curve,
      child: Text('›', textDirection: TextDirection.ltr, style: textStyle),
    );
  }
}

class _MonoAccordionTriggerStyle {
  const _MonoAccordionTriggerStyle({
    required this.foreground,
    required this.background,
    required this.focusDecoration,
  });

  final Color foreground;
  final Color background;
  final Decoration focusDecoration;

  static _MonoAccordionTriggerStyle resolve({
    required MonokitThemeData theme,
    required bool expanded,
    required bool enabled,
    required Set<MonoState> states,
  }) {
    final hovered = states.contains(MonoState.hovered);
    final pressed = states.contains(MonoState.pressed);
    final focused = states.contains(MonoState.focusVisible);
    final foreground = !enabled
        ? theme.colors.mutedForeground
        : theme.colors.foreground;
    final background = !enabled
        ? theme.colors.card
        : pressed
        ? theme.colors.accent
        : hovered || expanded
        ? theme.colors.muted
        : theme.colors.card;

    return _MonoAccordionTriggerStyle(
      foreground: foreground,
      background: background,
      focusDecoration: BoxDecoration(
        border: focused
            ? Border.all(color: theme.colors.ring, width: theme.focus.ringWidth)
            : null,
      ),
    );
  }
}
