import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';

/// A semantic breadcrumb navigation region with composable item slots.
class MonoBreadcrumb extends StatelessWidget {
  const MonoBreadcrumb({
    super.key,
    required this.children,
    this.separator,
    this.padding,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.semanticLabel = 'Breadcrumbs',
  });

  final List<Widget> children;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final WrapAlignment alignment;
  final WrapAlignment runAlignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final items = <Widget>[
      for (var index = 0; index < children.length; index++) ...<Widget>[
        children[index],
        if (index != children.length - 1)
          separator ?? const MonoBreadcrumbSeparator(),
      ],
    ];
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Wrap(
          spacing: theme.spacing.sm,
          runSpacing: theme.spacing.xs,
          alignment: alignment,
          runAlignment: runAlignment,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: items,
        ),
      ),
    );
  }
}

/// A structural breadcrumb item wrapper.
class MonoBreadcrumbItem extends StatelessWidget {
  const MonoBreadcrumbItem({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// An interactive breadcrumb segment with hover, focus, and keyboard support.
class MonoBreadcrumbLink extends StatelessWidget {
  const MonoBreadcrumbLink({
    super.key,
    required this.child,
    this.onPressed,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    Widget visual(Set<MonoState> states) {
      final highlighted =
          states.contains(MonoState.hovered) ||
          states.contains(MonoState.focused);
      return DefaultTextStyle.merge(
        style: theme.typography.labelMedium.copyWith(
          color: highlighted
              ? theme.colors.foreground
              : theme.colors.foregroundMuted,
          decoration: highlighted
              ? TextDecoration.underline
              : TextDecoration.none,
        ),
        child: child,
      );
    }

    if (onPressed == null || !enabled) {
      return Semantics(
        link: onPressed != null,
        enabled: enabled && onPressed != null,
        label: semanticLabel,
        child: visual(const <MonoState>{}),
      );
    }
    return MonoPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      child: (context, states) => visual(states),
    );
  }
}

/// The current, non-interactive breadcrumb segment.
class MonoBreadcrumbPage extends StatelessWidget {
  const MonoBreadcrumbPage({
    super.key,
    required this.child,
    this.semanticLabel,
  });

  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      selected: true,
      label: semanticLabel,
      child: DefaultTextStyle.merge(
        style: theme.typography.labelMedium.copyWith(
          color: theme.colors.foreground,
        ),
        child: child,
      ),
    );
  }
}

/// A decorative separator between breadcrumb items.
class MonoBreadcrumbSeparator extends StatelessWidget {
  const MonoBreadcrumbSeparator({super.key, this.child, this.semanticLabel});

  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final separator = DefaultTextStyle.merge(
      style: theme.typography.labelMedium.copyWith(
        color: theme.colors.foregroundMuted,
      ),
      child: child ?? const Text('/'),
    );
    if (semanticLabel == null) {
      return ExcludeSemantics(child: separator);
    }
    return Semantics(label: semanticLabel, child: separator);
  }
}

/// An overflow marker for collapsed breadcrumb paths.
class MonoBreadcrumbEllipsis extends StatelessWidget {
  const MonoBreadcrumbEllipsis({
    super.key,
    this.child,
    this.semanticLabel = 'More breadcrumb items',
  });

  final Widget? child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.foregroundMuted,
          ),
          child: child ?? const Text('…'),
        ),
      ),
    );
  }
}
