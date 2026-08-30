import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_placement.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Gives hover-card content a way to close the nearest [MonoHoverCard].
class MonoHoverCardScope extends InheritedWidget {
  const MonoHoverCardScope({
    super.key,
    required this.isOpen,
    required this.close,
    required super.child,
  });

  final bool isOpen;
  final VoidCallback close;

  static MonoHoverCardScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No MonoHoverCard found in context.');
    return scope!;
  }

  static MonoHoverCardScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoHoverCardScope>();
  }

  @override
  bool updateShouldNotify(MonoHoverCardScope oldWidget) {
    return isOpen != oldWidget.isOpen || close != oldWidget.close;
  }
}

/// A token-derived surface for rich [MonoHoverCard] content.
class MonoHoverCardContent extends StatelessWidget {
  const MonoHoverCardContent({
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
        color: theme.colors.popover,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        boxShadow: theme.elevation.resolve(MonoElevation.raised),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing.md),
        child: DefaultTextStyle.merge(
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.foreground,
          ),
          child: child,
        ),
      ),
    );
    if (constraints != null) {
      surface = ConstrainedBox(constraints: constraints!, child: surface);
    }
    return Semantics(
      container: true,
      label: semanticLabel ?? 'Hover card',
      child: FocusTraversalGroup(child: surface),
    );
  }
}

