import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_placement.dart';
import '../primitives/mono_pressable.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Exposes a [MonoPopover]'s current state and close actions to descendants.
class MonoPopoverScope extends InheritedWidget {
  const MonoPopoverScope({
    super.key,
    required this.isOpen,
    required this.open,
    required this.close,
    required this.toggle,
    required super.child,
  });

  final bool isOpen;
  final VoidCallback open;
  final VoidCallback close;
  final VoidCallback toggle;

  static MonoPopoverScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No MonoPopover found in context.');
    return scope!;
  }

  static MonoPopoverScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoPopoverScope>();
  }

  @override
  bool updateShouldNotify(MonoPopoverScope oldWidget) {
    return isOpen != oldWidget.isOpen ||
        open != oldWidget.open ||
        close != oldWidget.close ||
        toggle != oldWidget.toggle;
  }
}

/// An accessible trigger that toggles the nearest [MonoPopover].
///
/// Use this for keyboard activation when [MonoPopover.trigger] is not already
/// an interactive widget such as [MonoButton].
class MonoPopoverTrigger extends StatelessWidget {
  const MonoPopoverTrigger({
    super.key,
    required this.child,
    this.semanticLabel,
    this.enabled = true,
  });

  final Widget child;

  /// Accessible name for the trigger. Falls back to
  /// `MonokitTheme.of(context).labels.togglePopover` when null.
  final String? semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scope = MonoPopoverScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.togglePopover,
      enabled: enabled && scope != null,
      onPressed: scope?.toggle,
      child: (context, states) =>
          Semantics(expanded: scope?.isOpen ?? false, child: child),
    );
  }
}

/// An accessible close action for content inside a [MonoPopover].
class MonoPopoverClose extends StatelessWidget {
  const MonoPopoverClose({super.key, required this.child, this.semanticLabel});

  final Widget child;

  /// Accessible name for the close action. Falls back to
  /// `MonokitTheme.of(context).labels.closePopover` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = MonoPopoverScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.closePopover,
      enabled: scope != null,
      onPressed: scope?.close,
      child: (context, states) => child,
    );
  }
}

/// A token-derived floating surface for [MonoPopover] content.
class MonoPopoverContent extends StatelessWidget {
  const MonoPopoverContent({
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
      label: semanticLabel ?? 'Popover',
      child: surface,
    );
  }
}

/// A non-modal, anchored overlay with controlled and uncontrolled modes.
///
/// A plain [trigger] opens the popover on tap. Use [MonoPopoverTrigger] when
/// the trigger itself needs the library-provided keyboard interaction. Use
/// [open] with [onOpenChange] for controlled state, or [defaultOpen] for an
/// uncontrolled popover.
class MonoPopover extends StatefulWidget {
  const MonoPopover({
    super.key,
    this.trigger,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placement = MonoPlacement.bottomStart,
    this.offset = Offset.zero,
    this.gap,
    this.dismissible = true,
    this.requestFocus = true,
    this.semanticLabel,
  });

  final Widget? trigger;
  final Widget child;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final MonoPlacement placement;
  final Offset offset;

  /// Space between the trigger and the popover. Defaults to the small spacing
  /// token.
  final double? gap;

  /// Dismisses from Escape and an outside pointer press when true.
  final bool dismissible;

  /// Moves keyboard focus into the overlay when it opens.
  final bool requestFocus;
  final String? semanticLabel;

  static MonoPopoverScope of(BuildContext context) =>
      MonoPopoverScope.of(context);

  static MonoPopoverScope? maybeOf(BuildContext context) =>
      MonoPopoverScope.maybeOf(context);

  @override
  State<MonoPopover> createState() => _MonoPopoverState();
}

class _MonoPopoverState extends State<MonoPopover> {
  Rect _anchorRect = Rect.zero;
  OverlayEntry? _entry;
  final MonoOverlayFocusController _overlayFocus = MonoOverlayFocusController();
  late bool _uncontrolledOpen;
  MonokitThemeData? _overlayTheme;
  TextDirection _textDirection = TextDirection.ltr;
  bool _disableAnimations = false;
  bool _overlaySyncScheduled = false;
  bool _overlayVisible = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;

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
  void didUpdateWidget(covariant MonoPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != null && widget.open == null) {
      _uncontrolledOpen = oldWidget.open!;
    }

