import 'dart:async';

import 'package:flutter/widgets.dart';

import '../primitives/mono_overlay_layer.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final (background, foreground, border) = switch (variant) {
      MonoAlertVariant.destructive => (
        theme.colors.destructive.withValues(alpha: 0.12),
        theme.colors.destructive,
        theme.colors.destructive.withValues(alpha: 0.35),
      ),
      MonoAlertVariant.success => (
        theme.colors.primary.withValues(alpha: 0.1),
        theme.colors.foreground,
        theme.colors.border,
      ),
      MonoAlertVariant.warning => (
        theme.colors.accent,
        theme.colors.accentForeground,
        theme.colors.border,
      ),
      MonoAlertVariant.info => (
        theme.colors.secondary,
        theme.colors.secondaryForeground,
        theme.colors.border,
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
              DefaultTextStyle.merge(
                style: theme.typography.labelLarge,
                child: title!,
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
    return Semantics(
      liveRegion: variant == MonoAlertVariant.destructive,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(theme.radii.md),
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
