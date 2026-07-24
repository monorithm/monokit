import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Density options for keyboard shortcut labels.
enum MonoKbdSize { sm, md, lg }

/// A compact keyboard-key or keyboard-shortcut label.
class MonoKbd extends StatelessWidget {
  const MonoKbd({
    super.key,
    required this.child,
    this.size = MonoKbdSize.md,
    this.semanticLabel,
  });

  /// Creates a keyboard label from plain text.
  factory MonoKbd.text(
    String text, {
    Key? key,
    MonoKbdSize size = MonoKbdSize.md,
    String? semanticLabel,
  }) {
    return MonoKbd(
      key: key,
      size: size,
      semanticLabel: semanticLabel,
      child: Text(text),
    );
  }

  final Widget child;
  final MonoKbdSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final (
      EdgeInsets padding,
      double minimumHeight,
      TextStyle textStyle,
    ) = switch (size) {
      MonoKbdSize.sm => (
        EdgeInsets.symmetric(horizontal: theme.spacing.xs),
        theme.spacing.xl,
        theme.typography.labelMedium,
      ),
      MonoKbdSize.md => (
        EdgeInsets.symmetric(
          horizontal: theme.spacing.sm,
          vertical: theme.spacing.xs / 2,
        ),
        theme.spacing.xxl,
        theme.typography.labelMedium,
      ),
      MonoKbdSize.lg => (
        EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.xs,
        ),
        theme.spacing.xxl + theme.spacing.xs,
        theme.typography.labelLarge,
      ),
    };

    final kbd = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minimumHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(theme.radii.sm),
          border: Border.all(color: theme.colors.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: theme.colors.foreground.withValues(alpha: 0.08),
              offset: Offset(0, theme.spacing.xs / 4),
              blurRadius: theme.spacing.xs / 2,
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: Center(
            child: DefaultTextStyle.merge(
              style: textStyle.copyWith(color: theme.colors.foreground),
              child: child,
            ),
          ),
        ),
      ),
    );

    return Semantics(container: true, label: semanticLabel, child: kbd);
  }
}
