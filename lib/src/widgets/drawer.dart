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

/// Logical edge from which a [MonoDrawer] is revealed.
enum MonoDrawerSide { start, end }

/// Makes drawer open/close actions available to descendants.
/// **Expanded and pointer only.** The drawer is the web view's side
/// navigation; on touch the tab bar carries the same five destinations in the
/// same order — one information architecture, two densities. The two must
/// never coexist: a screen showing both is showing its navigation twice.
///
/// Nothing enforces this, because the component that would is a navigation
/// scaffold the package does not have — a screen still chooses between this
/// and [MonoBottomNav] itself.
///
class MonoDrawerScope extends InheritedWidget {
  const MonoDrawerScope({
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

  static MonoDrawerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoDrawerScope>();
  }

  static MonoDrawerScope of(BuildContext context) {
    final MonoDrawerScope? scope = maybeOf(context);
    assert(scope != null, 'No MonoDrawer found in context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(MonoDrawerScope oldWidget) {
    return isOpen != oldWidget.isOpen ||
        open != oldWidget.open ||
        close != oldWidget.close ||
        toggle != oldWidget.toggle;
  }
}

/// Keyboard-accessible trigger for the nearest [MonoDrawer].
class MonoDrawerTrigger extends StatelessWidget {
  const MonoDrawerTrigger({
    super.key,
    required this.child,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final bool enabled;

  /// Accessible name for the trigger. Falls back to
  /// `MonokitTheme.of(context).labels.openDrawer` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MonoDrawerScope? scope = MonoDrawerScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.openDrawer,
      enabled: enabled && scope != null,
      onPressed: scope?.toggle,
      child: (BuildContext context, Set<MonoState> states) =>
          Semantics(expanded: scope?.isOpen ?? false, child: child),
    );
  }
}

/// Keyboard-accessible close action for drawer content.
class MonoDrawerClose extends StatelessWidget {
  const MonoDrawerClose({super.key, required this.child, this.semanticLabel});

  final Widget child;

  /// Accessible name for the close action. Falls back to
  /// `MonokitTheme.of(context).labels.closeDrawer` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final MonoDrawerScope? scope = MonoDrawerScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.closeDrawer,
      enabled: scope != null,
      onPressed: scope?.close,
      child: (BuildContext context, Set<MonoState> states) => child,
    );
  }
}

/// Padded drawer content slot.
class MonoDrawerContent extends StatelessWidget {
  const MonoDrawerContent({super.key, required this.child, this.padding});

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

/// Standard title/description slot for a [MonoDrawer].
class MonoDrawerHeader extends StatelessWidget {
  const MonoDrawerHeader({super.key, this.title, this.description, this.child})
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

/// Standard trailing action slot for a [MonoDrawer].
class MonoDrawerFooter extends StatelessWidget {
  const MonoDrawerFooter({super.key, required this.child, this.padding});

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

/// A modal side drawer with controlled and uncontrolled open state.
class MonoDrawer extends StatefulWidget {
  const MonoDrawer({
    super.key,
    this.trigger,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.side = MonoDrawerSide.start,
    this.dismissible = true,
    this.requestFocus = true,
    this.semanticLabel,
    this.width,
    this.statesController,
  }) : assert(width == null || width > 0);

  final Widget? trigger;
  final Widget child;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final MonoDrawerSide side;
  final bool dismissible;
  final bool requestFocus;
  final String? semanticLabel;
  final double? width;
  final MonoStatesController? statesController;

  static MonoDrawerScope? maybeOf(BuildContext context) =>
      MonoDrawerScope.maybeOf(context);

  @override
  State<MonoDrawer> createState() => _MonoDrawerState();
}

class _MonoDrawerState extends State<MonoDrawer> {
  OverlayEntry? _entry;
  final MonoOverlayFocusController _overlayFocus = MonoOverlayFocusController();
  late bool _uncontrolledOpen;
  late MonoStatesController _statesController;
  late bool _ownsStatesController;
  MonokitThemeData? _overlayTheme;
  TextDirection _textDirection = TextDirection.ltr;
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
  void didUpdateWidget(covariant MonoDrawer oldWidget) {
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
    _textDirection = Directionality.of(context);
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
      child: _MonoDrawerOverlay(
        theme: theme,
        visible: _overlayVisible,
        onExited: _onOverlayExited,
        side: widget.side,
        textDirection: _textDirection,
        dismissible: widget.dismissible,
        requestFocus: widget.requestFocus,
        disableAnimations: _disableAnimations,
        semanticLabel: widget.semanticLabel,
        width: widget.width,
        onDismiss: () => _requestOpen(false),
        scope: MonoDrawerScope(
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
        : widget.trigger is MonoDrawerTrigger
        ? widget.trigger!
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _requestOpen(!_isOpen),
            child: widget.trigger,
          );
    return MonoDrawerScope(
      isOpen: _isOpen,
      open: () => _requestOpen(true),
      close: () => _requestOpen(false),
      toggle: () => _requestOpen(!_isOpen),
      child: trigger,
    );
  }
}

class _MonoDrawerOverlay extends StatefulWidget {
  const _MonoDrawerOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.side,
    required this.textDirection,
    required this.dismissible,
    required this.requestFocus,
    required this.disableAnimations,
    required this.scope,
    required this.onDismiss,
    this.semanticLabel,
    this.width,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final MonoDrawerSide side;
  final TextDirection textDirection;
  final bool dismissible;
  final bool requestFocus;
  final bool disableAnimations;
  final MonoDrawerScope scope;
  final VoidCallback onDismiss;
  final String? semanticLabel;
  final double? width;

