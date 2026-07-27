import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_placement.dart';
import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Access to the nearest [MonoContextMenu]'s close action.
class MonoContextMenuScope extends InheritedWidget {
  const MonoContextMenuScope({
    super.key,
    required this.isOpen,
    required this.close,
    required super.child,
  });

  final bool isOpen;
  final VoidCallback close;

  static MonoContextMenuScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No MonoContextMenu found in context.');
    return scope!;
  }

  static MonoContextMenuScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoContextMenuScope>();
  }

  @override
  bool updateShouldNotify(MonoContextMenuScope oldWidget) {
    return isOpen != oldWidget.isOpen || close != oldWidget.close;
  }
}

/// A styled surface for the content shown by [MonoContextMenu].
class MonoContextMenuContent extends StatelessWidget {
  const MonoContextMenuContent({
    super.key,
    required this.child,
    this.padding,
    this.constraints,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.elevated,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        boxShadow: theme.elevation.resolve(MonoElevation.raised),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing.xs),
        child: DefaultTextStyle.merge(
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.foreground,
          ),
          // Scrolls instead of overflowing when the anchored layout caps the
          // menu's height to the space available on screen.
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
    if (constraints != null) {
      surface = ConstrainedBox(constraints: constraints!, child: surface);
    }
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Context menu',
      child: FocusTraversalGroup(child: surface),
    );
  }
}

