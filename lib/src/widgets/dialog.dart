import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../motion/mono_spring_controller.dart';
import '../primitives/mono_focus_trap.dart';
import '../primitives/mono_heading.dart';
import '../primitives/mono_overlay_focus.dart';
import '../primitives/mono_pressable.dart';
import '../theme/monokit_elevation.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Provides an imperative close action to descendants of [MonoDialog].
class MonoDialogScope extends InheritedWidget {
  const MonoDialogScope({super.key, required this.close, required super.child});

  final VoidCallback close;

  static MonoDialogScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoDialogScope>();
  }

  @override
  bool updateShouldNotify(MonoDialogScope oldWidget) =>
      close != oldWidget.close;
}

/// A widgets-only modal dialog root with optional declarative trigger.
class MonoDialog extends StatefulWidget {
  const MonoDialog({
    super.key,
    this.trigger,
    required this.child,
    this.open,
    this.defaultOpen = false,
    this.onOpenChange,
    this.dismissible = true,
    this.semanticLabel,
  });

  final Widget? trigger;
  final Widget child;
  final bool? open;
  final bool defaultOpen;
  final ValueChanged<bool>? onOpenChange;
  final bool dismissible;
  final String? semanticLabel;

  static MonoDialogScope? maybeOf(BuildContext context) =>
      MonoDialogScope.maybeOf(context);

  @override
  State<MonoDialog> createState() => _MonoDialogState();
}

class _MonoDialogState extends State<MonoDialog> {
  OverlayEntry? _entry;
  bool _uncontrolledOpen = false;
  bool _overlaySyncScheduled = false;
  MonokitThemeData? _overlayTheme;

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
    if (_entry != null) {
      _scheduleOverlaySync();
    }
  }

  @override
  void didUpdateWidget(covariant MonoDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleOverlaySync();
  }

  /// Dialog was the one modal outside this contract: it trapped focus but
  /// restored nothing on close, so dismissing it left focus wherever the tree
  /// happened to put it instead of back on the control that opened it.
  final MonoOverlayFocusController _overlayFocus = MonoOverlayFocusController();

  @override
  void dispose() {
    _overlayFocus.cancelRestore();
    _removeOverlayNow();
    super.dispose();
  }

  void _setOpen(bool value) {
    if (_isOpen == value) {
      return;
    }
    if (!_isControlled) {
      setState(() => _uncontrolledOpen = value);
    }
    if (!value) {
      _overlayFocus.requestRestoreOnClose();
    }
    widget.onOpenChange?.call(value);
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
    _overlayFocus.captureForOpen();
    _entry = OverlayEntry(builder: (overlayContext) => _buildOverlay());
    overlay.insert(_entry!);
  }

  Widget _buildOverlay() {
    final theme = _overlayTheme;
    if (theme == null) {
      return const SizedBox.shrink();
    }
    return _MonoDialogOverlay(
      theme: theme,
      visible: _overlayVisible,
      onExited: _onOverlayExited,
      semanticLabel: widget.semanticLabel,
      dismissible: widget.dismissible,
      onDismiss: () => _setOpen(false),
      child: widget.child,
    );
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
    _overlayFocus.restoreIfRequested(mounted: mounted);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trigger == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _setOpen(true),
      child: widget.trigger,
    );
  }
}

class _MonoDialogOverlay extends StatefulWidget {
  const _MonoDialogOverlay({
    required this.theme,
    required this.visible,
    required this.onExited,
    required this.child,
    required this.dismissible,
    required this.onDismiss,
    this.semanticLabel,
  });

  final MonokitThemeData theme;
  final bool visible;
  final VoidCallback onExited;
  final Widget child;
  final String? semanticLabel;
  final bool dismissible;
  final VoidCallback onDismiss;

  @override
  State<_MonoDialogOverlay> createState() => _MonoDialogOverlayState();
}

