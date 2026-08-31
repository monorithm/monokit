import 'dart:async';

import 'package:flutter/widgets.dart';

import '../primitives/mono_heading.dart';
import '../primitives/mono_overlay_layer.dart';
import '../primitives/mono_width_scope.dart';
import '../theme/monokit_layout.dart';
import '../theme/monokit_theme.dart';

enum MonoAlertVariant { defaultStyle, info, success, warning, destructive }

/// A compact inline status surface.
class MonoAlert extends StatelessWidget {
  const MonoAlert({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.action,
    this.child,
    this.variant = MonoAlertVariant.defaultStyle,
  }) : assert(child != null || title != null || description != null);

  final Widget? title;
  final Widget? description;
  final Widget? icon;
  final Widget? action;
  final Widget? child;
  final MonoAlertVariant variant;

  static Widget _measure({required bool capped, required Widget child}) {
    if (!capped) return child;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: MonokitContainers.content),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final (background, foreground, border) = switch (variant) {
      MonoAlertVariant.destructive => (
        theme.colors.destructiveSoft,
        theme.colors.destructiveText,
        theme.colors.destructive,
      ),
      MonoAlertVariant.success => (
        theme.colors.successSoft,
        theme.colors.successText,
        theme.colors.success,
      ),
      MonoAlertVariant.warning => (
        theme.colors.warningSoft,
        theme.colors.warningText,
        theme.colors.warning,
      ),
      MonoAlertVariant.info => (
        theme.colors.infoSoft,
        theme.colors.infoText,
        theme.colors.info,
      ),
      MonoAlertVariant.defaultStyle => (
        theme.colors.muted,
        theme.colors.foreground,
        theme.colors.border,
      ),
    };
    final content =
        child ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title != null)
              MonoHeading(
                DefaultTextStyle.merge(
                  style: theme.typography.labelLarge,
                  child: title!,
                ),
              ),
            if (title != null && description != null)
              SizedBox(height: theme.spacing.xs),
            if (description != null)
              DefaultTextStyle.merge(
                style: theme.typography.bodyMedium,
                child: description!,
              ),
          ],
        );
    // "At medium and up the alert caps at a text measure, never the window."
    // An alert is a sentence to read, and a sentence stretched to 1400px is
    // not more readable for the extra pixels — it is less. Unchanged by
    // density: this is a width decision, not a metric one.
    final bool capped = MonoWidthScope.of(
      context,
    ).atLeast(MonoWidthClass.medium);

    return Semantics(
      liveRegion:
          variant == MonoAlertVariant.destructive ||
          variant == MonoAlertVariant.warning,
      container: true,
      child: _measure(
        capped: capped,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radii.lg),
            border: Border.all(color: border),
          ),
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.md),
            child: DefaultTextStyle.merge(
              style: theme.typography.bodyMedium.copyWith(color: foreground),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ?icon,
                  if (icon != null) SizedBox(width: theme.spacing.sm),
                  Expanded(child: content),
                  if (action != null) SizedBox(width: theme.spacing.sm),
                  ?action,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A transient [MonoAlert] surface suitable for a [MonoScreen] overlay layer.
class MonoToast extends StatelessWidget {
  const MonoToast({
    super.key,
    this.message,
    this.child,
    this.variant = MonoAlertVariant.defaultStyle,
    this.action,
  }) : assert(message != null || child != null);

  final Widget? message;
  final Widget? child;
  final MonoAlertVariant variant;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return MonoAlert(
      variant: variant,
      description: message,
      action: action,
      child: child,
    );
  }
}

/// Convenience APIs for showing a token-aware toast in a [MonoScreen].
extension MonoOverlayToastController on MonoOverlayController {
  MonoOverlayHandle showToast(
    MonoToast toast, {
    Duration duration = const Duration(seconds: 4),
    AlignmentGeometry alignment = AlignmentDirectional.bottomCenter,
    EdgeInsetsGeometry margin = const EdgeInsets.all(16),
  }) {
    late MonoOverlayHandle handle;
    handle = showBuilder(
      (context) => Align(
        alignment: alignment,
        child: Padding(
          padding: margin,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: toast,
          ),
        ),
      ),
    );
    Timer(duration, handle.dismiss);
    return handle;
  }
}
