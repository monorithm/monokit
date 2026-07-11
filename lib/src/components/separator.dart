import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// The axis on which [MonoSeparator] draws its token border.
enum MonoSeparatorOrientation { horizontal, vertical }

/// A quiet visual divider for grouping related content.
class MonoSeparator extends StatelessWidget {
  const MonoSeparator({
    super.key,
    this.orientation = MonoSeparatorOrientation.horizontal,
    this.thickness,
    this.color,
    this.length,
    this.indent = 0,
    this.endIndent = 0,
    this.semanticLabel,
  });

  final MonoSeparatorOrientation orientation;
  final double? thickness;
  final Color? color;

  /// Constrains the divider along its main axis when supplied.
  final double? length;
  final double indent;
  final double endIndent;

  /// Adds semantic meaning when this divider represents a named boundary.
  /// Decorative separators are excluded from the semantics tree by default.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedThickness = thickness ?? theme.spacing.xs / 4;
    final line = DecoratedBox(
      decoration: BoxDecoration(color: color ?? theme.colors.border),
    );

    final separator = switch (orientation) {
      MonoSeparatorOrientation.horizontal => Padding(
        padding: EdgeInsetsDirectional.only(start: indent, end: endIndent),
        child: SizedBox(height: resolvedThickness, width: length, child: line),
      ),
      MonoSeparatorOrientation.vertical => Padding(
        padding: EdgeInsetsDirectional.only(top: indent, bottom: endIndent),
        child: SizedBox(width: resolvedThickness, height: length, child: line),
      ),
    };

    if (semanticLabel == null) {
      return ExcludeSemantics(child: separator);
    }
    return Semantics(label: semanticLabel, child: separator);
  }
}
