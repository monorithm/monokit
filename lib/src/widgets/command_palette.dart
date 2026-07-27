import 'dart:ui' show ImageFilter;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_focus_trap.dart';
import '../primitives/mono_pressable.dart';
import '../primitives/mono_overlay_fade.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// A searchable action declaration for [MonoCommandPalette].
class MonoCommand {
  MonoCommand({
    required this.id,
    Widget? label,
    Widget? child,
    this.description,
    this.leading,
    this.trailing,
    this.keywords = const <String>[],
    this.searchText,
    this.enabled = true,
    this.semanticLabel,
    this.onSelected,
  }) : assert(label != null || child != null, 'Provide label or child.'),
       assert(
         label == null || child == null,
         'Specify label or child, not both.',
       ),
       child = child ?? label!;

  MonoCommand.text({
    required this.id,
    required String label,
    this.description,
    this.leading,
    this.trailing,
    this.keywords = const <String>[],
    this.enabled = true,
    this.semanticLabel,
    this.onSelected,
  }) : child = Text(label),
       searchText = label;

  final String id;
  final Widget child;
  final Widget? description;
  final Widget? leading;
  final Widget? trailing;
  final List<String> keywords;

  /// Text used when filtering a custom [child] presentation.
  final String? searchText;
  final bool enabled;
  final String? semanticLabel;
  final VoidCallback? onSelected;

  String get _filterText =>
      '$id ${searchText ?? ''} ${semanticLabel ?? ''} ${keywords.join(' ')}'
          .toLowerCase();
}

/// A modal, searchable command palette with controlled and uncontrolled modes.
class MonoCommandPalette extends StatefulWidget {
  const MonoCommandPalette({
    super.key,
    this.trigger,
    this.commands,
    this.items,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.onSelected,
    this.placeholder = 'Type a command or search…',
    this.empty,
    this.width = 560,
    this.maxHeight = 420,
    this.dismissible = true,
    this.semanticLabel,
  }) : assert(
         (commands?.length ?? 0) > 0 || (items?.length ?? 0) > 0,
         'MonoCommandPalette needs at least one command.',
       ),
       assert(
         commands == null || items == null,
         'Specify commands or items, not both.',
       ),
       assert(width > 0),
       assert(maxHeight > 0);

  final Widget? trigger;
  final List<MonoCommand>? commands;
  final List<MonoCommand>? items;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final ValueChanged<MonoCommand>? onSelected;
  final String placeholder;
  final Widget? empty;
  final double width;
  final double maxHeight;
  final bool dismissible;
  final String? semanticLabel;

  List<MonoCommand> get _commands => commands ?? items!;

  @override
  State<MonoCommandPalette> createState() => _MonoCommandPaletteState();
}

