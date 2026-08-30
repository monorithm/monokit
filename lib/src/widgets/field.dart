import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Arrangement for a [MonoField]'s label and control.
enum MonoFieldLayout {
  /// The label is displayed above the control.
  vertical,

  /// The label is displayed beside the control.
  horizontal,

  /// Uses [horizontal] when the available width reaches the breakpoint.
  responsive,
}

/// A labelled form-control wrapper with description and error support.
///
/// `MonoField` intentionally accepts widgets for the textual slots so apps can
/// provide rich labels or localized content. It does not impose a Material
/// `FormField`, keeping the core package widgets-only.
class MonoField extends StatelessWidget {
  const MonoField({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.error,
    this.layout = MonoFieldLayout.vertical,
    this.required = false,
    this.enabled = true,
    this.labelWidth = 144,
    this.responsiveBreakpoint = 600,
    this.spacing,
    this.focusNode,
  }) : assert(labelWidth >= 0),
       assert(responsiveBreakpoint >= 0);

  final Widget child;
  final Widget? label;
  final Widget? description;
  final Widget? error;
  final MonoFieldLayout layout;
  final bool required;
  final bool enabled;
  final double labelWidth;
  final double responsiveBreakpoint;
  final double? spacing;

  /// The [FocusNode] of the control in [child], forwarded to [MonoFieldLabel]
  /// so tapping the label focuses the field. Pass the same node you gave the
  /// control; omit it and the label stays presentation-only, as before.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final double gap = spacing ?? theme.spacing.sm;

    final Widget labelWidget = label == null
        ? const SizedBox.shrink()
        : MonoFieldLabel(
            required: required,
            enabled: enabled,
            focusNode: focusNode,
            child: label!,
          );
    final List<Widget> supporting = <Widget>[
      if (description != null)
        MonoFieldDescription(enabled: enabled, child: description!),
      if (error != null) MonoFieldError(child: error!),
    ];

    Widget buildVertical() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (label != null) ...<Widget>[labelWidget, SizedBox(height: gap)],
          Opacity(opacity: enabled ? 1 : 0.55, child: child),
          if (supporting.isNotEmpty) ...<Widget>[
            SizedBox(height: theme.spacing.xs),
            ..._spaceVertically(supporting, theme.spacing.xs),
          ],
        ],
      );
    }

    Widget buildHorizontal() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (label != null) ...<Widget>[
            SizedBox(
              width: labelWidth,
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: labelWidget,
              ),
            ),
            SizedBox(width: gap),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Opacity(opacity: enabled ? 1 : 0.55, child: child),
                if (supporting.isNotEmpty) ...<Widget>[
                  SizedBox(height: theme.spacing.xs),
                  ..._spaceVertically(supporting, theme.spacing.xs),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      enabled: enabled,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useHorizontal =
              layout == MonoFieldLayout.horizontal ||
              (layout == MonoFieldLayout.responsive &&
                  constraints.maxWidth >= responsiveBreakpoint);
          return useHorizontal ? buildHorizontal() : buildVertical();
        },
      ),
    );
  }
}

/// Styled label slot for [MonoField] and [MonoFieldSet].
class MonoFieldLabel extends StatelessWidget {
  const MonoFieldLabel({
    super.key,
    required this.child,
    this.required = false,
    this.enabled = true,
    this.focusNode,
  });

  final Widget child;
  final bool required;
  final bool enabled;

  /// The control this label names — the equivalent of the web's `label for`.
  ///
  /// Supply the same [FocusNode] you passed to the control and the label
  /// becomes part of its hit target: tapping the text focuses the field, and
  /// assistive technology gets a tap action on the label instead of a dead
  /// run of text sitting next to an unrelated control.
  final FocusNode? focusNode;

