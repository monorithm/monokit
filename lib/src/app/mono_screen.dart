import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_overlay_layer.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_motion.dart';

/// Edges that receive safe-area compensation in a [MonoScreen].
@immutable
class MonoSafeArea {
  const MonoSafeArea({
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  const MonoSafeArea.all() : this();

  const MonoSafeArea.none()
    : top = false,
      bottom = false,
      left = false,
      right = false;

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
}

/// How a screen region relates to a system or keyboard inset.
enum MonoInsetMode { inset, scrim, bleed }

/// Per-edge immersive inset policy for [MonoScreen]'s body region.
@immutable
class MonoInsetPolicy {
  const MonoInsetPolicy({
    this.top = MonoInsetMode.inset,
    this.bottom = MonoInsetMode.inset,
    this.left = MonoInsetMode.inset,
    this.right = MonoInsetMode.inset,
    this.keyboard = MonoInsetMode.inset,
  });

  final MonoInsetMode top;
  final MonoInsetMode bottom;
  final MonoInsetMode left;
  final MonoInsetMode right;
  final MonoInsetMode keyboard;
}

enum MonoHeaderBehavior { fixed, collapsing, floating, immersive }

enum MonoFooterBehavior { fixed, floating, immersive }

enum MonoSidebarReveal { pushInset, rail, pinned }

/// Coordinated timing for [MonoScreen] region transitions.
@immutable
class MonoScreenMotion {
  const MonoScreenMotion({
    required this.chromeCurve,
    required this.chromeDuration,
    required this.sidebarCurve,
    required this.sidebarDuration,
    required this.overlayCurve,
    required this.overlayDuration,
    required this.insetCurve,
    required this.insetDuration,
  });

  factory MonoScreenMotion.fromTokens(MonokitMotion motion) {
    return MonoScreenMotion(
      chromeCurve: motion.curve,
      chromeDuration: motion.duration,
      sidebarCurve: motion.emphasizedCurve,
      sidebarDuration: motion.moderate,
      overlayCurve: motion.curve,
      overlayDuration: motion.duration,
      insetCurve: motion.curve,
      insetDuration: motion.duration,
    );
  }

  final Curve chromeCurve;
  final Duration chromeDuration;
  final Curve sidebarCurve;
  final Duration sidebarDuration;
  final Curve overlayCurve;
  final Duration overlayDuration;
  final Curve insetCurve;
  final Duration insetDuration;
}

/// Controls a [MonoScreen] mobile sidebar reveal.
class MonoSidebarController extends ChangeNotifier {
  MonoSidebarController({bool isOpen = false}) : this._(isOpen);

  MonoSidebarController._(this._isOpen);

  bool _isOpen;

  bool get isOpen => _isOpen;

  void open() => _setOpen(true);
  void close() => _setOpen(false);
  void toggle() => _setOpen(!_isOpen);
  void setOpen(bool value) => _setOpen(value);

  void _setOpen(bool value) {
    if (_isOpen == value) {
      return;
    }
    _isOpen = value;
    notifyListeners();
  }
}

/// Resolved screen information available to descendants.
class MonoScreenScope extends InheritedWidget {
  const MonoScreenScope({
    super.key,
    required this.resolvedBodyInsets,
    required this.overlays,
    required this.sidebarController,
    required this.isCompact,
    required this.sidebarReveal,
    required super.child,
  });

  final EdgeInsets resolvedBodyInsets;
  final MonoOverlayController overlays;
  final MonoSidebarController sidebarController;
  final bool isCompact;
  final MonoSidebarReveal sidebarReveal;

  static MonoScreenScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MonoScreenScope>();
    assert(scope != null, 'No MonoScreen found in context.');
    return scope!;
  }

  static MonoScreenScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoScreenScope>();
  }

  @override
  bool updateShouldNotify(MonoScreenScope oldWidget) {
    return resolvedBodyInsets != oldWidget.resolvedBodyInsets ||
        overlays != oldWidget.overlays ||
        sidebarController != oldWidget.sidebarController ||
        isCompact != oldWidget.isCompact ||
        sidebarReveal != oldWidget.sidebarReveal;
  }
}

