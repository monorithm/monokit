import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../motion/mono_spring_controller.dart';
import '../primitives/mono_focus_trap.dart';
import '../primitives/mono_heading.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import '../theme/monokit_elevation.dart';

/// Edge from which a [MonoSheet] enters the screen.
enum MonoSheetSide { bottom, top }

/// Makes sheet open/close actions available to triggers and content.
/// **A touch surface.** At pointer density the sheet's jobs pass to
/// [MonoModal] and the menus: a drag handle is a thumb affordance, and a
/// surface that rises from the bottom edge of a 1400px window has risen from
/// nowhere the cursor was.
///
/// Nothing enforces this — a gallery legitimately renders one at any density,
/// and the choice belongs to the screen.
///
class MonoSheetScope extends InheritedWidget {
  const MonoSheetScope({
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

  static MonoSheetScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoSheetScope>();
  }

  static MonoSheetScope of(BuildContext context) {
    final MonoSheetScope? scope = maybeOf(context);
    assert(scope != null, 'No MonoSheet found in context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(MonoSheetScope oldWidget) {
    return isOpen != oldWidget.isOpen ||
        open != oldWidget.open ||
        close != oldWidget.close ||
        toggle != oldWidget.toggle;
  }
}

/// Keyboard-accessible trigger for the nearest [MonoSheet].
class MonoSheetTrigger extends StatelessWidget {
  const MonoSheetTrigger({
    super.key,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final bool enabled;

  /// Accessible name for the trigger. Falls back to
  /// `MonokitTheme.of(context).labels.openSheet` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MonoSheetScope? scope = MonoSheetScope.maybeOf(context);
    return MonoPressable(
      semanticLabel: semanticLabel ?? MonokitTheme.of(context).labels.openSheet,
      enabled: enabled && scope != null,
      onPressed: scope?.toggle,
      child: (BuildContext context, Set<MonoState> states) =>
          Semantics(expanded: scope?.isOpen ?? false, child: child),
    );
  }
}

/// Keyboard-accessible close action for sheet content.
class MonoSheetClose extends StatelessWidget {
  const MonoSheetClose({super.key, required this.child, this.semanticLabel});

  final Widget child;

  /// Accessible name for the close action. Falls back to
  /// `MonokitTheme.of(context).labels.closeSheet` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MonoSheetScope? scope = MonoSheetScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.closeSheet,
      enabled: scope != null,
      onPressed: scope?.close,
      child: (BuildContext context, Set<MonoState> states) => child,
    );
  }
}

/// Padded body slot for a [MonoSheet].
class MonoSheetContent extends StatelessWidget {
  const MonoSheetContent({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.all(theme.spacing.lg),
      child: DefaultTextStyle.merge(
        style: theme.typography.bodyMedium.copyWith(
          color: theme.colors.foreground,
        ),
        child: child,
      ),
    );
  }
}

/// Standard title/description slot for a [MonoSheet].
class MonoSheetHeader extends StatelessWidget {
  const MonoSheetHeader({super.key, this.title, this.description, this.child})
    : assert(child != null || title != null || description != null);

  final Widget? title;
  final Widget? description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    if (child != null) {
      return child!;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (title != null)
          MonoHeading(
            DefaultTextStyle.merge(
              style: theme.typography.titleLarge.copyWith(
                color: theme.colors.foreground,
              ),
              child: title!,
            ),
          ),
        if (title != null && description != null)
          SizedBox(height: theme.spacing.sm),
        if (description != null)
          DefaultTextStyle.merge(
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.mutedForeground,
            ),
            child: description!,
          ),
      ],
    );
  }
}

/// Standard trailing action slot for a [MonoSheet].
class MonoSheetFooter extends StatelessWidget {
  const MonoSheetFooter({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final MonokitThemeData theme = MonokitTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.only(top: theme.spacing.lg),
      child: child,
    );
  }
}

/// A modal edge sheet with controlled and uncontrolled open state.
class MonoSheet extends StatefulWidget {
  const MonoSheet({
    super.key,
    this.trigger,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.side = MonoSheetSide.bottom,
    this.dismissible = true,
    this.requestFocus = true,
    this.semanticLabel,
    this.constraints,
    this.showHandle = true,
    this.statesController,
  });

