import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/monokit_layout.dart';
import '../theme/monokit_theme.dart';
import 'tooltip.dart';

/// An opaque handle to one icon in the system's catalogue.
///
/// A role, not a picture. Callers name intent — [MonoIcons.like] — and the
/// mapping from role to glyph is the system's own business: which vendor set
/// backs it, and whether that set ever changes, is not something a call site
/// can see or depend on.
///
/// That opacity is the point. Until 4.0.0 this type carried the vendor's path
/// data as a public field and invited callers to construct one from a raw
/// vendor constant, which made a vendor swap a breaking change for everybody
/// rather than an internal detail. The catalogue is the API; if a role is
/// missing from it, the fix is to add the role.
@immutable
class MonoIconData {
  const MonoIconData._(this._data, {this.semanticLabel});

  final List<List<dynamic>> _data;

  /// What assistive technology announces, unless the call site overrides it.
  final String? semanticLabel;

  /// Same glyph, different announcement — for a role whose meaning is narrower
  /// at one call site than the catalogue can know.
  MonoIconData withSemanticLabel(String label) =>
      MonoIconData._(_data, semanticLabel: label);
}

/// A compact, semantic icon catalog mapped onto the HugeIcons stroke-rounded
/// set. Names describe role, not glyph, so a vendor swap never touches call
/// sites.
abstract final class MonoIcons {
  static const MonoIconData add = MonoIconData._(
    HugeIcons.strokeRoundedAdd01,
    semanticLabel: 'Add',
  );
  static const MonoIconData close = MonoIconData._(
    HugeIcons.strokeRoundedCancel01,
    semanticLabel: 'Close',
  );
  static const MonoIconData check = MonoIconData._(
    HugeIcons.strokeRoundedTick02,
    semanticLabel: 'Selected',
  );
  static const MonoIconData chevronDown = MonoIconData._(
    HugeIcons.strokeRoundedArrowDown01,
    semanticLabel: 'Expand',
  );
  static const MonoIconData chevronUp = MonoIconData._(
    HugeIcons.strokeRoundedArrowUp01,
    semanticLabel: 'Collapse',
  );
  static const MonoIconData chevronLeft = MonoIconData._(
    HugeIcons.strokeRoundedArrowLeft01,
    semanticLabel: 'Previous',
  );
  static const MonoIconData chevronRight = MonoIconData._(
    HugeIcons.strokeRoundedArrowRight01,
    semanticLabel: 'Next',
  );
  static const MonoIconData arrowRight = MonoIconData._(
    HugeIcons.strokeRoundedArrowRight01,
    semanticLabel: 'Continue',
  );
  static const MonoIconData menu = MonoIconData._(
    HugeIcons.strokeRoundedMenu01,
    semanticLabel: 'Menu',
  );
  static const MonoIconData more = MonoIconData._(
    HugeIcons.strokeRoundedMoreHorizontal,
    semanticLabel: 'More options',
  );
  static const MonoIconData sparkles = MonoIconData._(
    HugeIcons.strokeRoundedAiMagic,
    semanticLabel: 'Sparkles',
  );
  static const MonoIconData search = MonoIconData._(
    HugeIcons.strokeRoundedSearch01,
    semanticLabel: 'Search',
  );
  static const MonoIconData send = MonoIconData._(
    HugeIcons.strokeRoundedSent,
    semanticLabel: 'Send',
  );
  static const MonoIconData play = MonoIconData._(
    HugeIcons.strokeRoundedPlay,
    semanticLabel: 'Play',
  );
  static const MonoIconData pause = MonoIconData._(
    HugeIcons.strokeRoundedPause,
    semanticLabel: 'Pause',
  );
  static const MonoIconData bag = MonoIconData._(
    HugeIcons.strokeRoundedShoppingBag01,
    semanticLabel: 'Shop',
  );
  static const MonoIconData receipt = MonoIconData._(
    HugeIcons.strokeRoundedInvoice01,
    semanticLabel: 'Orders',
  );
  static const MonoIconData grid = MonoIconData._(
    HugeIcons.strokeRoundedDashboardSquare01,
    semanticLabel: 'Workspace',
  );
  static const MonoIconData video = MonoIconData._(
    HugeIcons.strokeRoundedVideo01,
    semanticLabel: 'Live video',
  );
  static const MonoIconData message = MonoIconData._(
    HugeIcons.strokeRoundedMessage01,
    semanticLabel: 'Messages',
  );
  static const MonoIconData call = MonoIconData._(
    HugeIcons.strokeRoundedCall,
    semanticLabel: 'Call',
  );
  static const MonoIconData user = MonoIconData._(
    HugeIcons.strokeRoundedUser,
    semanticLabel: 'Account',
  );
  static const MonoIconData like = MonoIconData._(
    HugeIcons.strokeRoundedFavourite,
    semanticLabel: 'Like',
  );
  static const MonoIconData location = MonoIconData._(
    HugeIcons.strokeRoundedLocation01,
    semanticLabel: 'Location',
  );
  static const MonoIconData filter = MonoIconData._(
    HugeIcons.strokeRoundedFilterHorizontal,
    semanticLabel: 'Filter',
  );
  static const MonoIconData mic = MonoIconData._(
    HugeIcons.strokeRoundedMic01,
    semanticLabel: 'Voice note',
  );
  static const MonoIconData image = MonoIconData._(
    HugeIcons.strokeRoundedImage01,
    semanticLabel: 'Photo',
  );
  static const MonoIconData star = MonoIconData._(
    HugeIcons.strokeRoundedStar,
    semanticLabel: 'Featured',
  );
  static const MonoIconData bookmark = MonoIconData._(
    HugeIcons.strokeRoundedBookmark01,
    semanticLabel: 'Save',
  );
  static const MonoIconData mute = MonoIconData._(
    HugeIcons.strokeRoundedVolumeMute01,
    semanticLabel: 'Mute',
  );
  static const MonoIconData clock = MonoIconData._(
    HugeIcons.strokeRoundedClock01,
    semanticLabel: 'Time',
  );
  static const MonoIconData document = MonoIconData._(
    HugeIcons.strokeRoundedFile01,
    semanticLabel: 'Document',
  );
  static const MonoIconData link = MonoIconData._(
    HugeIcons.strokeRoundedLink01,
    semanticLabel: 'Link',
  );
  static const MonoIconData download = MonoIconData._(
    HugeIcons.strokeRoundedDownload01,
    semanticLabel: 'Download',
  );
  static const MonoIconData back = MonoIconData._(
    HugeIcons.strokeRoundedArrowLeft01,
    semanticLabel: 'Back',
  );
  static const MonoIconData store = MonoIconData._(
    HugeIcons.strokeRoundedStore01,
    semanticLabel: 'Shop',
  );
  static const MonoIconData camera = MonoIconData._(
    HugeIcons.strokeRoundedCamera01,
    semanticLabel: 'Camera',
  );
  static const MonoIconData share = MonoIconData._(
    HugeIcons.strokeRoundedShare01,
    semanticLabel: 'Share',
  );
  static const MonoIconData settings = MonoIconData._(
    HugeIcons.strokeRoundedSettings01,
    semanticLabel: 'Settings',
  );
  static const MonoIconData notification = MonoIconData._(
    HugeIcons.strokeRoundedNotification02,
    semanticLabel: 'Notifications',
  );
  static const MonoIconData edit = MonoIconData._(
    HugeIcons.strokeRoundedEdit02,
    semanticLabel: 'Edit',
  );
  static const MonoIconData home = MonoIconData._(
    HugeIcons.strokeRoundedHome01,
    semanticLabel: 'Home',
  );