/// Monokit's widgets-first page shell.
///
/// The screen owns its background, regions, keyboard/safe-area policy and a
/// lightweight overlay layer. On compact layouts a supplied sidebar is painted
/// below the page composite, then revealed by pushing that whole composite aside.
class MonoScreen extends StatefulWidget {
  const MonoScreen({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.sidebar,
    this.floating,
    this.background,
    this.backdrop,
    this.safeArea = const MonoSafeArea.all(),
    this.resizeToAvoidInset = true,
    this.scrollBody = false,
    this.insetPolicy = const MonoInsetPolicy(),
    this.headerBehavior = MonoHeaderBehavior.fixed,
    this.footerBehavior = MonoFooterBehavior.fixed,
    this.motion,
    this.sidebarController,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final Widget? sidebar;
  final Widget? floating;
  final Color? background;
  final Widget? backdrop;
  final MonoSafeArea safeArea;
  final bool resizeToAvoidInset;
  final bool scrollBody;
  final MonoInsetPolicy insetPolicy;
  final MonoHeaderBehavior headerBehavior;
  final MonoFooterBehavior footerBehavior;
  final MonoScreenMotion? motion;
  final MonoSidebarController? sidebarController;

  /// Accesses the [MonoScreenScope] closest to [context].
  static MonoScreenScope of(BuildContext context) =>
      MonoScreenScope.of(context);

  static MonoScreenScope? maybeOf(BuildContext context) =>
      MonoScreenScope.maybeOf(context);

  @override
  State<MonoScreen> createState() => _MonoScreenState();
}

class _MonoScreenState extends State<MonoScreen>
    with SingleTickerProviderStateMixin {
  late MonoOverlayController _overlays;
  late MonoSidebarController _sidebarController;
  late bool _ownsSidebarController;
  late AnimationController _sidebarAnimation;
  MonoScreenMotion? _lastMotion;

  @override
  void initState() {
    super.initState();
    _overlays = MonoOverlayController();
    _setSidebarController(widget.sidebarController);
    _sidebarAnimation = AnimationController(
      vsync: this,
      value: _sidebarController.isOpen ? 1 : 0,
    );
  }

  void _setSidebarController(MonoSidebarController? controller) {
    _ownsSidebarController = controller == null;
    _sidebarController = controller ?? MonoSidebarController();
    _sidebarController.addListener(_syncSidebar);
  }

  @override
  void didUpdateWidget(covariant MonoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sidebarController != widget.sidebarController) {
      _sidebarController.removeListener(_syncSidebar);
      if (_ownsSidebarController) {
        _sidebarController.dispose();
      }
      _setSidebarController(widget.sidebarController);
      _syncSidebar();
    }
  }

  void _syncSidebar() {
    if (!mounted) {
      return;
    }
    final motion = _lastMotion;
    if (motion == null ||
        MediaQuery.maybeOf(context)?.disableAnimations == true) {
      _sidebarAnimation.value = _sidebarController.isOpen ? 1 : 0;
      return;
    }
    if (_sidebarController.isOpen) {
      _sidebarAnimation.animateTo(
        1,
        duration: motion.sidebarDuration,
        curve: motion.sidebarCurve,
      );
    } else {
      _sidebarAnimation.animateBack(
        0,
        duration: motion.sidebarDuration,
        curve: motion.sidebarCurve,
      );
    }
  }

  @override
  void dispose() {
    _sidebarController.removeListener(_syncSidebar);
    if (_ownsSidebarController) {
      _sidebarController.dispose();
    }
    _sidebarAnimation.dispose();
    _overlays.dispose();
    super.dispose();
  }

  EdgeInsets _bodyInsets(MediaQueryData media) {
    final safe = media.viewPadding;
    final keyboard = widget.resizeToAvoidInset ? media.viewInsets.bottom : 0.0;
    final policy = widget.insetPolicy;
    final top = policy.top == MonoInsetMode.inset && widget.safeArea.top
        ? safe.top
        : 0.0;
    final left = policy.left == MonoInsetMode.inset && widget.safeArea.left
        ? safe.left
        : 0.0;
    final right = policy.right == MonoInsetMode.inset && widget.safeArea.right
        ? safe.right
        : 0.0;
    final bottomSafe =
        policy.bottom == MonoInsetMode.inset && widget.safeArea.bottom
        ? safe.bottom
        : 0.0;
    final bottomKeyboard = policy.keyboard == MonoInsetMode.inset
        ? keyboard
        : 0.0;
    return EdgeInsets.fromLTRB(left, top, right, bottomSafe + bottomKeyboard);
  }

  /// Insets for edges in [MonoInsetMode.scrim]: the container bleeds under the
  /// system inset, but this amount is exposed via [MonoScreenScope] so immersive
  /// content (a feed overlay, on-media chrome) can pad itself clear of the
  /// status bar / home indicator. [MonoInsetMode.bleed] exposes nothing.
  EdgeInsets _scrimInsets(MediaQueryData media) {
    final safe = media.viewPadding;
    final keyboard = widget.resizeToAvoidInset ? media.viewInsets.bottom : 0.0;
    final policy = widget.insetPolicy;
    final top = policy.top == MonoInsetMode.scrim && widget.safeArea.top
        ? safe.top
        : 0.0;
    final left = policy.left == MonoInsetMode.scrim && widget.safeArea.left
        ? safe.left
        : 0.0;
    final right = policy.right == MonoInsetMode.scrim && widget.safeArea.right
        ? safe.right
        : 0.0;
    final bottomSafe =
        policy.bottom == MonoInsetMode.scrim && widget.safeArea.bottom
        ? safe.bottom
        : 0.0;
    final bottomKeyboard = policy.keyboard == MonoInsetMode.scrim
        ? keyboard
        : 0.0;
    return EdgeInsets.fromLTRB(left, top, right, bottomSafe + bottomKeyboard);
  }

  EdgeInsets _edgeSafePadding(MediaQueryData media, {bool keyboard = false}) {
    return EdgeInsets.only(
      left: widget.safeArea.left ? media.viewPadding.left : 0,
      top: widget.safeArea.top ? media.viewPadding.top : 0,
      right: widget.safeArea.right ? media.viewPadding.right : 0,
      bottom: widget.safeArea.bottom
          ? media.viewPadding.bottom +
                (keyboard && widget.resizeToAvoidInset
                    ? media.viewInsets.bottom
                    : 0)
          : 0,
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required EdgeInsets bodyInsets,
    required MonoScreenMotion motion,
  }) {
    final theme = MonokitTheme.of(context);
    Widget body = Padding(padding: bodyInsets, child: widget.body);
    if (widget.scrollBody) {
      body = SingleChildScrollView(padding: bodyInsets, child: widget.body);
    }

    final media = MediaQuery.of(context);
    final header =
        widget.header == null ||
            widget.headerBehavior == MonoHeaderBehavior.immersive
        ? null
        : Padding(
            padding: _edgeSafePadding(media).copyWith(bottom: 0),
            child: widget.header,
          );
    final footer =
        widget.footer == null ||
            widget.footerBehavior == MonoFooterBehavior.immersive
        ? null
        : Padding(
            padding: _edgeSafePadding(media, keyboard: true).copyWith(top: 0),
            child: widget.footer,
          );

    // Reading order for screen readers: the header/body/footer column reads
    // before the floating region, regardless of paint order. The floating
    // action is painted last and sits bottom-end, so without an explicit key it
    // can read in an ambiguous spot relative to the page content. Within the
    // column, header → body → footer already follow natural vertical order.
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Semantics(
          sortKey: const OrdinalSortKey(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ?header,
              Expanded(child: body),
              ?footer,
            ],
          ),
        ),
        if (widget.floating != null)
          PositionedDirectional(
            end: bodyInsets.right + theme.spacing.lg,
            bottom: bodyInsets.bottom + theme.spacing.lg,
            child: Semantics(
              sortKey: const OrdinalSortKey(2),
              child: widget.floating!,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    final motion = widget.motion ?? MonoScreenMotion.fromTokens(theme.motion);
    _lastMotion = motion;
    final bodyInsets = _bodyInsets(media);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenTheme = theme.components.screen;
        final isCompact = width < screenTheme.compactBreakpoint;
        final isMedium = !isCompact && width < screenTheme.mediumBreakpoint;
        final hasSidebar = widget.sidebar != null;
        final reveal = isCompact
            ? MonoSidebarReveal.pushInset
            : isMedium
            ? MonoSidebarReveal.rail
            : MonoSidebarReveal.pinned;
        final sidebarWidth = isMedium
            ? screenTheme.sidebarRailWidth
            : screenTheme.sidebarWidth;
        final page = _buildPage(
          context,
          bodyInsets: bodyInsets,
          motion: motion,
        );

        Widget pageWithSidebar;
        if (!hasSidebar || isCompact) {
          // At compact width the sidebar is painted behind the page and
          // revealed by sliding the page aside, so the page must be opaque to
          // conceal the closed sidebar rather than let it show through.
          final pageChild = hasSidebar && isCompact
              ? ColoredBox(
                  color: widget.background ?? theme.colors.background,
                  child: page,
                )
              : page;
          pageWithSidebar = AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              final offset = hasSidebar
                  ? sidebarWidth * _sidebarAnimation.value
                  : 0.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: pageChild,
          );
        } else {
          pageWithSidebar = Row(
            children: <Widget>[
              SizedBox(width: sidebarWidth, child: widget.sidebar!),
              Expanded(child: page),
            ],
          );
        }

        return MonoScreenScope(
          resolvedBodyInsets: _scrimInsets(media),
          overlays: _overlays,
          sidebarController: _sidebarController,
          isCompact: isCompact,
          sidebarReveal: reveal,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              ColoredBox(color: widget.background ?? theme.colors.background),
              if (widget.backdrop != null)
                Positioned.fill(child: widget.backdrop!),
              if (hasSidebar && isCompact)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ListenableBuilder(
                    listenable: _sidebarController,
                    child: SizedBox(
                      width: sidebarWidth,
                      child: widget.sidebar!,
                    ),
                    builder: (context, child) {
                      final isOpen = _sidebarController.isOpen;
                      // The compact sidebar remains mounted so the page can
                      // slide over it, but concealed controls must not remain
                      // reachable to assistive technology or focus traversal.
                      return ExcludeFocus(
                        excluding: !isOpen,
                        child: IgnorePointer(
                          ignoring: !isOpen,
                          child: ExcludeSemantics(
                            excluding: !isOpen,
                            child: child!,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              pageWithSidebar,
              MonoOverlayLayer(controller: _overlays),
            ],
          ),
        );
      },
    );
  }
}