  @override
  State<_MonoDrawerOverlay> createState() => _MonoDrawerOverlayState();
}

class _MonoDrawerOverlayState extends State<_MonoDrawerOverlay>
    with SingleTickerProviderStateMixin {
  /// Openness: 0 offscreen, 1 seated. Mirrors [MonoSheet], but on the
  /// horizontal axis.
  late final MonoSpringController _openness;
  late final FocusNode _focusNode;
  final GlobalKey _surfaceKey = GlobalKey();

  double? _releaseVelocity;
  bool _reportedExit = false;

  SpringDescription? get _spring =>
      widget.disableAnimations ? null : widget.theme.motion.spatial;

  /// Drawer width in logical pixels, for converting drag deltas to openness.
  double get _extent {
    final box = _surfaceKey.currentContext?.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 0;
    return width > 0 ? width : 1;
  }

  bool get _canDrag => widget.dismissible;

  /// Which screen direction closes the drawer: a start-side drawer closes
  /// leftward in LTR, rightward in RTL.
  double get _closeSign {
    final startIsLeft = widget.textDirection == TextDirection.ltr;
    final onLeft = widget.side == MonoDrawerSide.start
        ? startIsLeft
        : !startIsLeft;
    return onLeft ? -1 : 1;
  }

  @override
  void initState() {
    super.initState();
    _openness = MonoSpringController(vsync: this)..addListener(_onTick);
    _focusNode = FocusNode(debugLabel: 'MonoDrawer');
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
  void didUpdateWidget(covariant _MonoDrawerOverlay oldWidget) {
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
      _maybeReportExit();
    }
  }

  void _onDragStart(DragStartDetails details) => _openness.stop();

  void _onDragUpdate(DragUpdateDetails details) {
    final delta = (details.primaryDelta ?? 0) * _closeSign;
    var next = _openness.value - delta / _extent;
    if (next > 1) {
      next = 1 + monoRubberBand((next - 1) * _extent, _extent) / _extent;
    }
    _openness.jumpTo(next.clamp(0.0, 2.0));
  }

  void _onDragEnd(DragEndDetails details) {
    final pixels = details.velocity.pixelsPerSecond.dx * _closeSign;
    final velocity = -pixels / _extent;
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
    final double openness = _openness.value;
    final double scrimOpacity = openness.clamp(0.0, 1.0);
    final bool startIsLeft = widget.textDirection == TextDirection.ltr;
    final bool opensLeft = widget.side == MonoDrawerSide.start
        ? startIsLeft
        : !startIsLeft;
    final Alignment alignment = opensLeft
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final Offset begin = Offset(opensLeft ? -1 : 1, 0);
    final BorderRadius radius = opensLeft
        ? BorderRadius.horizontal(right: Radius.circular(widget.theme.radii.xl))
        : BorderRadius.horizontal(left: Radius.circular(widget.theme.radii.xl));
    final double width = widget.width ?? widget.theme.spacing.giant * 7;
    final Widget surface = SafeArea(
      child: SizedBox(
        key: _surfaceKey,
        width: width,
        height: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.theme.colors.popover,
            borderRadius: radius,
            boxShadow: widget.theme.elevation.resolve(MonoElevation.floating),
          ),
          child: widget.scope,
        ),
      ),
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
            Align(
              alignment: alignment,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onHorizontalDragStart: _canDrag ? _onDragStart : null,
                onHorizontalDragUpdate: _canDrag ? _onDragUpdate : null,
                onHorizontalDragEnd: _canDrag ? _onDragEnd : null,
                child: FractionalTranslation(
                  translation: Offset((1 - openness) * begin.dx, 0),
                  child: Semantics(
                    scopesRoute: true,
                    namesRoute: true,
                    explicitChildNodes: true,
                    label: widget.semanticLabel ?? widget.theme.labels.drawer,
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
