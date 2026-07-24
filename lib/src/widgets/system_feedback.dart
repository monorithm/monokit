import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';
import 'alert.dart';
import 'button.dart';

class MonoBanner extends StatelessWidget {
  const MonoBanner({
    super.key,
    required this.child,
    this.variant = MonoAlertVariant.info,
    this.action,
    this.onDismiss,
  });
  final Widget child;
  final MonoAlertVariant variant;
  final Widget? action;
  final VoidCallback? onDismiss;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion:
        variant == MonoAlertVariant.warning ||
        variant == MonoAlertVariant.destructive,
    child: MonoAlert(
      variant: variant,
      description: child,
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ?action,
          if (onDismiss != null)
            MonoButton(
              variant: MonoButtonVariant.ghost,
              size: MonoButtonSize.sm,
              onPressed: onDismiss,
              child: const Text('Dismiss'),
            ),
        ],
      ),
    ),
  );
}

class MonoEmptyState extends StatelessWidget {
  const MonoEmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
  });
  final Widget? icon;
  final Widget title;
  final Widget? description, action;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Semantics(
      container: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: EdgeInsets.all(t.spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ?icon,
                DefaultTextStyle.merge(
                  style: t.typography.titleLarge,
                  textAlign: TextAlign.center,
                  child: title,
                ),
                if (description != null) ...[
                  SizedBox(height: t.spacing.sm),
                  DefaultTextStyle.merge(
                    style: t.typography.bodyMedium.copyWith(
                      color: t.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                    child: description!,
                  ),
                ],
                if (action != null) ...[
                  SizedBox(height: t.spacing.lg),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MonokitToastController extends ChangeNotifier {
  final List<_ToastEntry> _entries = <_ToastEntry>[];
  List<MonoToast> get toasts =>
      List<MonoToast>.unmodifiable(_entries.map((e) => e.toast));

  void show(MonoToast toast, {Duration duration = const Duration(seconds: 4)}) {
    late _ToastEntry entry;
    entry = _ToastEntry(toast, Timer(duration, () => dismiss(toast)));
    _entries.add(entry);
    notifyListeners();
  }

  void dismiss(MonoToast toast) {
    final index = _entries.indexWhere((e) => identical(e.toast, toast));
    if (index < 0) return;
    _entries.removeAt(index).timer.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.timer.cancel();
    }
    _entries.clear();
    super.dispose();
  }
}

class _ToastEntry {
  _ToastEntry(this.toast, this.timer);
  final MonoToast toast;
  final Timer timer;
}

class MonokitToastHost extends StatefulWidget {
  const MonokitToastHost({
    super.key,
    required this.controller,
    required this.child,
    this.alignment = AlignmentDirectional.bottomCenter,
  });
  final MonokitToastController controller;
  final Widget child;
  final AlignmentGeometry alignment;
  @override
  State<MonokitToastHost> createState() => _MonokitToastHostState();
}

class _MonokitToastHostState extends State<MonokitToastHost> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(MonokitToastHost old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      widget.controller.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Stack(
      children: <Widget>[
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: widget.controller.toasts.isEmpty,
            child: Align(
              alignment: widget.alignment,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(t.spacing.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.controller.toasts
                          .map(
                            (toast) => Padding(
                              padding: EdgeInsets.only(top: t.spacing.sm),
                              child: toast,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