class _MonoCommandPaletteState extends State<MonoCommandPalette> {
  OverlayEntry? _entry;
  late bool _uncontrolledOpen;
  bool _overlaySyncScheduled = false;
  MonokitThemeData? _overlayTheme;
  TextDirection _textDirection = TextDirection.ltr;
  bool _disableAnimations = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    _assertUniqueIds();
    _uncontrolledOpen = widget.defaultOpen;
    if (_isOpen) {
      _scheduleOverlaySync();
    }
  }

  @override
  void didUpdateWidget(covariant MonoCommandPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertUniqueIds();
    _scheduleOverlaySync();
  }

  @override
  void dispose() {
    _removeOverlayNow();
    super.dispose();
  }

  void _assertUniqueIds() {
    assert(() {
      final ids = <String>{};
      for (final command in widget._commands) {
        if (!ids.add(command.id)) {
          throw FlutterError('Every MonoCommand needs a unique id.');
        }
      }
      return true;
    }());
  }

  void _setOpen(bool value) {
    if (value == _isOpen) {
      return;
    }
    if (!_isControlled) {
      setState(() => _uncontrolledOpen = value);
    }
    widget.onOpenChange?.call(value);
    if (_isControlled) {
      return;
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
    _overlayTheme = MonokitTheme.of(context);
    _textDirection = Directionality.of(context);
    _disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    _showOverlayNow();
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
    _entry = OverlayEntry(builder: (context) => _buildOverlay());
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
  }

  void _select(MonoCommand command) {
    if (!command.enabled) {
      return;
    }
    command.onSelected?.call();
    widget.onSelected?.call(command);
    _setOpen(false);
  }

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return MonokitTheme(
      data: theme,
      child: Directionality(
        textDirection: _textDirection,
        child: MonoOverlayFade(
          visible: _overlayVisible,
          onExited: _onOverlayExited,
          child: _MonoCommandPaletteOverlay(
            commands: widget._commands,
            theme: theme,
            placeholder: widget.placeholder,
            empty: widget.empty,
            width: widget.width,
            maxHeight: widget.maxHeight,
            dismissible: widget.dismissible,
            disableAnimations: _disableAnimations,
            semanticLabel: widget.semanticLabel,
            onDismiss: () => _setOpen(false),
            onSelected: _select,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trigger == null) {
      return const SizedBox.shrink();
    }
    return MonoPressable(
      onPressed: () => _setOpen(!_isOpen),
      semanticLabel: widget.semanticLabel,
      child: (context, states) => widget.trigger!,
    );
  }
}

class _MonoCommandPaletteOverlay extends StatefulWidget {
  const _MonoCommandPaletteOverlay({
    required this.commands,
    required this.theme,
    required this.placeholder,
    required this.empty,
    required this.width,
    required this.maxHeight,
    required this.dismissible,
    required this.disableAnimations,
    required this.semanticLabel,
    required this.onDismiss,
    required this.onSelected,
  });

  final List<MonoCommand> commands;
  final MonokitThemeData theme;
  final String placeholder;
  final Widget? empty;
  final double width;
  final double maxHeight;
  final bool dismissible;
  final bool disableAnimations;
  final String? semanticLabel;
  final VoidCallback onDismiss;
  final ValueChanged<MonoCommand> onSelected;

  @override
  State<_MonoCommandPaletteOverlay> createState() =>
      _MonoCommandPaletteOverlayState();
}

class _MonoCommandPaletteOverlayState
    extends State<_MonoCommandPaletteOverlay> {
  late final TextEditingController _queryController;
  late final FocusNode _queryFocusNode;
  late int _highlightedIndex;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController()
      ..addListener(_handleQueryChanged);
    _queryFocusNode = FocusNode(debugLabel: 'MonoCommandPaletteQuery');
    _highlightedIndex = _firstEnabledIndex(_filteredCommands);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _queryFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _queryController
      ..removeListener(_handleQueryChanged)
      ..dispose();
    _queryFocusNode.dispose();
    super.dispose();
  }

  List<MonoCommand> get _filteredCommands {
    final query = _queryController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.commands;
    }
    return widget.commands
        .where((command) => command._filterText.contains(query))
        .toList();
  }

  void _handleQueryChanged() {
    setState(() => _highlightedIndex = _firstEnabledIndex(_filteredCommands));
  }

  int _firstEnabledIndex(List<MonoCommand> commands) {
    return commands.indexWhere((command) => command.enabled);
  }

  int _nextEnabledIndex(List<MonoCommand> commands, int direction) {
    if (commands.isEmpty) {
      return -1;
    }
    var current = _highlightedIndex;
    if (current < 0) {
      current = direction > 0 ? -1 : 0;
    }
    for (var step = 1; step <= commands.length; step++) {
      final raw = (current + direction * step) % commands.length;
      final index = raw < 0 ? raw + commands.length : raw;
      if (commands[index].enabled) {
        return index;
      }
    }
    return _highlightedIndex;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final commands = _filteredCommands;
    if (event.logicalKey == LogicalKeyboardKey.escape && widget.dismissible) {
      widget.onDismiss();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlightedIndex = _nextEnabledIndex(commands, 1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() => _highlightedIndex = _nextEnabledIndex(commands, -1));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.home) {
      setState(() => _highlightedIndex = _firstEnabledIndex(commands));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.end) {
      for (var i = commands.length - 1; i >= 0; i--) {
        if (commands[i].enabled) {
          setState(() => _highlightedIndex = i);
          break;
        }
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        _highlightedIndex >= 0 &&
        _highlightedIndex < commands.length) {
      widget.onSelected(commands[_highlightedIndex]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final commands = _filteredCommands;
    final surface = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.width),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.popover,
          borderRadius: BorderRadius.circular(theme.radii.xl),
          border: Border.all(
            color: theme.colors.foreground.withValues(alpha: 0.1),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colors.foreground.withValues(alpha: 0.18),
              blurRadius: theme.spacing.xxxl,
              offset: Offset(0, theme.spacing.md),
            ),
          ],
        ),
        child: MonoFocusTrap(
          autofocus: true,
          child: Focus(
            onKeyEvent: _handleKey,
            child: Semantics(
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: true,
              label:
                  widget.semanticLabel ??
                  MonokitTheme.of(context).labels.commandPalette,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildQuery(theme),
                  DecoratedBox(
                    decoration: BoxDecoration(color: theme.colors.border),
                    child: SizedBox(height: theme.spacing.xs / 4),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: widget.maxHeight),
                    child: commands.isEmpty
                        ? Padding(
                            padding: EdgeInsets.all(theme.spacing.xxl),
                            child:
                                widget.empty ??
                                DefaultTextStyle.merge(
                                  style: theme.typography.bodyMedium.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                  child: const Text('No commands found.'),
                                ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(theme.spacing.xs),
                            itemCount: commands.length,
                            itemBuilder: (context, index) => _buildCommand(
                              theme,
                              commands[index],
                              index == _highlightedIndex,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (widget.dismissible)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: ColoredBox(color: theme.colors.overlayScrim),
            ),
          )
        else
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: ColoredBox(color: theme.colors.overlayScrim),
          ),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: widget.disableAnimations ? 1 : 0.96,
              end: 1,
            ),
            duration: widget.disableAnimations
                ? Duration.zero
                : theme.motion.duration,
            curve: theme.motion.curve,
            builder: (context, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: surface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuery(MonokitThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(theme.spacing.md),
      child: Row(
        children: <Widget>[
          Text(
            '⌕',
            style: theme.typography.titleMedium.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          SizedBox(width: theme.spacing.sm),
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: <Widget>[
                if (_queryController.text.isEmpty)
                  IgnorePointer(
                    child: Text(
                      widget.placeholder,
                      style: theme.typography.bodyMedium.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                EditableText(
                  controller: _queryController,
                  focusNode: _queryFocusNode,
                  style: theme.typography.bodyMedium.copyWith(
                    color: theme.colors.popoverForeground,
                  ),
                  cursorColor: theme.colors.foreground,
                  backgroundCursorColor: theme.colors.foreground,
                  selectionColor: theme.colors.ring.withValues(alpha: 0.25),
                  maxLines: 1,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommand(
    MonokitThemeData theme,
    MonoCommand command,
    bool highlighted,
  ) {
    // Reference command items highlight on neutral muted (not the brand
    // accent), keeping the foreground unchanged.
    final background = highlighted ? theme.colors.muted : theme.colors.popover;
    final foreground = theme.colors.popoverForeground;
    return Semantics(
      button: true,
      enabled: command.enabled,
      label: command.semanticLabel ?? command.searchText ?? command.id,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: command.enabled ? () => widget.onSelected(command) : null,
        child: AnimatedContainer(
          duration: widget.disableAnimations
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
          ),
          child: Opacity(
            opacity: command.enabled ? 1 : 0.5,
            child: DefaultTextStyle.merge(
              style: theme.typography.bodyMedium.copyWith(color: foreground),
              child: Row(
                children: <Widget>[
                  if (command.leading != null) ...<Widget>[
                    command.leading!,
                    SizedBox(width: theme.spacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        command.child,
                        if (command.description != null) ...<Widget>[
                          SizedBox(height: theme.spacing.xs / 2),
                          DefaultTextStyle.merge(
                            style: theme.typography.labelMedium.copyWith(
                              color: highlighted
                                  ? foreground.withValues(alpha: 0.75)
                                  : theme.colors.mutedForeground,
                            ),
                            child: command.description!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (command.trailing != null) ...<Widget>[
                    SizedBox(width: theme.spacing.sm),
                    command.trailing!,
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