/// A keyboard-accessible selectable row for [MonoContextMenuContent].
class MonoContextMenuItem extends StatelessWidget {
  const MonoContextMenuItem({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
    this.closeOnSelect = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool destructive;
  final bool closeOnSelect;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final scope = MonoContextMenuScope.maybeOf(context);
    final isEnabled = enabled && onPressed != null;
    return MonoPressable(
      enabled: isEnabled,
      semanticLabel: semanticLabel,
      onPressed: () {
        if (!isEnabled) {
          return;
        }
        onPressed!.call();
        if (closeOnSelect) {
          scope?.close();
        }
      },
      child: (context, states) {
        final hovered = states.contains(MonoState.hovered);
        final pressed = states.contains(MonoState.pressed);
        final focused = states.contains(MonoState.focusVisible);
        final bool isHi = (pressed || hovered) && isEnabled;
        final foreground = !isEnabled
            ? theme.colors.foregroundMuted
            : destructive
            ? (isHi ? theme.colors.dangerText : theme.colors.danger)
            : isHi
            ? theme.colors.onPrimary
            : theme.colors.foreground;
        // On the accent-highlighted row, the trailing/shortcut glyph flips to
        // accentForeground too; otherwise it stays muted.
        final trailingColor = isHi && !destructive
            ? theme.colors.onPrimary
            : theme.colors.foregroundMuted;
        return AnimatedContainer(
          duration: theme.motion.fast,
          curve: theme.motion.curve,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.sm,
          ),
          decoration: BoxDecoration(
            color: !isHi
                ? const Color(0x00000000)
                : destructive
                ? theme.colors.dangerSoft
                : theme.colors.primary,
            borderRadius: BorderRadius.circular(theme.radii.md),
            boxShadow: focused
                ? <BoxShadow>[
                    BoxShadow(
                      color: theme.colors.ring.withValues(alpha: 0.7),
                      blurRadius: 0,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: isEnabled ? 1 : 0.5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  IconTheme.merge(
                    data: IconThemeData(
                      color: foreground,
                      size: theme.spacing.lg,
                    ),
                    child: leading!,
                  ),
                  SizedBox(width: theme.spacing.sm),
                ],
                DefaultTextStyle.merge(
                  style: theme.typography.bodyMedium.copyWith(
                    color: foreground,
                  ),
                  child: child,
                ),
                if (trailing != null) ...<Widget>[
                  SizedBox(width: theme.spacing.xl),
                  IconTheme.merge(
                    data: IconThemeData(
                      color: trailingColor,
                      size: theme.spacing.lg,
                    ),
                    child: trailing!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A token-aware separator for [MonoContextMenuContent].
class MonoContextMenuSeparator extends StatelessWidget {
  const MonoContextMenuSeparator({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: ColoredBox(
        color: theme.colors.separator,
        child: const SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

/// Opens an anchored context menu on secondary click, long press, or the
/// platform context-menu key.
class MonoContextMenu extends StatefulWidget {
  const MonoContextMenu({
    super.key,
    required this.child,
    required this.menu,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.offset = Offset.zero,
    this.dismissible = true,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The area that receives secondary-click and long-press interactions.
  final Widget child;

  /// The context menu, usually a [MonoContextMenuContent].
  final Widget menu;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final Offset offset;
  final bool dismissible;
  final bool enabled;
  final String? semanticLabel;

  static MonoContextMenuScope of(BuildContext context) =>
      MonoContextMenuScope.of(context);

  static MonoContextMenuScope? maybeOf(BuildContext context) =>
      MonoContextMenuScope.maybeOf(context);

  @override
  State<MonoContextMenu> createState() => _MonoContextMenuState();
}

class _MonoContextMenuState extends State<MonoContextMenu> {
  Rect _anchorRect = Rect.zero;
  final FocusNode _focusNode = FocusNode(debugLabel: 'MonoContextMenuTrigger');
  OverlayEntry? _entry;
  late final MonoOverlayFocusController _overlayFocus =
      MonoOverlayFocusController(triggerFocusNode: () => _focusNode);
  late bool _uncontrolledOpen;
  Offset _anchorOffset = Offset.zero;
  MonokitThemeData? _overlayTheme;
  bool _disableAnimations = false;
  bool _overlaySyncScheduled = false;
  bool _centerAnchorOnNextOverlaySync = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    _uncontrolledOpen = widget.defaultOpen;
    _scheduleOverlaySync(anchorAtCenter: _isOpen);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleOverlaySync();
  }

  @override
  void didUpdateWidget(covariant MonoContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != null && widget.open == null) {
      _uncontrolledOpen = oldWidget.open!;
    }
    if (!widget.enabled) {
      _uncontrolledOpen = false;
      _overlayFocus.cancelRestore();
      _scheduleOverlaySync();
      return;
    }
    _scheduleOverlaySync(
      anchorAtCenter: oldWidget.open != widget.open && _isOpen,
      restoreFocus: oldWidget.open != widget.open && !_isOpen,
    );
  }

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _requestOpen(bool value) {
    if (_isOpen == value) {
      return;
    }
    if (_isControlled) {
      widget.onOpenChange?.call(value);
      return;
    }
    setState(() => _uncontrolledOpen = value);
    widget.onOpenChange?.call(value);
    _scheduleOverlaySync(restoreFocus: !value);
  }

  void _openAt(Offset globalPosition) {
    if (!widget.enabled) {
      return;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _anchorOffset = renderObject.globalToLocal(globalPosition);
    }
    _requestOpen(true);
    _scheduleOverlaySync();
  }

  void _anchorAtCenter() {
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _anchorOffset = renderObject.size.center(Offset.zero);
    }
  }

  /// Converts the local anchor point (tap position or trigger center) into a
  /// zero-size global rect for the anchored layout, keeping the last known
  /// value when the render box is not laid out.
  Rect _resolveAnchorRect() {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize) {
      final Offset global = box.localToGlobal(_anchorOffset + widget.offset);
      _anchorRect = global & Size.zero;
    }
    return _anchorRect;
  }

  /// Defers overlay mutations until the current widget update has completed.
  void _scheduleOverlaySync({
    bool restoreFocus = false,
    bool anchorAtCenter = false,
  }) {
    if (restoreFocus) {
      _overlayFocus.requestRestoreOnClose();
    }
    _centerAnchorOnNextOverlaySync |= anchorAtCenter;
    if (_overlaySyncScheduled) {
      return;
    }
    _overlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      final shouldAnchorAtCenter = _centerAnchorOnNextOverlaySync;
      _centerAnchorOnNextOverlaySync = false;
      if (!mounted) {
        return;
      }
      if (shouldAnchorAtCenter && widget.enabled && _isOpen) {
        _anchorAtCenter();
      }
      if (widget.enabled && _isOpen) {
        _showOverlay();
      } else {
        _beginClose();
      }
    });
  }

  bool _overlayVisible = false;

  void _showOverlay() {
    _overlayVisible = true;
    if (_entry != null || !mounted) {
      _refreshOverlay();
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
    _overlayFocus.captureForOpen();
    _overlayTheme = MonokitTheme.of(context);
    _disableAnimations = MonokitMotion.noAnimation(context);
    _entry = OverlayEntry(
      maintainState: true,
      builder: (overlayContext) => _buildOverlay(),
    );
    overlay.insert(_entry!);
  }

  void _beginClose() {
    if (_entry == null) {
      return;
    }
    _overlayVisible = false;
    _refreshOverlay();
  }

  void _onOverlayExited() {
    if (_overlayVisible) {
      return;
    }
    _removeOverlay();
  }

  void _refreshOverlay() {
    if (_entry == null || !mounted) {
      return;
    }
    _overlayTheme = MonokitTheme.of(context);
    _disableAnimations = MonokitMotion.noAnimation(context);
    _entry!.markNeedsBuild();
  }

  void _removeOverlay() {
    final entry = _entry;
    _entry = null;
    entry?.remove();
    entry?.dispose();
    _overlayFocus.restoreIfRequested(mounted: mounted);
  }

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return _MonoContextMenuOverlay(
      theme: theme,
      visible: _overlayVisible,
      onExited: _onOverlayExited,
      anchorRect: _resolveAnchorRect(),
      dismissible: widget.dismissible,
      disableAnimations: _disableAnimations,
      semanticLabel: widget.semanticLabel,
      onDismiss: () => _requestOpen(false),
      child: widget.menu,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MonoContextMenuScope(
      isOpen: _isOpen,
      close: () => _requestOpen(false),
      child: Semantics(
        container: true,
        label: widget.semanticLabel,
        onLongPress: widget.enabled
            ? () {
                _anchorAtCenter();
                _requestOpen(true);
              }
            : null,
        child: Focus(
          focusNode: _focusNode,
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (_, event) {
            final isContextMenuKey =
                event.logicalKey == LogicalKeyboardKey.contextMenu ||
                (event.logicalKey == LogicalKeyboardKey.f10 &&
                    HardwareKeyboard.instance.isShiftPressed);
            if (event is KeyDownEvent && isContextMenuKey && widget.enabled) {
              _anchorAtCenter();
              _requestOpen(true);
              return KeyEventResult.handled;
            }
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape &&
                _isOpen) {
              _requestOpen(false);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onSecondaryTapDown: widget.enabled
                ? (details) => _openAt(details.globalPosition)
                : null,
            onLongPressStart: widget.enabled
                ? (details) => _openAt(details.globalPosition)
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _MonoContextMenuOverlay extends StatefulWidget {
  const _MonoContextMenuOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.anchorRect,
    required this.dismissible,
    required this.disableAnimations,
    required this.onDismiss,
    required this.child,
    this.semanticLabel,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final Rect anchorRect;
  final bool dismissible;
  final bool disableAnimations;
  final VoidCallback onDismiss;
  final Widget child;
  final String? semanticLabel;

  @override
  State<_MonoContextMenuOverlay> createState() =>
      _MonoContextMenuOverlayState();
}

class _MonoContextMenuOverlayState extends State<_MonoContextMenuOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.disableAnimations
          ? Duration.zero
          : widget.theme.motion.fast,
    );
    _controller.addStatusListener(_onStatus);
    if (widget.visible) {
      _controller.forward();
    }
    _focusNode = FocusNode(debugLabel: 'MonoContextMenu');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _MonoContextMenuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.visible) {
      widget.onExited();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.theme.motion.curve,
    );
    return MonokitTheme(
      data: widget.theme,
      child: FocusScope(
        autofocus: false,
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (_, event) {
            if (widget.dismissible &&
                event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onDismiss();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: <Widget>[
              if (widget.dismissible)
                Positioned.fill(
                  child: Semantics(
                    button: true,
                    label: widget.theme.labels.dismissContextMenu,
                    onTap: widget.onDismiss,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDismiss,
                    ),
                  ),
                ),
              MonoAnchoredOverlay(
                anchorRect: widget.anchorRect,
                placement: MonoPlacement.bottomStart,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.98,
                        end: 1,
                      ).animate(animation),
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        container: true,
                        label: widget.semanticLabel ?? 'Context menu',
                        child: MonoContextMenuScope(
                          isOpen: true,
                          close: widget.onDismiss,
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
