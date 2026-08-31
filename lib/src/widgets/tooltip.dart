import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_anchored_layout.dart';
import '../primitives/mono_placement.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// The token-derived visual surface used by [MonoTooltip].
class MonoTooltipContent extends StatelessWidget {
  const MonoTooltipContent({
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
        // Inverted-neutral surface (foreground bubble / background text) to
        // match the reference tooltip, rather than the brand color.
        color: theme.colors.foreground,
        borderRadius: BorderRadius.circular(theme.radii.md),
        boxShadow: theme.elevation.resolve(MonoElevation.raised),
      ),
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: theme.spacing.md,
              vertical: theme.spacing.xs,
            ),
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.background,
          ),
          child: child,
        ),
      ),
    );
    if (constraints != null) {
      surface = ConstrainedBox(constraints: constraints!, child: surface);
    }
    return Semantics(container: true, label: semanticLabel, child: surface);
  }
}

/// An anchored, non-modal hint shown on hover, focus, or long press.
///
/// Tooltips are announced through the child's semantic tooltip property even
/// while their visual overlay is hidden. Use [open] with [onOpenChange] to
/// control visibility explicitly, or leave it unset for the default automatic
/// hover, focus, and long-press behavior.
///
/// **The visual tooltip is pointer-density only.** A tooltip exists to answer
/// a hovering cursor, and there is no cursor on a touch screen; touch reveals
/// the same label through the platform's own long-press instead. At touch
/// density this renders its child and the semantic tooltip and nothing else,
/// so the label still reaches assistive technology at both densities.
/// An explicitly [open] tooltip is honoured everywhere — that is a caller
/// driving it, not an affordance the density decides.
class MonoTooltip extends StatefulWidget {
  const MonoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.content,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.placement = MonoPlacement.top,
    this.offset = Offset.zero,
    this.gap,
    this.waitDuration,
    this.exitDuration,
    this.enabled = true,
    this.semanticLabel,
  });

  /// The plain-text tooltip message announced to assistive technologies.
  final String message;

  /// The anchored trigger.
  final Widget child;

  /// Overrides the default text content while retaining [message] for
  /// accessibility.
  final Widget? content;

  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final MonoPlacement placement;
  final Offset offset;

  /// Space between the trigger and tooltip. Defaults to the extra-small token.
  final double? gap;

  /// Delay before hover opens the tooltip. Defaults to the fast motion token.
  final Duration? waitDuration;

  /// Delay before the tooltip closes after the pointer or focus leaves.
  /// Defaults to the fast motion token.
  final Duration? exitDuration;

  final bool enabled;
  final String? semanticLabel;

  @override
  State<MonoTooltip> createState() => _MonoTooltipState();
}