    _scheduleOverlaySync(
      restoreFocus: oldWidget.open != widget.open && !_isOpen,
    );
  }

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
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

  /// Defers overlay mutations until the current widget update has completed.
  ///
  /// An [OverlayEntry] belongs to a separate part of the element tree, so
  /// inserting, removing, or rebuilding it from a lifecycle callback can mark
  /// that tree dirty while this widget is building. Coalescing work here also
  /// makes a sequence of controlled updates resolve to its final value.
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
      if (_isOpen) {
        _showOverlay();
      } else {
        _beginClose();
      }
    });
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

  /// Plays the exit animation, then removes the entry from [_onOverlayExited].
  void _beginClose() {
    if (_entry == null) {
      return;
    }
    _overlayVisible = false;
    _refreshOverlay();
  }

  void _onOverlayExited() {
    if (_overlayVisible) {
      return; // Re-opened mid-exit.
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

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return _MonoPopoverOverlay(
      theme: theme,
      visible: _overlayVisible,
      onExited: _onOverlayExited,
      anchorRect: _resolveAnchorRect(),
      placement: widget.placement,
      offset: widget.offset,
      gap: widget.gap ?? theme.spacing.sm,
      textDirection: _textDirection,
      dismissible: widget.dismissible,
      requestFocus: widget.requestFocus,
      disableAnimations: _disableAnimations,
      semanticLabel: widget.semanticLabel,
      onOpen: () => _requestOpen(true),
      onDismiss: () => _requestOpen(false),
      onToggle: () => _requestOpen(!_isOpen),
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger = widget.trigger;
    final child = trigger == null
        ? const SizedBox.shrink()
        : trigger is MonoPopoverTrigger
        ? trigger
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _requestOpen(!_isOpen),
            child: trigger,
          );
    return MonoPopoverScope(
      isOpen: _isOpen,
      open: () => _requestOpen(true),
      close: () => _requestOpen(false),
      toggle: () => _requestOpen(!_isOpen),
      child: child,
    );
  }
}

class _MonoPopoverOverlay extends StatefulWidget {
  const _MonoPopoverOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.anchorRect,
    required this.placement,
    required this.offset,
    required this.gap,
    required this.textDirection,
    required this.dismissible,
    required this.requestFocus,
    required this.disableAnimations,
    required this.onOpen,
    required this.onDismiss,
    required this.onToggle,
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
  final bool requestFocus;
  final bool disableAnimations;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  final VoidCallback onToggle;
  final Widget child;
  final String? semanticLabel;

  @override
  State<_MonoPopoverOverlay> createState() => _MonoPopoverOverlayState();
}

class _MonoPopoverOverlayState extends State<_MonoPopoverOverlay>
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
    _focusNode = FocusNode(debugLabel: 'MonoPopover');
    if (widget.requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _MonoPopoverOverlay oldWidget) {
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
    final anchors = _MonoPopoverAnchors.resolve(
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
              label: widget.semanticLabel ?? 'Popover',
              child: MonoPopoverScope(
                isOpen: true,
                open: widget.onOpen,
                close: widget.onDismiss,
                toggle: widget.onToggle,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
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
                    label: widget.theme.labels.dismissPopover,
                    onTap: widget.onDismiss,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDismiss,
                    ),
                  ),
                ),
              follower,
            ],
          ),
        ),
      ),
    );
  }
}

@immutable
class _MonoPopoverAnchors {
  const _MonoPopoverAnchors({
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

  static _MonoPopoverAnchors resolve(
    MonoPlacement placement,
    TextDirection textDirection,
  ) {
    final isLtr = textDirection == TextDirection.ltr;
    final start = isLtr ? Alignment.topLeft : Alignment.topRight;
    final end = isLtr ? Alignment.topRight : Alignment.topLeft;
    final bottomStart = isLtr ? Alignment.bottomLeft : Alignment.bottomRight;
    final bottomEnd = isLtr ? Alignment.bottomRight : Alignment.bottomLeft;

    return switch (placement) {
      MonoPlacement.top => const _MonoPopoverAnchors(
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topStart => _MonoPopoverAnchors(
        targetAnchor: start,
        followerAnchor: bottomStart,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topEnd => _MonoPopoverAnchors(
        targetAnchor: end,
        followerAnchor: bottomEnd,
        direction: AxisDirection.up,
      ),
      MonoPlacement.right => const _MonoPopoverAnchors(
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightStart => const _MonoPopoverAnchors(
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightEnd => const _MonoPopoverAnchors(
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.bottomLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.bottom => const _MonoPopoverAnchors(
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomStart => _MonoPopoverAnchors(
        targetAnchor: bottomStart,
        followerAnchor: start,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomEnd => _MonoPopoverAnchors(
        targetAnchor: bottomEnd,
        followerAnchor: end,
        direction: AxisDirection.down,
      ),
      MonoPlacement.left => const _MonoPopoverAnchors(
        targetAnchor: Alignment.centerLeft,
        followerAnchor: Alignment.centerRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftStart => const _MonoPopoverAnchors(
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.topRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftEnd => const _MonoPopoverAnchors(
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.bottomRight,
        direction: AxisDirection.left,
      ),
    };
  }
}
