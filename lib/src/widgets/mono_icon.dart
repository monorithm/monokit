import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/monokit_layout.dart';
import '../theme/monokit_theme.dart';
import 'tooltip.dart';

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
  static const MonoIconData add = MonoIconData(
    HugeIcons.strokeRoundedAdd01,
    semanticLabel: 'Add',
  );
  static const MonoIconData close = MonoIconData(
    HugeIcons.strokeRoundedCancel01,
    semanticLabel: 'Close',
  );
  static const MonoIconData check = MonoIconData(
    HugeIcons.strokeRoundedTick02,
    semanticLabel: 'Selected',
  );
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
  static const MonoIconData menu = MonoIconData(
    HugeIcons.strokeRoundedMenu01,
    semanticLabel: 'Menu',
  );
  static const MonoIconData more = MonoIconData(
    HugeIcons.strokeRoundedMoreHorizontal,
    semanticLabel: 'More options',
  );
  static const MonoIconData sparkles = MonoIconData(
    HugeIcons.strokeRoundedAiMagic,
    semanticLabel: 'Sparkles',
  );
  static const MonoIconData search = MonoIconData(
    HugeIcons.strokeRoundedSearch01,
    semanticLabel: 'Search',
  );
  static const MonoIconData send = MonoIconData(
    HugeIcons.strokeRoundedSent,
    semanticLabel: 'Send',
  );
  static const MonoIconData play = MonoIconData(
    HugeIcons.strokeRoundedPlay,
    semanticLabel: 'Play',
  );
  static const MonoIconData pause = MonoIconData(
    HugeIcons.strokeRoundedPause,
    semanticLabel: 'Pause',
  );
  static const MonoIconData bag = MonoIconData(
    HugeIcons.strokeRoundedShoppingBag01,
    semanticLabel: 'Shop',
  );
  static const MonoIconData receipt = MonoIconData(
    HugeIcons.strokeRoundedInvoice01,
    semanticLabel: 'Orders',
  );
  static const MonoIconData grid = MonoIconData(
    HugeIcons.strokeRoundedDashboardSquare01,
    semanticLabel: 'Workspace',
  );
  static const MonoIconData video = MonoIconData(
    HugeIcons.strokeRoundedVideo01,
    semanticLabel: 'Live video',
  );
  static const MonoIconData message = MonoIconData(
    HugeIcons.strokeRoundedMessage01,
    semanticLabel: 'Messages',
  );
  static const MonoIconData call = MonoIconData(
    HugeIcons.strokeRoundedCall,
    semanticLabel: 'Call',
  );
  static const MonoIconData user = MonoIconData(
    HugeIcons.strokeRoundedUser,
    semanticLabel: 'Account',
  );
  static const MonoIconData like = MonoIconData(
    HugeIcons.strokeRoundedFavourite,
    semanticLabel: 'Like',
  );
  static const MonoIconData location = MonoIconData(
    HugeIcons.strokeRoundedLocation01,
    semanticLabel: 'Location',
  );
  static const MonoIconData filter = MonoIconData(
    HugeIcons.strokeRoundedFilterHorizontal,
    semanticLabel: 'Filter',
  );
  static const MonoIconData mic = MonoIconData(
    HugeIcons.strokeRoundedMic01,
    semanticLabel: 'Voice note',
  );
  static const MonoIconData image = MonoIconData(
    HugeIcons.strokeRoundedImage01,
    semanticLabel: 'Photo',
  );
  static const MonoIconData star = MonoIconData(
    HugeIcons.strokeRoundedStar,
    semanticLabel: 'Featured',
  );
  static const MonoIconData bookmark = MonoIconData(
    HugeIcons.strokeRoundedBookmark01,
    semanticLabel: 'Save',
  );
  static const MonoIconData mute = MonoIconData(
    HugeIcons.strokeRoundedVolumeMute01,
    semanticLabel: 'Mute',
  );
  static const MonoIconData clock = MonoIconData(
    HugeIcons.strokeRoundedClock01,
    semanticLabel: 'Time',
  );
  static const MonoIconData document = MonoIconData(
    HugeIcons.strokeRoundedFile01,
    semanticLabel: 'Document',
  );
  static const MonoIconData link = MonoIconData(
    HugeIcons.strokeRoundedLink01,
    semanticLabel: 'Link',
  );
  static const MonoIconData download = MonoIconData(
    HugeIcons.strokeRoundedDownload01,
    semanticLabel: 'Download',
  );
  static const MonoIconData back = MonoIconData(
    HugeIcons.strokeRoundedArrowLeft01,
    semanticLabel: 'Back',
  );
  static const MonoIconData store = MonoIconData(
    HugeIcons.strokeRoundedStore01,
    semanticLabel: 'Shop',
  );
  static const MonoIconData camera = MonoIconData(
    HugeIcons.strokeRoundedCamera01,
    semanticLabel: 'Camera',
  );
  static const MonoIconData share = MonoIconData(
    HugeIcons.strokeRoundedShare01,
    semanticLabel: 'Share',
  );
  static const MonoIconData settings = MonoIconData(
    HugeIcons.strokeRoundedSettings01,
    semanticLabel: 'Settings',
  );
  static const MonoIconData notification = MonoIconData(
    HugeIcons.strokeRoundedNotification02,
    semanticLabel: 'Notifications',
  );
  static const MonoIconData edit = MonoIconData(
    HugeIcons.strokeRoundedEdit02,
    semanticLabel: 'Edit',
  );
  static const MonoIconData home = MonoIconData(
    HugeIcons.strokeRoundedHome01,
    semanticLabel: 'Home',
  );

  static const MonoIconData list = MonoIconData(
    HugeIcons.strokeRoundedLeftToRightListBullet,
    semanticLabel: 'List view',
  );
  static const MonoIconData shield = MonoIconData(
    HugeIcons.strokeRoundedShield01,
    semanticLabel: 'Verified',
  );
  static const MonoIconData trash = MonoIconData(
    HugeIcons.strokeRoundedDelete02,
    semanticLabel: 'Delete',
  );
  static const MonoIconData flag = MonoIconData(
    HugeIcons.strokeRoundedFlag02,
    semanticLabel: 'Report',
  );
  static const MonoIconData wifiOff = MonoIconData(
    HugeIcons.strokeRoundedWifiDisconnected01,
    semanticLabel: 'Offline',
  );
  static const MonoIconData eyeOff = MonoIconData(
    HugeIcons.strokeRoundedViewOff,
    semanticLabel: 'Hide',
  );
  static const MonoIconData zap = MonoIconData(
    HugeIcons.strokeRoundedFlash,
    semanticLabel: 'Activate',
  );
  static const MonoIconData phoneIncoming = MonoIconData(
    HugeIcons.strokeRoundedCallIncoming01,
    semanticLabel: 'Incoming call',
  );
  static const MonoIconData phoneOutgoing = MonoIconData(
    HugeIcons.strokeRoundedCallOutgoing01,
    semanticLabel: 'Outgoing call',
  );
  static const MonoIconData plus = MonoIconData(
    HugeIcons.strokeRoundedPlusSign,
    semanticLabel: 'Add',
  );
  static const MonoIconData refresh = MonoIconData(
    HugeIcons.strokeRoundedRefresh,
    semanticLabel: 'Retry',
  );
  static const MonoIconData crop = MonoIconData(
    HugeIcons.strokeRoundedCrop,
    semanticLabel: 'Crop',
  );
}