class _MonoTooltipState extends State<MonoTooltip> {
  Rect _anchorRect = Rect.zero;
  final FocusNode _focusNode = FocusNode(debugLabel: 'MonoTooltip');
  OverlayEntry? _entry;
  Timer? _showTimer;
  Timer? _hideTimer;
  late bool _uncontrolledOpen;
  bool _isHovering = false;
  bool _hasFocus = false;
  bool _isLongPressing = false;
  MonokitThemeData? _overlayTheme;
  TextDirection _textDirection = TextDirection.ltr;
  bool _disableAnimations = false;
  bool _overlaySyncScheduled = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;
  bool get _shouldRemainOpen => _isHovering || _hasFocus || _isLongPressing;

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
  void didUpdateWidget(covariant MonoTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.open != null && widget.open == null) {
      _uncontrolledOpen = oldWidget.open!;
    }
    if (!widget.enabled) {
      _cancelTimers();
      _uncontrolledOpen = false;
      _scheduleOverlaySync();
      return;
    }
    _scheduleOverlaySync();
  }

  @override
  void dispose() {
    _cancelTimers();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _cancelTimers() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _showTimer = null;
    _hideTimer = null;
  }

  Duration _waitDuration(BuildContext context) =>
      widget.waitDuration ?? MonokitTheme.of(context).motion.fast;

  Duration _exitDuration(BuildContext context) =>
      widget.exitDuration ?? MonokitTheme.of(context).motion.fast;

  void _scheduleOpen({required bool immediately}) {
    if (!widget.enabled) {
      return;
    }
    _hideTimer?.cancel();
    _hideTimer = null;
    if (_isOpen) {
      return;
    }
    _showTimer?.cancel();
    final delay = immediately ? Duration.zero : _waitDuration(context);
    _showTimer = Timer(delay, () {
      _showTimer = null;
      if (mounted && widget.enabled && _shouldRemainOpen) {
        _requestOpen(true);
      }
    });
  }

  void _scheduleClose() {
    if (_shouldRemainOpen) {
      return;
    }
    _showTimer?.cancel();
    _showTimer = null;
    if (!_isOpen) {
      return;
    }
    _hideTimer?.cancel();
    _hideTimer = Timer(_exitDuration(context), () {
      _hideTimer = null;
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
    _scheduleOverlaySync();
  }

  /// Defers overlay mutations until this frame's widget updates are complete.
  void _scheduleOverlaySync() {
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
    _overlayTheme = MonokitTheme.of(context);
    _textDirection = Directionality.of(context);
    _disableAnimations = MonokitMotion.noAnimation(context);
    _entry = OverlayEntry(
      maintainState: true,
      builder: (overlayContext) => _buildOverlay(),
    );
    overlay.insert(_entry!);
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
  }

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return _MonoTooltipOverlay(
      theme: theme,
      visible: _overlayVisible,
      onExited: _onOverlayExited,
      anchorRect: _resolveAnchorRect(),
      placement: widget.placement,
      offset: widget.offset,
      gap: widget.gap ?? theme.spacing.xs,
      textDirection: _textDirection,
      disableAnimations: _disableAnimations,
      semanticLabel: widget.semanticLabel ?? widget.message,
      child: widget.content ?? Text(widget.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Touch has no hover to answer, so the overlay never arms. The semantics
    // stay, because the label is the part a screen reader needs at any density.
    if (MonokitTheme.of(context).density.isTouch && widget.open == null) {
      return Semantics(tooltip: widget.message, child: widget.child);
    }
    return Semantics(
      tooltip: widget.message,
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (hasFocus) {
          _hasFocus = hasFocus;
          if (hasFocus) {
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
                  _isHovering = true;
                  _scheduleOpen(immediately: false);
                }
              : null,
          onExit: widget.enabled
              ? (_) {
                  _isHovering = false;
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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _MonoTooltipOverlay extends StatefulWidget {
  const _MonoTooltipOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.anchorRect,
    required this.placement,
    required this.offset,
    required this.gap,
    required this.textDirection,
    required this.disableAnimations,
    required this.semanticLabel,
    required this.child,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final Rect anchorRect;
  final MonoPlacement placement;
  final Offset offset;
  final double gap;
  final TextDirection textDirection;
  final bool disableAnimations;
  final String semanticLabel;
  final Widget child;

  @override
  State<_MonoTooltipOverlay> createState() => _MonoTooltipOverlayState();
}

class _MonoTooltipOverlayState extends State<_MonoTooltipOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

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
  }

  @override
  void didUpdateWidget(covariant _MonoTooltipOverlay oldWidget) {
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchors = _MonoTooltipAnchors.resolve(
      widget.placement,
      widget.textDirection,
    );
    final animation = CurvedAnimation(
      parent: _controller,
      curve: widget.theme.motion.curve,
    );
    return MonokitTheme(
      data: widget.theme,
      child: IgnorePointer(
        ignoring: true,
        child: MonoAnchoredOverlay(
          anchorRect: widget.anchorRect.shift(widget.offset),
          placement: widget.placement,
          gap: widget.gap,
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
              alignment: anchors.scaleAlignment,
              child: Semantics(
                container: true,
                liveRegion: true,
                label: widget.semanticLabel,
                child: MonoTooltipContent(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _MonoTooltipAnchors {
  const _MonoTooltipAnchors({
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

  static _MonoTooltipAnchors resolve(
    MonoPlacement placement,
    TextDirection textDirection,
  ) {
    final isLtr = textDirection == TextDirection.ltr;
    final start = isLtr ? Alignment.topLeft : Alignment.topRight;
    final end = isLtr ? Alignment.topRight : Alignment.topLeft;
    final bottomStart = isLtr ? Alignment.bottomLeft : Alignment.bottomRight;
    final bottomEnd = isLtr ? Alignment.bottomRight : Alignment.bottomLeft;

    return switch (placement) {
      MonoPlacement.top => const _MonoTooltipAnchors(
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topStart => _MonoTooltipAnchors(
        targetAnchor: start,
        followerAnchor: bottomStart,
        direction: AxisDirection.up,
      ),
      MonoPlacement.topEnd => _MonoTooltipAnchors(
        targetAnchor: end,
        followerAnchor: bottomEnd,
        direction: AxisDirection.up,
      ),
      MonoPlacement.right => const _MonoTooltipAnchors(
        targetAnchor: Alignment.centerRight,
        followerAnchor: Alignment.centerLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightStart => const _MonoTooltipAnchors(
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.rightEnd => const _MonoTooltipAnchors(
        targetAnchor: Alignment.bottomRight,
        followerAnchor: Alignment.bottomLeft,
        direction: AxisDirection.right,
      ),
      MonoPlacement.bottom => const _MonoTooltipAnchors(
        targetAnchor: Alignment.bottomCenter,
        followerAnchor: Alignment.topCenter,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomStart => _MonoTooltipAnchors(
        targetAnchor: bottomStart,
        followerAnchor: start,
        direction: AxisDirection.down,
      ),
      MonoPlacement.bottomEnd => _MonoTooltipAnchors(
        targetAnchor: bottomEnd,
        followerAnchor: end,
        direction: AxisDirection.down,
      ),
      MonoPlacement.left => const _MonoTooltipAnchors(
        targetAnchor: Alignment.centerLeft,
        followerAnchor: Alignment.centerRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftStart => const _MonoTooltipAnchors(
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.topRight,
        direction: AxisDirection.left,
      ),
      MonoPlacement.leftEnd => const _MonoTooltipAnchors(
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.bottomRight,
        direction: AxisDirection.left,
      ),
    };
  }
}
