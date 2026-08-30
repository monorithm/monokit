import 'package:flutter/foundation.dart';

/// Whether the UI is being driven by a finger or a cursor.
///
/// This is an *input* distinction, not a size one. A phone in landscape is
/// still touch; a tablet docked with a trackpad is not.
enum MonoDensity { touch, pointer }

/// Control metrics, and the policy for choosing between them.
///
/// [mode] is `null` by default, meaning **adaptive**: [MonokitApp] resolves it
/// once per frame via [resolveFrom] and bakes the answer into the theme, so no
/// widget performs its own `MediaQuery` lookup. Setting [mode] explicitly is a
/// hard override and disables adaptation — useful for tests and for hosts that
/// know better than the heuristic.
@immutable
final class MonokitDensity {
  const MonokitDensity({
    this.mode,
    this.touchTarget = 44,
    this.pointerTarget = 32,
  });

  /// `null` means adaptive. Non-null overrides [resolveFrom].
  final MonoDensity? mode;

  final double touchTarget;
  final double pointerTarget;

  /// The minimum hit target for the resolved mode. Falls back to the touch
  /// target when unresolved, because being too generous is the safe failure.
  double get minimumTarget =>
      mode == MonoDensity.pointer ? pointerTarget : touchTarget;

  bool get isTouch => mode != MonoDensity.pointer;

  /// The specification's name for [minimumTarget]. The visual glyph may be
  /// smaller than this; the hit area may not.
  double get minTarget => minimumTarget;

  /// The height of a standard control — a button, an input, a select.
  double get controlHeight => isTouch ? 44 : 36;

  /// The gap between adjacent controls in a group.
  double get gap => isTouch ? 8 : 4;

  /// The three list-row heights. One line, two lines, and a media row.
  double get row1 => isTouch ? 48 : 40;
  double get row2 => isTouch ? 64 : 56;
  double get row3 => isTouch ? 88 : 76;

  /// The default size for a chrome icon at this density. Touch gets the larger
  /// glyph because a finger is a coarser instrument than a cursor.
  double get iconChrome => isTouch ? 20 : 16;

  /// Platform first, width second.
  ///
  /// A desktop platform is always pointer — it has a cursor regardless of
  /// window size. A touch platform in a window at or past
  /// [MonokitBreakpoints.expanded] is treated as pointer, because at that size
  /// it is an iPad with a keyboard or an Android device in desktop mode far
  /// more often than it is a phone. Below that, touch.
  ///
  /// Pure by design: no `BuildContext`, so it is table-testable directly.
  static MonoDensity resolveFrom({
    required TargetPlatform platform,
    required double width,
    required MonokitBreakpoints breakpoints,
  }) {
    const touchPlatforms = <TargetPlatform>{
      TargetPlatform.iOS,
      TargetPlatform.android,
      TargetPlatform.fuchsia,
    };
    if (!touchPlatforms.contains(platform)) return MonoDensity.pointer;
    return width >= breakpoints.expanded
        ? MonoDensity.pointer
        : MonoDensity.touch;
  }

  MonokitDensity copyWith({
    MonoDensity? mode,
    double? touchTarget,
    double? pointerTarget,
  }) => MonokitDensity(
    mode: mode ?? this.mode,
    touchTarget: touchTarget ?? this.touchTarget,
    pointerTarget: pointerTarget ?? this.pointerTarget,
  );

  /// [copyWith] cannot clear [mode] back to adaptive, since `null` means
  /// "unchanged" there. This can.
  MonokitDensity withMode(MonoDensity? mode) => MonokitDensity(
    mode: mode,
    touchTarget: touchTarget,
    pointerTarget: pointerTarget,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitDensity &&
          mode == other.mode &&
          touchTarget == other.touchTarget &&
          pointerTarget == other.pointerTarget);

  @override
  int get hashCode => Object.hash(mode, touchTarget, pointerTarget);
}

/// The single width ladder: compact <600 · medium 600–960 · expanded 960–1280 ·
/// wide ≥1280.
///
/// This used to be duplicated — `MonoScreenTheme` carried its own
/// `compactBreakpoint`/`mediumBreakpoint` with the same numbers, and the
/// library read that copy while the example read this one. There is now one.
@immutable
final class MonokitBreakpoints {
  const MonokitBreakpoints({
    this.compact = 600,
    this.medium = 960,
    this.expanded = 1280,
  });

  final double compact;
  final double medium;
  final double expanded;

  bool isCompact(double width) => width < compact;
  bool isMedium(double width) => width >= compact && width < medium;
  bool isExpanded(double width) => width >= medium && width < expanded;
  bool isWide(double width) => width >= expanded;

  MonokitBreakpoints copyWith({
    double? compact,
    double? medium,
    double? expanded,
  }) => MonokitBreakpoints(
    compact: compact ?? this.compact,
    medium: medium ?? this.medium,
    expanded: expanded ?? this.expanded,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonokitBreakpoints &&
          compact == other.compact &&
          medium == other.medium &&
          expanded == other.expanded);

  @override
  int get hashCode => Object.hash(compact, medium, expanded);
}