  void _focusField() {
    final node = focusNode;
    if (!enabled || node == null || !node.canRequestFocus) {
      return;
    }
    node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final bool associated = focusNode != null;
    Widget label = Semantics(
      container: true,
      onTap: associated && enabled ? _focusField : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: child),
          if (required)
            Semantics(
              label: 'required',
              child: ExcludeSemantics(
                child: Text(
                  ' *',
                  style: theme.typography.labelLarge.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (associated) {
      label = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusField,
        // Joining the field's tap region keeps a label tap from reading as a
        // tap *outside* the field it names, which would fight the focus
        // request by dismissing the keyboard in the same gesture.
        child: TextFieldTapRegion(child: label),
      );
    }
    return DefaultTextStyle.merge(
      style: theme.typography.labelLarge.copyWith(
        color: enabled ? theme.colors.foreground : theme.colors.mutedForeground,
      ),
      child: label,
    );
  }
}

/// Muted supporting text for a [MonoField].
class MonoFieldDescription extends StatelessWidget {
  const MonoFieldDescription({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.bodyMedium.copyWith(
        color: enabled
            ? theme.colors.mutedForeground
            : theme.colors.mutedForeground.withAlpha(150),
      ),
      child: child,
    );
  }
}

/// Destructive, live-region supporting text for a [MonoField].
class MonoFieldError extends StatelessWidget {
  const MonoFieldError({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.bodyMedium.copyWith(
          color: theme.colors.destructive,
        ),
        child: child,
      ),
    );
  }
}

/// A group of related fields, commonly used for compact form sections.
class MonoFieldGroup extends StatelessWidget {
  const MonoFieldGroup({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final Axis direction;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final double gap = spacing ?? theme.spacing.lg;
    if (direction == Axis.horizontal) {
      return Row(
        crossAxisAlignment: crossAxisAlignment,
        children: _spaceHorizontally(children, gap),
      );
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: _spaceVertically(children, gap),
    );
  }
}

/// A semantic fieldset-style surface for related [MonoField] widgets.
class MonoFieldSet extends StatelessWidget {
  const MonoFieldSet({
    super.key,
    required this.child,
    this.legend,
    this.padding,
  });

  final Widget child;
  final Widget? legend;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(theme.radii.md),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (legend != null) ...<Widget>[
                MonoFieldLegend(child: legend!),
                SizedBox(height: theme.spacing.md),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A title-like legend for [MonoFieldSet].
class MonoFieldLegend extends StatelessWidget {
  const MonoFieldLegend({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      header: true,
      child: DefaultTextStyle.merge(
        style: theme.typography.titleMedium.copyWith(
          color: theme.colors.foreground,
        ),
        child: child,
      ),
    );
  }
}

/// A token-driven separator for field groups, optionally with a label.
class MonoFieldSeparator extends StatelessWidget {
  const MonoFieldSeparator({super.key, this.label, this.padding});

  final Widget? label;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final EdgeInsetsGeometry resolvedPadding =
        padding ?? EdgeInsets.symmetric(vertical: theme.spacing.md);
    if (label == null) {
      return Padding(
        padding: resolvedPadding,
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colors.border),
          child: const SizedBox(height: 1),
        ),
      );
    }

    Widget divider() {
      return DecoratedBox(
        decoration: BoxDecoration(color: theme.colors.border),
        child: const SizedBox(height: 1),
      );
    }

    Widget labelContent() {
      return DefaultTextStyle.merge(
        style: theme.typography.labelMedium.copyWith(
          color: theme.colors.mutedForeground,
        ),
        child: label!,
      );
    }

    return Padding(
      padding: resolvedPadding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // A divider label is arbitrary widget content. On narrow screens,
          // stacking it between the rules preserves every character instead
          // of allowing an unbreakable child to overflow the row.
          if (constraints.maxWidth < 280) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
                  child: labelContent(),
                ),
                divider(),
              ],
            );
          }
          return Row(
            children: <Widget>[
              Expanded(child: divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm),
                child: labelContent(),
              ),
              Expanded(child: divider()),
            ],
          );
        },
      ),
    );
  }
}

List<Widget> _spaceVertically(List<Widget> children, double spacing) {
  if (children.length < 2) {
    return children;
  }
  final List<Widget> result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    if (index > 0) {
      result.add(SizedBox(height: spacing));
    }
    result.add(children[index]);
  }
  return result;
}

List<Widget> _spaceHorizontally(List<Widget> children, double spacing) {
  if (children.length < 2) {
    return children;
  }
  final List<Widget> result = <Widget>[];
  for (var index = 0; index < children.length; index++) {
    if (index > 0) {
      result.add(SizedBox(width: spacing));
    }
    result.add(children[index]);
  }
  return result;
}
