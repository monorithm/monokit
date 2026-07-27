import 'package:flutter/widgets.dart';

import '../app/mono_screen.dart';
import '../primitives/mono_pressable.dart';
import '../theme/monokit_theme.dart';

/// State exposed by [MonoSidebar] to its descendants.
class MonoSidebarScope extends InheritedWidget {
  const MonoSidebarScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final MonoSidebarController controller;

  static MonoSidebarScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoSidebarScope>();
  }

  @override
  bool updateShouldNotify(MonoSidebarScope oldWidget) =>
      controller != oldWidget.controller;
}

/// Responsive side-navigation surface designed to be hosted by [MonoScreen].
class MonoSidebar extends StatelessWidget {
  const MonoSidebar({
    super.key,
    this.controller,
    this.header,
    this.footer,
    this.child,
    this.padding,
  });

  final MonoSidebarController? controller;
  final Widget? header;
  final Widget? footer;
  final Widget? child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final screenScope = MonoScreen.maybeOf(context);
    final effectiveController = controller ?? screenScope?.sidebarController;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.sidebar,
        border: BorderDirectional(
          end: BorderSide(color: theme.colors.sidebarBorder),
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ?header,
            if (header != null) SizedBox(height: theme.spacing.md),
            Expanded(child: child ?? const SizedBox.shrink()),
            if (footer != null) SizedBox(height: theme.spacing.md),
            ?footer,
          ],
        ),
      ),
    );
    if (effectiveController == null) {
      return content;
    }
    return MonoSidebarScope(controller: effectiveController, child: content);
  }
}

/// An accessible trigger for opening or closing a [MonoSidebarController].
class MonoSidebarTrigger extends StatelessWidget {
  const MonoSidebarTrigger({
    super.key,
    this.controller,
    required this.child,
    this.semanticLabel = 'Toggle navigation',
  });

  final MonoSidebarController? controller;
  final Widget child;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveController =
        controller ??
        MonoSidebarScope.maybeOf(context)?.controller ??
        MonoScreen.maybeOf(context)?.sidebarController;
    Widget buildTrigger(bool? expanded) {
      return MonoPressable(
        semanticLabel: semanticLabel,
        expanded: expanded,
        onPressed: effectiveController?.toggle,
        child: (context, states) => child,
      );
    }

    if (effectiveController == null) {
      return buildTrigger(null);
    }
    return ListenableBuilder(
      listenable: effectiveController,
      builder: (context, child) => buildTrigger(effectiveController.isOpen),
    );
  }
}