/// A rich, non-modal overlay revealed by hover, focus, or long press.
///
/// The card stays open while either its trigger or its content is hovered or
/// focused. [open] and [onOpenChange] provide controlled behavior; otherwise
/// hover, focus, and long press manage the default state automatically.
class MonoHoverCard extends StatefulWidget {
  const MonoHoverCard({
    super.key,
    required this.child,
    required this.card,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placement = MonoPlacement.bottom,
    this.offset = Offset.zero,
    this.gap,
    this.openDelay,
    this.closeDelay,
    this.dismissible = true,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final Widget card;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final MonoPlacement placement;
  final Offset offset;

  /// Space between trigger and card. Defaults to the small spacing token.
  final double? gap;

  /// Delay before hover opens the card. Defaults to the fast motion token.
  final Duration? openDelay;

  /// Delay before a pointer or focus exit closes the card. Defaults to the
  /// motion duration token, giving a pointer time to reach the card.
  final Duration? closeDelay;

  /// Enables Escape and outside-pointer dismissal.
  final bool dismissible;
  final bool enabled;
  final String? semanticLabel;

  static MonoHoverCardScope of(BuildContext context) =>
      MonoHoverCardScope.of(context);

  static MonoHoverCardScope? maybeOf(BuildContext context) =>
      MonoHoverCardScope.maybeOf(context);

  @override
  State<MonoHoverCard> createState() => _MonoHoverCardState();
}

class _MonoHoverCardState extends State<MonoHoverCard> {
  Rect _anchorRect = Rect.zero;
  final FocusNode _triggerFocusNode = FocusNode(debugLabel: 'MonoHoverCard');
  OverlayEntry? _entry;
  Timer? _openTimer;
  Timer? _closeTimer;
  late final MonoOverlayFocusController _overlayFocus =
      MonoOverlayFocusController(triggerFocusNode: () => _triggerFocusNode);
  late bool _uncontrolledOpen;
  bool _isTriggerHovered = false;
  bool _isCardHovered = false;
  bool _hasTriggerFocus = false;
  bool _hasCardFocus = false;
  bool _isLongPressing = false;
  MonokitThemeData? _overlayTheme;
  TextDirection _textDirection = TextDirection.ltr;
  bool _disableAnimations = false;
  bool _overlaySyncScheduled = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;
  bool get _shouldRemainOpen =>
      _isTriggerHovered ||
      _isCardHovered ||
      _hasTriggerFocus ||
      _hasCardFocus ||
      _isLongPressing;

  @override
  void initState() {
    super.initState();
    _uncontrolledOpen = widget.defaultOpen;
    _scheduleOverlaySync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleOverlaySync();
  }

  @override
  void didUpdateWidget(covariant MonoHoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != null && widget.open == null) {
      _uncontrolledOpen = oldWidget.open!;
    }
    if (!widget.enabled) {
      _cancelTimers();
      _uncontrolledOpen = false;
      _overlayFocus.cancelRestore();
      _scheduleOverlaySync();
      return;
    }
    _scheduleOverlaySync(
      restoreFocus: oldWidget.open != widget.open && !_isOpen,
    );
  }

  @override
  void dispose() {
    _cancelTimers();
    _overlayFocus.cancelRestore();
    _triggerFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Duration _openDelay(BuildContext context) =>
      widget.openDelay ?? MonokitTheme.of(context).motion.fast;

  Duration _closeDelay(BuildContext context) =>
      widget.closeDelay ?? MonokitTheme.of(context).motion.duration;

  void _cancelTimers() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _openTimer = null;
    _closeTimer = null;
  }

  void _scheduleOpen({required bool immediately}) {
    if (!widget.enabled) {
      return;
    }
    _closeTimer?.cancel();
    _closeTimer = null;
    if (_isOpen) {
      return;
    }
    _openTimer?.cancel();
    final delay = immediately ? Duration.zero : _openDelay(context);
    _openTimer = Timer(delay, () {
      _openTimer = null;
      if (mounted && widget.enabled && _shouldRemainOpen) {
        _requestOpen(true);
      }
    });
  }

  void _scheduleClose() {
    // The overlay notifies us it is no longer hovered from its own dispose(),
    // which can run while this state is being unmounted (e.g. the whole subtree
    // is torn down at once). Never read context after that.
    if (!mounted) {
      return;
    }
    if (_shouldRemainOpen) {
      return;
    }
    _openTimer?.cancel();
    _openTimer = null;
    if (!_isOpen) {
      return;
    }
    _closeTimer?.cancel();
    _closeTimer = Timer(_closeDelay(context), () {
      _closeTimer = null;
      if (mounted && !_shouldRemainOpen) {
        _requestOpen(false);
      }
    });
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

  /// Defers overlay mutations until the current widget update has completed.
  void _scheduleOverlaySync({bool restoreFocus = false}) {
    if (restoreFocus) {
      _overlayFocus.requestRestoreOnClose();
    }
    if (_overlaySyncScheduled) {
      return;
    }
    _overlaySyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      if (!mounted) {
        return;
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
    _textDirection = Directionality.of(context);
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
    _textDirection = Directionality.of(context);
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

  void _onCardHover(bool hovered) {
    _isCardHovered = hovered;
    if (hovered) {
      _closeTimer?.cancel();
      _closeTimer = null;
    } else {
      _scheduleClose();
    }
  }

  void _onCardFocus(bool focused) {
    _hasCardFocus = focused;
    if (focused) {
      _closeTimer?.cancel();
      _closeTimer = null;
    } else {
      _scheduleClose();
    }
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

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return _MonoHoverCardOverlay(
      theme: theme,
      visible: _overlayVisible,
      onExited: _onOverlayExited,
      anchorRect: _resolveAnchorRect(),
      placement: widget.placement,
      offset: widget.offset,
      gap: widget.gap ?? theme.spacing.sm,
      textDirection: _textDirection,
      dismissible: widget.dismissible,
      disableAnimations: _disableAnimations,
      semanticLabel: widget.semanticLabel,
      onDismiss: () => _requestOpen(false),
      onCardHover: _onCardHover,
      onCardFocus: _onCardFocus,
      child: widget.card,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MonoHoverCardScope(
      isOpen: _isOpen,
      close: () => _requestOpen(false),
      child: Focus(
        focusNode: _triggerFocusNode,
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (focused) {
          _hasTriggerFocus = focused;
          if (focused) {
            _scheduleOpen(immediately: true);
          } else {
            _scheduleClose();
          }
        },
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape &&
              _isOpen) {
            _cancelTimers();
            _requestOpen(false);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: MouseRegion(
          cursor: widget.enabled ? MouseCursor.defer : SystemMouseCursors.basic,
          onEnter: widget.enabled
              ? (_) {
                  _isTriggerHovered = true;
                  _scheduleOpen(immediately: false);
                }
              : null,
          onExit: widget.enabled
              ? (_) {
                  _isTriggerHovered = false;
                  _scheduleClose();
                }
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onLongPressStart: widget.enabled
                ? (_) {
                    _isLongPressing = true;
                    _scheduleOpen(immediately: true);
                  }
                : null,
            onLongPressEnd: widget.enabled
                ? (_) {
                    _isLongPressing = false;
                    _scheduleClose();
                  }
                : null,
            child: Semantics(
              container: true,
              label: widget.semanticLabel,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonoHoverCardOverlay extends StatefulWidget {
  const _MonoHoverCardOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.anchorRect,
    required this.placement,
    required this.offset,
    required this.gap,
    required this.textDirection,
    required this.dismissible,
    required this.disableAnimations,
    required this.onDismiss,
    required this.onCardHover,
    required this.onCardFocus,
    required this.child,
    this.semanticLabel,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final Rect anchorRect;
  final MonoPlacement placement;
  final Offset offset;
  final double gap;
  final TextDirection textDirection;
  final bool dismissible;
  final bool disableAnimations;
  final VoidCallback onDismiss;
  final ValueChanged<bool> onCardHover;
  final ValueChanged<bool> onCardFocus;
  final Widget child;
  final String? semanticLabel;

  @override
  State<_MonoHoverCardOverlay> createState() => _MonoHoverCardOverlayState();
}

class _MonoHoverCardOverlayState extends State<_MonoHoverCardOverlay>
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
          : widget.theme.motion.base,
    );
    _controller.addStatusListener(_onStatus);
    if (widget.visible) {
      _controller.forward();
    }
    _focusNode = FocusNode(debugLabel: 'MonoHoverCardContent');
  }

  @override
  void didUpdateWidget(covariant _MonoHoverCardOverlay oldWidget) {
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
    widget.onCardHover(false);
    widget.onCardFocus(false);
    _controller.removeStatusListener(_onStatus);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchors = _MonoHoverCardAnchors.resolve(
      widget.placement,
      widget.textDirection,
    );
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.theme.motion.curve,
    );
    final follower = MonoAnchoredOverlay(
      anchorRect: widget.anchorRect.shift(widget.offset),
      placement: widget.placement,
      gap: widget.gap,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: widget.onCardFocus,
        child: MouseRegion(
          onEnter: (_) => widget.onCardHover(true),
          onExit: (_) => widget.onCardHover(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                alignment: anchors.scaleAlignment,
                child: Semantics(
                  container: true,
                  label: widget.semanticLabel ?? 'Hover card',
                  child: MonoHoverCardScope(
                    isOpen: true,
                    close: widget.onDismiss,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return MonokitTheme(
      data: widget.theme,
      child: Focus(
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
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => widget.onDismiss(),
                ),
              ),
            follower,
          ],
        ),
      ),
    );
  }
}

@immutable
class _MonoHoverCardAnchors {
  const _MonoHoverCardAnchors({
    required this.targetAnchor,
    required this.followerAnchor,
    required this.direction,
  });

  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final AxisDirection direction;

  Alignment get scaleAlignment => switch (direction) {
    AxisDirection.up => Alignment.bottomCenter,
    AxisDirection.down => Alignment.topCenter,
    AxisDirection.left => Alignment.centerRight,
    AxisDirection.right => Alignment.centerLeft,
  };

  Offset offset(double gap) => switch (direction) {
    AxisDirection.up => Offset(0, -gap),
    AxisDirection.down => Offset(0, gap),
    AxisDirection.left => Offset(-gap, 0),
    AxisDirection.right => Offset(gap, 0),
  };

  static _MonoHoverCardAnchors resolve(
    MonoPlacement placement,
    TextDirection textDirection,
  ) {
    final isLtr = textDirection == TextDirection.ltr;
    final start = isLtr ? Alignment.topLeft : Alignment.topRight;
    final end = isLtr ? Alignment.topRight : Alignment.topLeft;
    final bottomStart = isLtr ? Alignment.bottomLeft : Alignment.bottomRight;
    final bottomEnd = isLtr ? Alignment.bottomRight : Alignment.bottomLeft;

    return switch (placement) {
      MonoPlacement.top => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topStart => _MonoHoverCardAnchors(
        targetAnchor: start,
        followerAnchor: bottomStart,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topEnd => _MonoHoverCardAnchors(
        targetAnchor: end,
        followerAnchor: bottomEnd,
        direction: AxisDirection.up,
      ),
      MonoPlacement.right => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightStart => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightEnd => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.bottomLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.bottom => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomStart => _MonoHoverCardAnchors(
        targetAnchor: bottomStart,
        followerAnchor: start,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomEnd => _MonoHoverCardAnchors(
        targetAnchor: bottomEnd,
        followerAnchor: end,
        direction: AxisDirection.down,
      ),
      MonoPlacement.left => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.centerLeft,
        followerAnchor: Alignment.centerRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftStart => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.topRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftEnd => const _MonoHoverCardAnchors(
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.bottomRight,
        direction: AxisDirection.left,
      ),
    };
  }
}
