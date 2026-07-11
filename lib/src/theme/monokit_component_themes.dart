/// Per-component configuration tokens.
///
/// Colors remain semantic and live in [MonokitColors]. These lightweight theme
/// objects intentionally hold only component-specific geometry and behavior,
/// so a product can adjust a single component without breaking token usage.
class MonoButtonTheme {
  const MonoButtonTheme({this.focusRingWidth = 2, this.pressedScale = 0.98});

  final double focusRingWidth;
  final double pressedScale;

  @override
  bool operator ==(Object other) =>
      other is MonoButtonTheme &&
      focusRingWidth == other.focusRingWidth &&
      pressedScale == other.pressedScale;

  @override
  int get hashCode => Object.hash(focusRingWidth, pressedScale);
}

class MonoCardTheme {
  const MonoCardTheme({this.borderWidth = 1, this.elevation = 1});

  final double borderWidth;
  final double elevation;

  @override
  bool operator ==(Object other) =>
      other is MonoCardTheme &&
      borderWidth == other.borderWidth &&
      elevation == other.elevation;

  @override
  int get hashCode => Object.hash(borderWidth, elevation);
}

class MonoInputTheme {
  const MonoInputTheme({this.borderWidth = 1, this.focusRingWidth = 2});

  final double borderWidth;
  final double focusRingWidth;

  @override
  bool operator ==(Object other) =>
      other is MonoInputTheme &&
      borderWidth == other.borderWidth &&
      focusRingWidth == other.focusRingWidth;

  @override
  int get hashCode => Object.hash(borderWidth, focusRingWidth);
}

class MonoControlTheme {
  const MonoControlTheme({this.focusRingWidth = 2});

  final double focusRingWidth;

  @override
  bool operator ==(Object other) =>
      other is MonoControlTheme && focusRingWidth == other.focusRingWidth;

  @override
  int get hashCode => focusRingWidth.hashCode;
}

class MonoScreenTheme {
  const MonoScreenTheme({
    this.compactBreakpoint = 600,
    this.mediumBreakpoint = 960,
    this.sidebarWidth = 280,
    this.sidebarRailWidth = 72,
  });

  final double compactBreakpoint;
  final double mediumBreakpoint;
  final double sidebarWidth;
  final double sidebarRailWidth;

  @override
  bool operator ==(Object other) =>
      other is MonoScreenTheme &&
      compactBreakpoint == other.compactBreakpoint &&
      mediumBreakpoint == other.mediumBreakpoint &&
      sidebarWidth == other.sidebarWidth &&
      sidebarRailWidth == other.sidebarRailWidth;

  @override
  int get hashCode => Object.hash(
    compactBreakpoint,
    mediumBreakpoint,
    sidebarWidth,
    sidebarRailWidth,
  );
}

/// Container for all component theme knobs.
class MonokitComponentThemes {
  const MonokitComponentThemes({
    this.button = const MonoButtonTheme(),
    this.badge = const MonoControlTheme(),
    this.card = const MonoCardTheme(),
    this.input = const MonoInputTheme(),
    this.textarea = const MonoInputTheme(),
    this.field = const MonoControlTheme(),
    this.checkbox = const MonoControlTheme(),
    this.radioGroup = const MonoControlTheme(),
    this.toggle = const MonoControlTheme(),
    this.tabs = const MonoControlTheme(),
    this.accordion = const MonoControlTheme(),
    this.avatar = const MonoControlTheme(),
    this.separator = const MonoControlTheme(),
    this.skeleton = const MonoControlTheme(),
    this.spinner = const MonoControlTheme(),
    this.kbd = const MonoControlTheme(),
    this.screen = const MonoScreenTheme(),
  });

  final MonoButtonTheme button;
  final MonoControlTheme badge;
  final MonoCardTheme card;
  final MonoInputTheme input;
  final MonoInputTheme textarea;
  final MonoControlTheme field;
  final MonoControlTheme checkbox;
  final MonoControlTheme radioGroup;
  final MonoControlTheme toggle;
  final MonoControlTheme tabs;
  final MonoControlTheme accordion;
  final MonoControlTheme avatar;
  final MonoControlTheme separator;
  final MonoControlTheme skeleton;
  final MonoControlTheme spinner;
  final MonoControlTheme kbd;
  final MonoScreenTheme screen;

  @override
  bool operator ==(Object other) =>
      other is MonokitComponentThemes &&
      button == other.button &&
      badge == other.badge &&
      card == other.card &&
      input == other.input &&
      textarea == other.textarea &&
      field == other.field &&
      checkbox == other.checkbox &&
      radioGroup == other.radioGroup &&
      toggle == other.toggle &&
      tabs == other.tabs &&
      accordion == other.accordion &&
      avatar == other.avatar &&
      separator == other.separator &&
      skeleton == other.skeleton &&
      spinner == other.spinner &&
      kbd == other.kbd &&
      screen == other.screen;

  @override
  int get hashCode => Object.hashAll(<Object>[
    button,
    badge,
    card,
    input,
    textarea,
    field,
    checkbox,
    radioGroup,
    toggle,
    tabs,
    accordion,
    avatar,
    separator,
    skeleton,
    spinner,
    kbd,
    screen,
  ]);
}