  final Widget? trigger;
  final Widget child;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final MonoSheetSide side;
  final bool dismissible;
  final bool requestFocus;
  final String? semanticLabel;
  final BoxConstraints? constraints;
  final bool showHandle;
  final MonoStatesController? statesController;

  static MonoSheetScope? maybeOf(BuildContext context) =>
      MonoSheetScope.maybeOf(context);

  @override
  State<MonoSheet> createState() => _MonoSheetState();
}

class _MonoSheetState extends State<MonoSheet> {
  OverlayEntry? _entry;
  final MonoOverlayFocusController _overlayFocus = MonoOverlayFocusController();
  late bool _uncontrolledOpen;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;
  MonokitThemeData? _overlayTheme;
  bool _disableAnimations = false;
  bool _overlaySyncScheduled = false;

  bool get _isControlled => widget.open != null;
  bool get _isOpen => widget.open ?? _uncontrolledOpen;

  @override
  void initState() {
    super.initState();
    _uncontrolledOpen = widget.defaultOpen;
    _ownsStatesController = widget.statesController == null;
    _statesController = widget.statesController ?? MonoStatesController();
    _syncStates();
    _statesController.addListener(_handleStatesChanged);
    _scheduleOverlaySync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleOverlaySync();
  }

  @override
  void didUpdateWidget(covariant MonoSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool wasOpen = oldWidget.open ?? _uncontrolledOpen;
    if (oldWidget.open != null && widget.open == null) {
      _uncontrolledOpen = oldWidget.open!;
    }
    if (oldWidget.statesController != widget.statesController) {
      _statesController.removeListener(_handleStatesChanged);
      if (_ownsStatesController) {
        _statesController.dispose();
      }
      _ownsStatesController = widget.statesController == null;
      _statesController = widget.statesController ?? MonoStatesController();
      _syncStates();
      _statesController.addListener(_handleStatesChanged);
    }
    _syncStates();
    _scheduleOverlaySync(restoreFocus: wasOpen && !_isOpen);
  }

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
    _removeOverlayNow();
    _statesController.removeListener(_handleStatesChanged);
    if (_ownsStatesController) {
      _statesController.dispose();
    }
    super.dispose();
  }

  void _syncStates() => _statesController.update(MonoState.open, _isOpen);

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
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
    _statesController.update(MonoState.open, value);
    widget.onOpenChange?.call(value);
    _scheduleOverlaySync(restoreFocus: !value);
  }

  void _scheduleOverlaySync({bool restoreFocus = false}) {
    if (restoreFocus) {
      _overlayFocus.requestRestoreOnClose();
    }
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
        _showOrRefreshOverlayNow();
      } else {
        _beginClose();
      }
    });
  }

  bool _overlayVisible = false;

  void _showOrRefreshOverlayNow() {
    if (!mounted) {
      return;
    }
    _overlayVisible = true;
    _overlayTheme = MonokitTheme.of(context);
    _disableAnimations = MonokitMotion.noAnimation(context);
    final OverlayEntry? entry = _entry;
    if (entry != null) {
      entry.markNeedsBuild();
      return;
    }
    final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true);
    assert(
      overlay != null,
      'MonoOverlay: no Overlay ancestor found. Wrap the app in MonokitApp or a Navigator/Overlay.',
    );
    if (overlay == null) {
      return;
    }
    _overlayFocus.captureForOpen();
    _entry = OverlayEntry(
      maintainState: true,
      builder: (BuildContext context) => _buildOverlay(),
    );
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
    final OverlayEntry? entry = _entry;
    _entry = null;
    entry?.remove();
    entry?.dispose();
    _overlayFocus.restoreIfRequested(mounted: mounted);
  }

  Widget _buildOverlay() {
    final MonokitThemeData? theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return MonokitTheme(
      data: theme,
      child: _MonoSheetOverlay(
        theme: theme,
        visible: _overlayVisible,
        onExited: _onOverlayExited,
        side: widget.side,
        dismissible: widget.dismissible,
        requestFocus: widget.requestFocus,
        disableAnimations: _disableAnimations,
        semanticLabel: widget.semanticLabel,
        constraints: widget.constraints,
        showHandle: widget.showHandle,
        onDismiss: () => _requestOpen(false),
        scope: MonoSheetScope(
          isOpen: _isOpen,
          open: () => _requestOpen(true),
          close: () => _requestOpen(false),
          toggle: () => _requestOpen(!_isOpen),
          child: widget.child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget trigger = widget.trigger == null
        ? const SizedBox.shrink()
        : widget.trigger is MonoSheetTrigger
        ? widget.trigger!
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _requestOpen(!_isOpen),
            child: widget.trigger,
          );
    return MonoSheetScope(
      isOpen: _isOpen,
      open: () => _requestOpen(true),
      close: () => _requestOpen(false),
      toggle: () => _requestOpen(!_isOpen),
      child: trigger,
    );
  }
}

class _MonoSheetOverlay extends StatefulWidget {
  const _MonoSheetOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.side,
    required this.dismissible,
    required this.requestFocus,
    required this.disableAnimations,
    required this.scope,
    required this.showHandle,
    required this.onDismiss,
    this.semanticLabel,
    this.constraints,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final MonoSheetSide side;
  final bool dismissible;
  final bool requestFocus;
  final bool disableAnimations;
  final MonoSheetScope scope;
  final bool showHandle;
  final VoidCallback onDismiss;
  final String? semanticLabel;
  final BoxConstraints? constraints;

  @override
  State<_MonoSheetOverlay> createState() => _MonoSheetOverlayState();
}

class _MonoSheetOverlayState extends State<_MonoSheetOverlay>
    with SingleTickerProviderStateMixin {
  /// Openness: 0 is fully offscreen, 1 is seated. Values above 1 are overdrag,
  /// which the rubber band resists rather than clamping.
  late final MonoSpringController _openness;
  late final FocusNode _focusNode;
  final GlobalKey _surfaceKey = GlobalKey();

  /// Velocity captured at the moment a drag releases into a dismissal, so the
  /// parent-driven `visible: false` rebuild can continue the same motion
  /// instead of restarting from rest.
  double? _releaseVelocity;

  SpringDescription? get _spring =>
      widget.disableAnimations ? null : widget.theme.motion.spatial;

  /// Sheet height in logical pixels, used to convert drag deltas into openness.
  double get _extent {
    final box = _surfaceKey.currentContext?.findRenderObject() as RenderBox?;
    final height = box?.size.height ?? 0;
    return height > 0 ? height : 1;
  }

  bool get _canDrag => widget.dismissible;

  @override
  void initState() {
    super.initState();
    _openness = MonoSpringController(
      vsync: this,
      value: widget.visible ? 0 : 0,
    );
    _openness.addListener(_onTick);
    _focusNode = FocusNode(debugLabel: 'MonoSheet');
    if (widget.visible) {
      _openness.animateTo(1, spring: _spring);
    }
    if (widget.requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  /// Guards against reporting the exit twice — the settle tick and the
  /// jump-on-reduced-motion path can otherwise both fire it.
  bool _reportedExit = false;

  void _onTick() {
    if (!mounted) return;
    setState(() {});
    _maybeReportExit();
  }

  void _maybeReportExit() {
    if (_reportedExit || widget.visible) return;
    if (_openness.isAnimating || _openness.value > 0.001) return;
    _reportedExit = true;
    widget.onExited();
  }

  @override
  void didUpdateWidget(covariant _MonoSheetOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      final velocity = _releaseVelocity;
      _releaseVelocity = null;
      if (widget.visible) _reportedExit = false;
      _openness.animateTo(
        widget.visible ? 1 : 0,
        withVelocity: velocity,
        spring: _spring,
      );
      // With motion disabled animateTo jumps, and a jump to a value that is
      // already 0 emits no tick — so report from here too. _maybeReportExit
      // is idempotent.
      _maybeReportExit();
    }
  }

  void _onDragStart(DragStartDetails details) => _openness.stop();

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    // A bottom sheet closes downward, a top sheet upward.
    final towardClosed = widget.side == MonoSheetSide.bottom ? delta : -delta;
    var next = _openness.value - towardClosed / _extent;
    if (next > 1) {
      // Resist pulling further open than the sheet actually is.
      next = 1 + monoRubberBand((next - 1) * _extent, _extent) / _extent;
    }
    _openness.jumpTo(next.clamp(0.0, 2.0));
  }

  void _onDragEnd(DragEndDetails details) {
    final pixels = details.velocity.pixelsPerSecond.dy;
    final towardClosed = widget.side == MonoSheetSide.bottom ? pixels : -pixels;
    // Openness units per second: positive means being flung open.
    final velocity = -towardClosed / _extent;

    // Decide on where the fling would land, not where the finger let go — a
    // hard flick from past the midpoint should still dismiss.
    final target = monoNearest(const <double>[
      0,
      1,
    ], monoProject(_openness.value, velocity));

    if (target == 0) {
      _releaseVelocity = velocity;
      widget.onDismiss();
    } else {
      _openness.animateTo(1, withVelocity: velocity, spring: _spring);
    }
  }

  @override
  void dispose() {
    _openness.removeListener(_onTick);
    _openness.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Openness drives position on a spring; the scrim is pure opacity and so
    // reads straight off the same value without a curve of its own.
    final double openness = _openness.value;
    final double scrimOpacity = openness.clamp(0.0, 1.0);
    final bool isBottom = widget.side == MonoSheetSide.bottom;
    final Alignment alignment = isBottom
        ? Alignment.bottomCenter
        : Alignment.topCenter;
    final Offset begin = Offset(0, isBottom ? 1 : -1);
    final BorderRadius radius = isBottom
        ? BorderRadius.vertical(top: Radius.circular(widget.theme.radii.xxl))
        : BorderRadius.vertical(
            bottom: Radius.circular(widget.theme.radii.xxl),
          );
    // Cap the sheet to the area left above the keyboard so tall content
    // scrolls instead of overflowing, and forms stay visible while typing.
    final MediaQueryData media = MediaQuery.of(context);
    final double visibleHeight =
        media.size.height - media.viewInsets.bottom - media.padding.vertical;
    final double heightCap = visibleHeight * 0.9;
    final BoxConstraints baseConstraints =
        widget.constraints ?? const BoxConstraints(maxWidth: 720);
    final double maxHeight = baseConstraints.maxHeight < heightCap
        ? baseConstraints.maxHeight
        : heightCap;
    Widget surface = ConstrainedBox(
      key: _surfaceKey,
      constraints: baseConstraints.copyWith(maxHeight: maxHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.theme.colors.popover,
          borderRadius: radius,
          boxShadow: widget.theme.elevation.resolve(MonoElevation.floating),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.showHandle)
              // The handle now affords something. It previously drew a grab
              // pill over a sheet that had no drag gesture at all.
              Semantics(
                label: widget.theme.labels.closeSheet,
                button: _canDrag,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: _canDrag ? _onDragStart : null,
                  onVerticalDragUpdate: _canDrag ? _onDragUpdate : null,
                  onVerticalDragEnd: _canDrag ? _onDragEnd : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: widget.theme.spacing.sm,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: widget.theme.spacing.xxl,
                        height: widget.theme.spacing.xs,
                        decoration: BoxDecoration(
                          color: widget.theme.colors.mutedForeground.withAlpha(
                            120,
                          ),
                          borderRadius: BorderRadius.circular(
                            widget.theme.radii.full,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Flexible(child: SingleChildScrollView(child: widget.scope)),
          ],
        ),
      ),
    );
    surface = SafeArea(
      top: !isBottom,
      bottom: isBottom,
      left: true,
      right: true,
      child: surface,
    );

    return MonoFocusTrap(
      autofocus: widget.requestFocus,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (FocusNode node, KeyEvent event) {
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
          children: <Widget>[
            Opacity(
              opacity: scrimOpacity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.dismissible ? widget.onDismiss : null,
                child: ColoredBox(color: widget.theme.colors.scrim),
              ),
            ),
            // Keep the sheet above the software keyboard.
            Padding(
              padding: EdgeInsets.only(
                bottom: isBottom ? media.viewInsets.bottom : 0,
              ),
              child: Align(
                alignment: alignment,
                child: FractionalTranslation(
                  // begin.dy is +1 for a bottom sheet, -1 for a top one; at
                  // openness 1 the sheet is seated, and overdrag (>1) lets it
                  // peek past its resting position.
                  translation: Offset(0, (1 - openness) * begin.dy),
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    explicitChildNodes: true,
                    label: widget.semanticLabel ?? widget.theme.labels.sheet,
                    child: surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
