import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// A portable glyph descriptor used by [MonoIcon].
///
/// Monokit does not bundle a Material or icon-font dependency. The default set
/// therefore uses well-supported Unicode symbols; apps can also supply their
/// own glyph through [MonoIconData].
@immutable
class MonoIconData {
  const MonoIconData(this.glyph, {this.semanticLabel});

  final String glyph;
  final String? semanticLabel;
}

/// A small dependency-free icon catalog for common Monokit affordances.
abstract final class MonoIcons {
  static const MonoIconData add = MonoIconData('+', semanticLabel: 'Add');
  static const MonoIconData close = MonoIconData('×', semanticLabel: 'Close');
  static const MonoIconData check = MonoIconData(
    '✓',
    semanticLabel: 'Selected',
  );
  static const MonoIconData chevronDown = MonoIconData(
    '⌄',
    semanticLabel: 'Expand',
  );
  static const MonoIconData chevronUp = MonoIconData(
    '⌃',
    semanticLabel: 'Collapse',
  );
  static const MonoIconData chevronLeft = MonoIconData(
    '‹',
    semanticLabel: 'Previous',
  );
  static const MonoIconData chevronRight = MonoIconData(
    '›',
    semanticLabel: 'Next',
  );
  static const MonoIconData arrowRight = MonoIconData(
    '→',
    semanticLabel: 'Continue',
  );
  static const MonoIconData menu = MonoIconData('☰', semanticLabel: 'Menu');
  static const MonoIconData more = MonoIconData(
    '⋯',
    semanticLabel: 'More options',
  );
  static const MonoIconData sparkles = MonoIconData(
    '✦',
    semanticLabel: 'Sparkles',
  );
  static const MonoIconData search = MonoIconData('⌕', semanticLabel: 'Search');
  static const MonoIconData send = MonoIconData('↑', semanticLabel: 'Send');
}

/// A token-aware icon rendered without a platform-specific icon font.
class MonoIcon extends StatelessWidget {
  const MonoIcon(
    this.icon, {
    super.key,
    this.size = 16,
    this.color,
    this.semanticLabel,
  });

  final MonoIconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Semantics(
      label: semanticLabel ?? icon.semanticLabel,
      child: ExcludeSemantics(
        child: Text(
          icon.glyph,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color ?? theme.colors.foreground,
            fontSize: size,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