class _MonoDialogOverlayState extends State<_MonoDialogOverlay>
    with SingleTickerProviderStateMixin {
  /// Presence: 0 absent, 1 presented. Drives the scale (spatial, so a spring)
  /// and the scrim/surface opacity (appearance, read straight off the value).
  late final MonoSpringController _presence;
  bool _reportedExit = false;

  /// The dialog's own scope node.
  ///
  /// `MonoFocusTrap`'s autofocus alone is not enough: an [OverlayEntry] modal
  /// sits in a scope that already has a focused child whenever the page had
  /// one, and an autofocus is skipped in that case. Sheet and drawer have
  /// always requested focus explicitly for this reason; dialog did not, so it
  /// left focus on the page behind it — Esc handling and focus restoration both
  /// silently depended on the user having tabbed into the dialog first.
  late final FocusNode _focusNode;

  /// Read through the token rather than
  /// `platformDispatcher.accessibilityFeatures` — that route bypassed
  /// MediaQuery entirely, so it also ignored any test or host override.
  SpringDescription? _spring(BuildContext context) =>
      widget.theme.motion.reducedSpring(context, widget.theme.motion.spatial);

  @override
  void initState() {
    super.initState();
    _presence = MonoSpringController(vsync: this)..addListener(_onTick);
    _focusNode = FocusNode(debugLabel: 'MonoDialog');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.visible && _presence.value == 0 && !_presence.isAnimating) {
      _presence.animateTo(1, spring: _spring(context));
    }
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {});
    _maybeReportExit();
  }

  void _maybeReportExit() {
    if (_reportedExit || widget.visible) return;
    if (_presence.isAnimating || _presence.value > 0.001) return;
    _reportedExit = true;
    widget.onExited();
  }

  @override
  void didUpdateWidget(covariant _MonoDialogOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) _reportedExit = false;
      _presence.animateTo(widget.visible ? 1 : 0, spring: _spring(context));
      _maybeReportExit();
    }
  }

  @override
  void dispose() {
    _presence.removeListener(_onTick);
    _presence.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double presence = _presence.value;
    final double opacity = presence.clamp(0.0, 1.0);
    return MonokitTheme(
      data: widget.theme,
      child: MonoFocusTrap(
        autofocus: true,
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
            children: <Widget>[
              Opacity(
                opacity: opacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.dismissible ? widget.onDismiss : null,
                  child: ColoredBox(color: widget.theme.colors.scrim),
                ),
              ),
              // Lift the surface clear of the software keyboard and keep an
              // inset margin, so the dialog is height-capped to the visible
              // area instead of overflowing behind the keyboard.
              Padding(
                padding:
                    MediaQuery.viewInsetsOf(context) +
                    EdgeInsets.all(widget.theme.spacing.lg),
                child: Center(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      // Spring-driven, so a dialog dismissed while still
                      // arriving reverses from where it actually is.
                      scale: 0.96 + 0.04 * presence,
                      child: Semantics(
                        scopesRoute: true,
                        namesRoute: true,
                        explicitChildNodes: true,
                        label: widget.semanticLabel ?? 'Dialog',
                        child: MonoDialogScope(
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

/// Token-aware modal surface for a [MonoDialog] child.
class MonoDialogContent extends StatelessWidget {
  const MonoDialogContent({
    super.key,
    required this.child,
    this.padding,
    this.constraints = const BoxConstraints(maxWidth: 480),
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ConstrainedBox(
      constraints: constraints,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.popover,
          borderRadius: BorderRadius.circular(theme.radii.xxl),
          // No border: in the grouped model `elevated` already steps above the
          // card behind it, and the shadow carries the rest. The shadow colour
          // now tracks the theme instead of the hardcoded 0x2609090B, which was
          // a near-black over an already-dark ground in dark mode.
          boxShadow: theme.elevation.resolve(MonoElevation.floating),
        ),
        // Scrolls instead of overflowing when the dialog is taller than the
        // visible area (small screens, open keyboard, long content).
        child: SingleChildScrollView(
          child: Padding(
            padding: padding ?? EdgeInsets.all(theme.spacing.xxl),
            child: DefaultTextStyle(
              style: theme.typography.body.copyWith(
                color: theme.colors.foreground,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard title and description region for dialog content.
class MonoDialogHeader extends StatelessWidget {
  const MonoDialogHeader({super.key, this.title, this.description, this.child})
    : assert(child != null || title != null || description != null);

  final Widget? title;
  final Widget? description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
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
              style: theme.typography.titleLarge,
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

/// Standard trailing action region for dialog content.
class MonoDialogFooter extends StatelessWidget {
  const MonoDialogFooter({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.only(top: theme.spacing.xxl),
      child: child,
    );
  }
}

/// A declarative portal slot. It is intentionally transparent because
/// [MonoDialog] already renders its content in the application's overlay.
class MonoDialogPortal extends StatelessWidget {
  const MonoDialogPortal({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// An accessible close trigger for dialog content.
class MonoDialogClose extends StatelessWidget {
  const MonoDialogClose({super.key, required this.child, this.semanticLabel});

  final Widget child;

  /// Accessible name for the close control. Falls back to
  /// `MonokitTheme.of(context).labels.closeDialog` when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = MonoDialogScope.maybeOf(context);
    return MonoPressable(
      semanticLabel:
          semanticLabel ?? MonokitTheme.of(context).labels.closeDialog,
      onPressed: scope?.close,
      child: (context, states) => child,
    );
  }
}

/// A compact alert-dialog surface that can be placed inside [MonoDialog].
class MonoAlertDialog extends StatelessWidget {
  const MonoAlertDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions,
  });

  final Widget? title;
  final Widget? description;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return MonoDialogContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null || description != null)
            MonoDialogHeader(title: title, description: description),
          if (content != null) ...<Widget>[
            SizedBox(height: MonokitTheme.of(context).spacing.lg),
            content!,
          ],
          if (actions != null && actions!.isNotEmpty)
            MonoDialogFooter(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: MonokitTheme.of(context).spacing.sm,
                runSpacing: MonokitTheme.of(context).spacing.sm,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}
