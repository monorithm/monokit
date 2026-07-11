import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
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

  @override
  void dispose() {
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
        _removeOverlayNow();
      }
    });
  }

  void _showOrRefreshOverlay() {
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
    if (overlay == null) {
      return;
    }
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
      semanticLabel: widget.semanticLabel,
      dismissible: widget.dismissible,
      onDismiss: () => _setOpen(false),
      child: widget.child,
    );
  }

  void _removeOverlayNow() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
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
    required this.child,
    required this.dismissible,
    required this.onDismiss,
    this.semanticLabel,
  });

  final MonokitThemeData theme;
  final Widget child;
  final String? semanticLabel;
  final bool dismissible;
  final VoidCallback onDismiss;

  @override
  State<_MonoDialogOverlay> createState() => _MonoDialogOverlayState();
}

class _MonoDialogOverlayState extends State<_MonoDialogOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.theme.motion.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = CurvedAnimation(
      parent: _controller,
      curve: widget.theme.motion.curve,
    );
    return MonokitTheme(
      data: widget.theme,
      child: FocusScope(
        autofocus: true,
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
            children: <Widget>[
              FadeTransition(
                opacity: opacity,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.dismissible ? widget.onDismiss : null,
                  child: ColoredBox(color: const Color(0x9909090B)),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: opacity,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(opacity),
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
          borderRadius: BorderRadius.circular(theme.radii.xl),
          border: Border.all(color: theme.colors.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0x2609090B),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing.xxl),
          child: DefaultTextStyle(
            style: theme.typography.body.copyWith(
              color: theme.colors.popoverForeground,
            ),
            child: child,
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
          DefaultTextStyle.merge(
            style: theme.typography.titleLarge,
            child: title!,
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
  const MonoDialogClose({
    super.key,
    required this.child,
    this.semanticLabel = 'Close dialog',
  });

  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = MonoDialogScope.maybeOf(context);
    return MonoPressable(
      semanticLabel: semanticLabel,
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
