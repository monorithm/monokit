import 'package:flutter/widgets.dart';

import '../primitives/mono_heading.dart';
import '../theme/monokit_theme.dart';

/// A compact, token-aware top region for [MonoScreen].
class MonoScreenHeader extends StatelessWidget {
  const MonoScreenHeader({
    super.key,
    this.leading,
    this.title,
    this.trailing,
    this.padding,
    this.minHeight = 56,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(horizontal: theme.spacing.lg),
        child: Row(
          children: <Widget>[
            ?leading,
            if (leading != null) SizedBox(width: theme.spacing.sm),
            if (title != null)
              Expanded(
                child: MonoHeading(
                  DefaultTextStyle.merge(
                    style: theme.typography.titleLarge,
                    child: title!,
                  ),
                ),
              )
            else
              const Spacer(),
            if (trailing != null) SizedBox(width: theme.spacing.sm),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A compact, token-aware bottom region for [MonoScreen].
class MonoScreenFooter extends StatelessWidget {
  const MonoScreenFooter({
    super.key,
    required this.child,
    this.padding,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.page,
        border: showBorder
            ? Border(top: BorderSide(color: theme.colors.separator))
            : null,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing.md),
        child: child,
      ),
    );
  }
}

/// A simple token-aware canvas backdrop for immersive [MonoScreen]s.
class MonoBackdrop extends StatelessWidget {
  const MonoBackdrop.color(this.color, {super.key})
    : colors = null,
      begin = Alignment.topLeft,
      end = Alignment.bottomRight,
      stops = null;

  const MonoBackdrop.gradient({
    super.key,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.stops,
  }) : color = null;

  final Color? color;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<double>? stops;

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradientColors == null
            ? null
            : LinearGradient(
                colors: gradientColors,
                begin: begin,
                end: end,
                stops: stops,
              ),
      ),
    );
  }
}