/// A token-aware vector icon.
///
/// Three things resolve themselves unless you override them, and each is a rule
/// of the design language rather than a default anyone should have to remember:
///
/// * **Size follows density.** 20 at touch, 16 at pointer. A finger is a
///   coarser instrument than a cursor, so a chrome icon it has to find is
///   drawn larger. Hardcoding 16 everywhere quietly under-sizes every icon in
///   a touch product.
/// * **Stroke follows size.** 1.5 resting — except at 16, where the optical
///   floor is 1.75, because the same stroke reads thinner at a smaller size.
///   That correction is applied here, once, and never per-component.
/// * **Direction follows the reading direction.** Icons that mean "back",
///   "forward" or "onward" mirror in RTL. Icons that depict an object do not:
///   a camera points the same way in Arabic.
///
/// [active] is stroke 2.0, and is always paired with a colour change by the
/// caller — the weight alone is not a state signal.
class MonoIcon extends StatelessWidget {
  const MonoIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.active = false,
    this.semanticLabel,
    this.tooltip,
  }) : assert(
         size == null || (size >= 16 && size <= 32),
         'Icons render between 16 and 32. Below 16 use nothing; above 32 it is '
         'an illustration and has left the system.',
       );

  final MonoIconData icon;

  /// Overrides the density-resolved default. One of 16, 20, 24, 28, 32.
  final double? size;

  final Color? color;

  /// Overrides the size-resolved stroke. Rarely correct to set.
  final double? strokeWidth;

  /// Renders at stroke 2.0. Pair it with a colour: weight alone never carries
  /// a state.
  final bool active;

  final String? semanticLabel;

  /// Shown at pointer density only, where an icon-only control has no label
  /// beside it to explain itself.
  final String? tooltip;

  /// The roles that mean direction rather than depict an object, and therefore
  /// mirror when the reading direction flips.
  static const Set<String> _mirroredLabels = <String>{
    'Back',
    'Previous',
    'Next',
    'Continue',
    'Send',
    'Reply',
    'Forward',
  };

  bool get _mirrors => _mirroredLabels.contains(icon.semanticLabel);

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final resolvedSize = size ?? theme.density.iconChrome;
    final resolvedStroke =
        strokeWidth ??
        (active
            ? MonokitIconSize.strokeActive
            : resolvedSize <= MonokitIconSize.xs
            ? MonokitIconSize.strokeXs
            : MonokitIconSize.stroke);

    Widget glyph = HugeIcon(
      icon: icon.data,
      size: resolvedSize,
      color: color ?? theme.colors.foreground,
      strokeWidth: resolvedStroke,
    );

    if (_mirrors && Directionality.of(context) == TextDirection.rtl) {
      glyph = Transform.flip(flipX: true, child: glyph);
    }

    final label = semanticLabel ?? icon.semanticLabel;
    Widget result = Semantics(
      label: label,
      excludeSemantics: true,
      child: glyph,
    );

    final tip = tooltip;
    if (tip != null && !theme.density.isTouch) {
      result = MonoTooltip(message: tip, child: result);
    }
    return result;
  }
}
