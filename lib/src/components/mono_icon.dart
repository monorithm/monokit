import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/monokit_theme.dart';

/// A portable icon descriptor used by [MonoIcon].
///
/// Monokit re-exports the **HugeIcons** stroke-rounded set (the canonical
/// vendor) under semantic names, so product code references intent
/// ([MonoIcons.like]) rather than a raw vendor constant. Apps can also supply
/// any HugeIcons constant directly via [MonoIconData.new].
@immutable
class MonoIconData {
  const MonoIconData(this.data, {this.semanticLabel});

  /// The HugeIcons path data (e.g. `HugeIcons.strokeRoundedSearch01`).
  final List<List<dynamic>> data;
  final String? semanticLabel;
}

/// A compact, semantic icon catalog mapped onto the HugeIcons stroke-rounded
/// set. Names describe role, not glyph, so a vendor swap never touches call
/// sites.
abstract final class MonoIcons {
  static const MonoIconData add =
      MonoIconData(HugeIcons.strokeRoundedAdd01, semanticLabel: 'Add');
  static const MonoIconData close =
      MonoIconData(HugeIcons.strokeRoundedCancel01, semanticLabel: 'Close');
  static const MonoIconData check =
      MonoIconData(HugeIcons.strokeRoundedTick02, semanticLabel: 'Selected');
  static const MonoIconData chevronDown = MonoIconData(
    HugeIcons.strokeRoundedArrowDown01,
    semanticLabel: 'Expand',
  );
  static const MonoIconData chevronUp = MonoIconData(
    HugeIcons.strokeRoundedArrowUp01,
    semanticLabel: 'Collapse',
  );
  static const MonoIconData chevronLeft = MonoIconData(
    HugeIcons.strokeRoundedArrowLeft01,
    semanticLabel: 'Previous',
  );
  static const MonoIconData chevronRight = MonoIconData(
    HugeIcons.strokeRoundedArrowRight01,
    semanticLabel: 'Next',
  );
  static const MonoIconData arrowRight = MonoIconData(
    HugeIcons.strokeRoundedArrowRight01,
    semanticLabel: 'Continue',
  );
  static const MonoIconData menu =
      MonoIconData(HugeIcons.strokeRoundedMenu01, semanticLabel: 'Menu');
  static const MonoIconData more = MonoIconData(
    HugeIcons.strokeRoundedMoreHorizontal,
    semanticLabel: 'More options',
  );
  static const MonoIconData sparkles =
      MonoIconData(HugeIcons.strokeRoundedAiMagic, semanticLabel: 'Sparkles');
  static const MonoIconData search =
      MonoIconData(HugeIcons.strokeRoundedSearch01, semanticLabel: 'Search');
  static const MonoIconData send =
      MonoIconData(HugeIcons.strokeRoundedSent, semanticLabel: 'Send');
  static const MonoIconData play =
      MonoIconData(HugeIcons.strokeRoundedPlay, semanticLabel: 'Play');
  static const MonoIconData pause =
      MonoIconData(HugeIcons.strokeRoundedPause, semanticLabel: 'Pause');
  static const MonoIconData bag = MonoIconData(
    HugeIcons.strokeRoundedShoppingBag01,
    semanticLabel: 'Shop',
  );
  static const MonoIconData receipt =
      MonoIconData(HugeIcons.strokeRoundedInvoice01, semanticLabel: 'Orders');
  static const MonoIconData grid = MonoIconData(
    HugeIcons.strokeRoundedDashboardSquare01,
    semanticLabel: 'Workspace',
  );
  static const MonoIconData video =
      MonoIconData(HugeIcons.strokeRoundedVideo01, semanticLabel: 'Live video');
  static const MonoIconData message =
      MonoIconData(HugeIcons.strokeRoundedMessage01, semanticLabel: 'Messages');
  static const MonoIconData call =
      MonoIconData(HugeIcons.strokeRoundedCall, semanticLabel: 'Call');
  static const MonoIconData like =
      MonoIconData(HugeIcons.strokeRoundedFavourite, semanticLabel: 'Like');
  static const MonoIconData location = MonoIconData(
    HugeIcons.strokeRoundedLocation01,
    semanticLabel: 'Location',
  );
  static const MonoIconData filter = MonoIconData(
    HugeIcons.strokeRoundedFilterHorizontal,
    semanticLabel: 'Filter',
  );
  static const MonoIconData mic =
      MonoIconData(HugeIcons.strokeRoundedMic01, semanticLabel: 'Voice note');
  static const MonoIconData image =
      MonoIconData(HugeIcons.strokeRoundedImage01, semanticLabel: 'Photo');
  static const MonoIconData star =
      MonoIconData(HugeIcons.strokeRoundedStar, semanticLabel: 'Featured');
  static const MonoIconData bookmark =
      MonoIconData(HugeIcons.strokeRoundedBookmark01, semanticLabel: 'Save');
  static const MonoIconData mute =
      MonoIconData(HugeIcons.strokeRoundedVolumeMute01, semanticLabel: 'Mute');
  static const MonoIconData clock =
      MonoIconData(HugeIcons.strokeRoundedClock01, semanticLabel: 'Time');
  static const MonoIconData document = MonoIconData(
    HugeIcons.strokeRoundedFile01,
    semanticLabel: 'Document',
  );
  static const MonoIconData link =
      MonoIconData(HugeIcons.strokeRoundedLink01, semanticLabel: 'Link');
  static const MonoIconData download = MonoIconData(
    HugeIcons.strokeRoundedDownload01,
    semanticLabel: 'Download',
  );
}

/// A token-aware vector icon.
///
/// Renders a HugeIcons stroke-rounded glyph at the given [size], defaulting to
/// the theme foreground [color]. Stroke weight follows the design language
/// (1.5 resting).
class MonoIcon extends StatelessWidget {
  const MonoIcon(
    this.icon, {
    super.key,
    this.size = 16,
    this.color,
    this.strokeWidth = 1.5,
    this.semanticLabel,
  });

  final MonoIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final label = semanticLabel ?? icon.semanticLabel;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: HugeIcon(
        icon: icon.data,
        size: size,
        color: color ?? theme.colors.foreground,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