  static const MonoIconData list = MonoIconData._(
    HugeIcons.strokeRoundedLeftToRightListBullet,
    semanticLabel: 'List view',
  );

  // The account surface's roles. A product built on this kit reaches Settings,
  // a blocked list and a way out on day one, and until now had to draw those
  // itself - which it could not, since MonoIconData is ours to construct. Same
  // vendor family as everything above, so the catalogue stays one hand.
  static const MonoIconData language = MonoIconData._(
    HugeIcons.strokeRoundedGlobe02,
    semanticLabel: 'Language',
  );

  /// Notifications silenced - NOT [mute], which is the audio one. A product
  /// that offers both needs them to be different glyphs, because they are
  /// different promises.
  static const MonoIconData notificationOff = MonoIconData._(
    HugeIcons.strokeRoundedNotificationOff03,
    semanticLabel: 'Notifications off',
  );

  /// A credential: signing back in, a key to an account.
  static const MonoIconData key = MonoIconData._(
    HugeIcons.strokeRoundedKey01,
    semanticLabel: 'Sign in',
  );

  /// Someone the viewer has blocked. Not [flag], which reports outward, and
  /// not [eyeOff], which hides: this one is about a person.
  static const MonoIconData block = MonoIconData._(
    HugeIcons.strokeRoundedUserBlock01,
    semanticLabel: 'Blocked',
  );

  /// Leaving the session, not the account. Deletion is [trash].
  static const MonoIconData signOut = MonoIconData._(
    HugeIcons.strokeRoundedLogout03,
    semanticLabel: 'Sign out',
  );

  /// A nudge before something lapses. [clock] states a time; this one says
  /// somebody will be told.
  static const MonoIconData reminder = MonoIconData._(
    HugeIcons.strokeRoundedAlarmClock,
    semanticLabel: 'Reminder',
  );

  /// A credential that was checked. [shield] is the idea of protection;
  /// this is the state of having passed.
  static const MonoIconData verified = MonoIconData._(
    HugeIcons.strokeRoundedCheckmarkBadge01,
    semanticLabel: 'Verified',
  );
  static const MonoIconData shield = MonoIconData._(
    HugeIcons.strokeRoundedShield01,
    semanticLabel: 'Verified',
  );
  static const MonoIconData trash = MonoIconData._(
    HugeIcons.strokeRoundedDelete02,
    semanticLabel: 'Delete',
  );
  static const MonoIconData flag = MonoIconData._(
    HugeIcons.strokeRoundedFlag02,
    semanticLabel: 'Report',
  );
  static const MonoIconData wifiOff = MonoIconData._(
    HugeIcons.strokeRoundedWifiDisconnected01,
    semanticLabel: 'Offline',
  );
  static const MonoIconData eyeOff = MonoIconData._(
    HugeIcons.strokeRoundedViewOff,
    semanticLabel: 'Hide',
  );
  static const MonoIconData zap = MonoIconData._(
    HugeIcons.strokeRoundedFlash,
    semanticLabel: 'Activate',
  );
  static const MonoIconData phoneIncoming = MonoIconData._(
    HugeIcons.strokeRoundedCallIncoming01,
    semanticLabel: 'Incoming call',
  );
  static const MonoIconData phoneOutgoing = MonoIconData._(
    HugeIcons.strokeRoundedCallOutgoing01,
    semanticLabel: 'Outgoing call',
  );
  static const MonoIconData plus = MonoIconData._(
    HugeIcons.strokeRoundedPlusSign,
    semanticLabel: 'Add',
  );
  static const MonoIconData refresh = MonoIconData._(
    HugeIcons.strokeRoundedRefresh,
    semanticLabel: 'Retry',
  );
  static const MonoIconData crop = MonoIconData._(
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
      icon: icon._data,
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
