/// The specification's semantic layout tokens.
///
/// These are the numbers the design language names — `row2`, `headerHeight`,
/// `swipeActionCell`, `feed` — as opposed to the raw four-point scale in
/// `MonokitSpacing`. A design board is drawn in *these* words, so without them
/// a developer reading "a 64px list row" has nothing to reach for and types
/// `64`.
///
/// They are static rather than themed, matching the shape the specification's
/// own generator emits: these are canonical constants of the language, not
/// values a host retunes. What *does* vary — row heights, control heights, the
/// hit-target floor — varies by **density**, and lives on `MonokitDensity`
/// where it can be resolved from the input modality.
library;

/// Width classes, as the specification names them.
enum MonoWidthClass { compact, medium, expanded, wide }

/// Content containers. A measure, not a box: these cap how wide a thing gets,
/// they do not set how wide it is.
abstract final class MonokitContainers {
  /// The feed column. The reason a post does not stretch to 1200px on a tablet.
  static const double feed = 480;

  /// Reading measure for long-form text.
  static const double content = 640;

  static const double sheet = 640;
  static const double page = 1200;
  static const double dialogSm = 400;
  static const double dialogMd = 560;
  static const double dialogLg = 720;
  static const double sidebar = 280;
  static const double rail = 72;
}

/// Application chrome.
abstract final class MonokitChrome {
  /// Compact and medium. The title aligns to the content column, not the
  /// screen edge.
  static const double headerHeight = 56;

  static const double headerHeightExpanded = 64;

  /// The bottom tab bar. Chrome, like the header, and the same height as it —
  /// not a control, so it does not shrink to `minimumTarget`. Five equal
  /// columns with their labels always on.
  static const double tabBarHeight = 56;
  static const double borderWidth = 1;
}

/// The page inset per width class — the gutter between content and the screen
/// edge.
abstract final class MonokitPageInset {
  static const double compact = 16;
  static const double medium = 24;
  static const double expanded = 32;
  static const double wide = 32;

  static double of(MonoWidthClass w) => switch (w) {
    MonoWidthClass.compact => compact,
    MonoWidthClass.medium => medium,
    MonoWidthClass.expanded => expanded,
    MonoWidthClass.wide => wide,
  };
}

/// Gutters between columns.
abstract final class MonokitGutter {
  static const double base = 16;
  static const double medium = 24;

  /// Media grids sit tighter than content grids: the images are the content,
  /// and air between them reads as a gap in the subject.
  static const double media = 4;
}

/// The five icon sizes, and the three stroke weights.
abstract final class MonokitIconSize {
  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 32;

  /// The resting stroke.
  static const double stroke = 1.5;

  /// Active — paired with colour, never carrying the state alone.
  static const double strokeActive = 2;

  /// The optical floor at 16px, and **only** at 16px. A 1.5 stroke at that
  /// size reads thinner than the same stroke at 24, so it is corrected once
  /// here rather than per-component.
  static const double strokeXs = 1.75;

  /// Every sanctioned size, in order. Nothing renders below [xs] (use nothing)
  /// or above [xl] (it is an illustration and has left the system).
  static const List<double> all = <double>[xs, sm, md, lg, xl];
}

/// List metrics that are not row heights.
abstract final class MonokitList {
  /// One swipe-action cell. Wider than the 44 minimum on purpose: room for an
  /// icon and a label. At most two per side.
  static const double swipeActionCell = 72;

  static const double leadingAvatar = 40;
}

/// Which side of the screen the thumb arc favours.
///
/// Flips every thumb-arc placement together, for handedness and for RTL. The
/// point is that they flip *together* — a layout with some controls flipped and
/// some not is worse than either arrangement.
enum MonoReachSide { start, end }
