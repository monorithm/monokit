import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'message.dart';

/// Visual treatments available to a [MonoBubble].
///
/// Dart reserves `default`, so [default_] is the default-treatment spelling.
enum MonoBubbleVariant {
  default_,
  primary,
  secondary,
  muted,
  tinted,
  outline,
  ghost,
  destructive;

  /// Readable alias for [default_] when an API cannot use a trailing
  /// underscore in its own defaults.
  static const MonoBubbleVariant defaultVariant = default_;
}

/// Alias for consumers that prefer a bubble-specific alignment name.
typedef MonoBubbleAlign = MonoMessageAlign;

/// Alias for consumers that prefer the longer alignment name.
typedef MonoBubbleAlignment = MonoMessageAlign;

/// The immutable visual result of resolving a [MonoBubble] variant.
@immutable
class MonoResolvedBubbleStyle {
  const MonoResolvedBubbleStyle({
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.borderRadius,
  });

  final Color background;
  final Color foreground;
  final Color? borderColor;
  final BorderRadius borderRadius;
}

/// Resolves bubble variants from semantic Monokit tokens.
class MonoBubbleStyleResolver {
  const MonoBubbleStyleResolver();

  MonoResolvedBubbleStyle resolve({
    required MonokitThemeData theme,
    required MonoBubbleVariant variant,
  }) {
    final colors = theme.colors;
    final (
      Color background,
      Color foreground,
      Color? borderColor,
    ) = switch (variant) {
      MonoBubbleVariant.default_ => (
        colors.card,
        colors.cardForeground,
        colors.border,
      ),
      MonoBubbleVariant.primary => (
        colors.primary,
        colors.primaryForeground,
        null,
      ),
      MonoBubbleVariant.secondary => (
        colors.secondary,
        colors.secondaryForeground,
        null,
      ),
      MonoBubbleVariant.muted => (colors.muted, colors.foreground, null),
      MonoBubbleVariant.tinted => (
        colors.accent,
        colors.accentForeground,
        null,
      ),
      MonoBubbleVariant.outline => (
        colors.background.withValues(alpha: 0),
        colors.foreground,
        colors.border,
      ),
      MonoBubbleVariant.ghost => (
        colors.background.withValues(alpha: 0),
        colors.foreground,
        null,
      ),
      MonoBubbleVariant.destructive => (
        colors.destructive,
        colors.primary,
        null,
      ),
    };
    return MonoResolvedBubbleStyle(
      background: background,
      foreground: foreground,
      borderColor: borderColor,
      borderRadius: BorderRadius.circular(theme.radii.lg),
    );
  }
}

/// A token-driven chat bubble with optional reaction content.
class MonoBubble extends StatelessWidget {
  const MonoBubble({
    super.key,
    required this.child,
    this.variant = MonoBubbleVariant.default_,
    this.align,
    this.padding,
    this.maxWidth,
    this.reactions,
    this.semanticLabel,
  }) : assert(maxWidth == null || maxWidth > 0);

  final Widget child;
  final MonoBubbleVariant variant;

  /// When omitted, uses the surrounding [MonoMessage]'s alignment.
  final MonoMessageAlign? align;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final Widget? reactions;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedAlign =
        align ??
        MonoMessageScope.maybeOf(context)?.align ??
        MonoMessageAlign.start;
    final style = const MonoBubbleStyleResolver().resolve(
      theme: theme,
      variant: variant,
    );
    final surface = Semantics(
      container: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: style.borderRadius,
          border: style.borderColor == null
              ? null
              : Border.all(color: style.borderColor!),
        ),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: theme.spacing.lg,
                vertical: theme.spacing.md,
              ),
          child: DefaultTextStyle.merge(
            style: theme.typography.bodyMedium.copyWith(
              color: style.foreground,
            ),
            child: child,
          ),
        ),
      ),
    );
    final bubble = ConstrainedBox(
      constraints: maxWidth == null
          ? const BoxConstraints()
          : BoxConstraints(maxWidth: maxWidth!),
      child: surface,
    );
    final contents = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: resolvedAlign == MonoMessageAlign.end
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        bubble,
        if (reactions != null) SizedBox(height: theme.spacing.xs),
        ?reactions,
      ],
    );

    return Align(
      alignment: resolvedAlign == MonoMessageAlign.end
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: contents,
    );
  }
}

/// A semantic content slot for [MonoBubble].
class MonoBubbleContent extends StatelessWidget {
  const MonoBubbleContent({
    super.key,
    required this.child,
    this.padding,
    this.textAlign,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final align =
        MonoMessageScope.maybeOf(context)?.align ?? MonoMessageAlign.start;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DefaultTextStyle.merge(
        textAlign:
            textAlign ??
            (align == MonoMessageAlign.end ? TextAlign.end : TextAlign.start),
        child: child,
      ),
    );
  }
}

/// A wrapping row of [MonoBubbleReaction] controls.
class MonoBubbleReactions extends StatelessWidget {
  const MonoBubbleReactions({
    super.key,
    required this.children,
    this.align,
    this.spacing,
    this.runSpacing,
    this.padding,
    this.semanticLabel = 'Message reactions',
  });

  final List<Widget> children;
  final MonoMessageAlign? align;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedAlign =
        align ??
        MonoMessageScope.maybeOf(context)?.align ??
        MonoMessageAlign.start;
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Wrap(
          spacing: spacing ?? theme.spacing.xs,
          runSpacing: runSpacing ?? theme.spacing.xs,
          alignment: resolvedAlign == MonoMessageAlign.end
              ? WrapAlignment.end
              : WrapAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

/// A compact, accessible emoji/count reaction control.
class MonoBubbleReaction extends StatelessWidget {
  const MonoBubbleReaction({
    super.key,
    this.emoji,
    this.count,
    this.child,
    this.selected = false,
    this.onPressed,
    this.statesController,
    this.semanticLabel,
  }) : assert(emoji != null || child != null, 'Provide emoji or child.'),
       assert(count == null || count >= 0);

  final String? emoji;
  final int? count;
  final Widget? child;
  final bool selected;
  final VoidCallback? onPressed;
  final MonoStatesController? statesController;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    Widget buildVisual(Set<MonoState> states) {
      final isSelected = selected || states.contains(MonoState.selected);
      final isPressed = states.contains(MonoState.pressed);
      final isHovered = states.contains(MonoState.hovered);
      final background = isSelected
          ? theme.colors.accent
          : isPressed || isHovered
          ? theme.colors.muted
          : theme.colors.background;
      final borderColor = isSelected ? theme.colors.ring : theme.colors.border;
      return AnimatedContainer(
        duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
            ? Duration.zero
            : theme.motion.fast,
        curve: theme.motion.curve,
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.sm,
          vertical: theme.spacing.xs / 2,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(theme.radii.full),
          border: Border.all(color: borderColor),
        ),
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.foreground,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (emoji != null) Text(emoji!),
              if (emoji != null && (count != null || child != null))
                SizedBox(width: theme.spacing.xs),
              if (count != null) Text('$count'),
              if (count != null && child != null)
                SizedBox(width: theme.spacing.xs),
              ?child,
            ],
          ),
        ),
      );
    }

    final label =
        semanticLabel ??
        '${emoji ?? 'Reaction'}${count == null ? '' : ', $count'}';
    if (onPressed == null) {
      return Semantics(label: label, child: buildVisual(const <MonoState>{}));
    }
    return MonoPressable(
      onPressed: onPressed,
      statesController: statesController,
      semanticLabel: label,
      child: (context, states) => buildVisual(states),
    );
  }
}
