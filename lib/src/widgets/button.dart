import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../primitives/mono_text_scale.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'spinner.dart';

/// Visual treatments available to a [MonoButton].
///
/// Five weights, each with an obvious job. `outline` is gone — a bordered
/// button contradicts the grouped surface model, and [tinted] covers the same
/// "present but not primary" role without one. `link` is gone too: [ghost]
/// already renders a bare tinted label.
enum MonoButtonVariant { filled, tinted, secondary, ghost, destructive }

/// Density options available to a [MonoButton].
///
/// Icon-only buttons are no longer separate values; pass `iconOnly` instead.
/// The old eight values were four sizes doubled, and at touch density `xs` and
/// `sm` both clamped to the 44pt minimum target — identical in practice.
///
/// [cta] is the block commitment control: the 48 rhythm at the `xxl` radius,
/// one per screen, usually pinned to the screen footer. It exists as a size
/// rather than a variant because any weight can be the commitment ("Send the
/// code" is filled, "Save this seller" is secondary).
enum MonoButtonSize { sm, md, lg, cta }

/// The immutable visual result of resolving a [MonoButton]'s tokens and state.
@immutable
class MonoResolvedButtonStyle {
  const MonoResolvedButtonStyle({
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.borderRadius,
    required this.padding,
    required this.minimumHeight,
    required this.iconSize,
    required this.opacity,
    required this.textStyle,
  });

  final Color background;
  final Color foreground;
  final Color? borderColor;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double minimumHeight;
  final double iconSize;
  final double opacity;
  final TextStyle textStyle;
}

/// Resolves a button's visual treatment from Monokit tokens and interaction
/// state. It is public so custom buttons can share the core visual language.
class MonoButtonStyleResolver {
  const MonoButtonStyleResolver();

  MonoResolvedButtonStyle resolve({
    required MonokitThemeData theme,
    required MonoButtonVariant variant,
    required MonoButtonSize size,
    required Set<MonoState> states,
    bool iconOnly = false,
  }) {
    final colors = theme.colors;
    final isHovered = states.contains(MonoState.hovered);
    final isPressed = states.contains(MonoState.pressed);
    final isDisabled = states.contains(MonoState.disabled);

    var background = colors.background.withValues(alpha: 0);
    var foreground = colors.foreground;
    Color? borderColor;

    switch (variant) {
      case MonoButtonVariant.filled:
        background = colors.primary;
        foreground = colors.primaryForeground;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.background,
            isPressed ? 0.18 : 0.1,
          )!;
        }
        break;
      case MonoButtonVariant.tinted:
        // The new middle weight, and what `outline` should have been: brand
        // presence without a border, since the grouped model has no borders
        // to lean on.
        background = colors.primarySoft;
        foreground = colors.primaryText;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.primary,
            isPressed ? 0.24 : 0.14,
          )!;
        }
        break;
      case MonoButtonVariant.secondary:
        background = colors.muted;
        foreground = colors.foreground;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.foreground,
            isPressed ? 0.1 : 0.05,
          )!;
        }
        break;
      case MonoButtonVariant.ghost:
        // Absorbs the former `link` variant: a bare interactive label. It
        // takes the tint rather than the plain foreground, which is what made
        // `link` distinct in the first place.
        foreground = colors.primaryText;
        if (isHovered || isPressed) {
          background = colors.muted;
        }
        break;
      case MonoButtonVariant.destructive:
        // Soft tint rather than a solid fill; hover deepens it toward solid.
        background = colors.destructiveSoft;
        foreground = colors.destructiveText;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.destructive,
            isPressed ? 0.24 : 0.14,
          )!;
        }
        break;
    }

    final sizeTokens = _MonoButtonSizeTokens.fromTheme(theme, size, iconOnly);
    return MonoResolvedButtonStyle(
      background: background,
      foreground: foreground,
      borderColor: borderColor,
      // The commitment control rounds up with its height; everything else
      // keeps the control radius.
      borderRadius: BorderRadius.circular(
        size == MonoButtonSize.cta ? theme.radii.xxl : theme.radii.lg,
      ),
      padding: sizeTokens.padding,
      minimumHeight: sizeTokens.minimumHeight < theme.density.minimumTarget
          ? theme.density.minimumTarget
          : sizeTokens.minimumHeight,
      iconSize: sizeTokens.iconSize,
      opacity: isDisabled ? 0.5 : 1,
      textStyle: theme.typography.button.copyWith(color: foreground),
    );
  }
}

class _MonoButtonSizeTokens {
  const _MonoButtonSizeTokens({
    required this.padding,
    required this.minimumHeight,
    required this.iconSize,
  });

  final EdgeInsets padding;
  final double minimumHeight;
  final double iconSize;

  factory _MonoButtonSizeTokens.fromTheme(
    MonokitThemeData theme,
    MonoButtonSize size,
    bool iconOnly,
  ) {
    final spacing = theme.spacing;
    final (double horizontal, double height, double icon) = switch (size) {
      MonoButtonSize.sm => (spacing.md, spacing.xxxl, spacing.lg),
      MonoButtonSize.md => (spacing.lg, spacing.lg + spacing.xl, spacing.xl),
      MonoButtonSize.lg => (spacing.xl, spacing.huge, spacing.xxl),
      MonoButtonSize.cta => (spacing.xl, spacing.giant, spacing.xl),
    };
    return _MonoButtonSizeTokens(
      padding: iconOnly
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(horizontal: horizontal),
      minimumHeight: height,
      iconSize: icon,
    );
  }
}

/// A token-driven button with pointer, keyboard, focus, and loading support.
///
/// It deliberately uses Widgets primitives rather than a Material button, so
/// it works just as well in a [WidgetsApp] as it does in a Material host.
class MonoButton extends StatefulWidget {
  const MonoButton({
    super.key,
    required this.child,
    this.onPressed,
    this.leading,
    this.trailing,
    this.variant = MonoButtonVariant.filled,
    this.size = MonoButtonSize.md,
    bool pending = false,
    @Deprecated('Renamed to pending. Removed in 5.0.0.') bool? isLoading,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.iconOnly = false,
  }) : pending = isLoading ?? pending;

  /// Convenience constructor for an icon followed by an optional label.
  ///
  /// Omitting [label] makes it an icon-only button — the padding collapses and
  /// it renders square. That used to require picking one of four separate
  /// `icon*` size values.
  const MonoButton.icon({
    super.key,
    required Widget icon,
    Widget? label,
    this.onPressed,
    this.variant = MonoButtonVariant.filled,
    this.size = MonoButtonSize.md,
    bool pending = false,
    @Deprecated('Renamed to pending. Removed in 5.0.0.') bool? isLoading,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : pending = isLoading ?? pending,
       child = label ?? icon,
       leading = label == null ? null : icon,
       trailing = null,
       iconOnly = label == null;

  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final MonoButtonVariant variant;
  final MonoButtonSize size;

  /// Renders square with no horizontal padding. Set automatically by
  /// [MonoButton.icon] when no label is supplied.
  final bool iconOnly;

  /// Whether the action is in flight.
  ///
  /// The system's word is **pending**, not "loading" — `MonoPhase.pending`,
  /// `MonoInput.pending`, `MonoField.pending`, and the board's own *"pending
  /// never claims done"*. The button was the one control saying something
  /// else, and a consumer should not have to remember which is which.
  final bool pending;

  /// The former name for [pending].
  @Deprecated('Renamed to pending for consistency. Removed in 5.0.0.')
  bool get isLoading => pending;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  @override
  State<MonoButton> createState() => _MonoButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<MonoButtonVariant>('variant', variant))
      ..add(EnumProperty<MonoButtonSize>('size', size))
      ..add(
        FlagProperty('enabled', value: onPressed != null, ifFalse: 'disabled'),
      )
      ..add(FlagProperty('pending', value: pending, ifTrue: 'pending'))
      ..add(StringProperty('semanticLabel', semanticLabel, defaultValue: null));
  }
}

class _MonoButtonState extends State<MonoButton> {
  final MonoButtonStyleResolver _styleResolver =
      const MonoButtonStyleResolver();
  final Set<MonoState> _states = <MonoState>{};
  // Bumped on every interaction-state change to rebuild only the visual leaf
  // (scoped in a ListenableBuilder), not the Semantics/FocusableActionDetector.
  final ValueNotifier<int> _statesTick = ValueNotifier<int>(0);
  late final FocusNode _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  bool get _isEnabled => widget.onPressed != null && !widget.pending;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode(debugLabel: 'MonoButton');
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant MonoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      final previousFocusNode = oldWidget.focusNode ?? _internalFocusNode;
      previousFocusNode.removeListener(_handleFocusChanged);
      _focusNode.addListener(_handleFocusChanged);
      _handleFocusChanged();
    }
    // If the button became disabled mid-press, clear the transient interaction
    // states so it can never render disabled *and* pressed/hovered.
    if (!_isEnabled) {
      _states
        ..remove(MonoState.pressed)
        ..remove(MonoState.hovered)
        ..remove(MonoState.focusVisible);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _internalFocusNode.dispose();
    _statesTick.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    _setState(MonoState.focused, _focusNode.hasFocus);
    if (!_focusNode.hasFocus) {
      _setState(MonoState.focusVisible, false);
    }
  }

  void _setState(MonoState state, bool value) {
    final didChange = value ? _states.add(state) : _states.remove(state);
    if (didChange && mounted) {
      _statesTick.value++;
    }
  }

  void _activate() {
    if (_isEnabled) {
      // Fires only when the app opts into MonokitHaptics (disabled by default).
      MonokitTheme.of(context).haptics.impactLight();
      widget.onPressed!.call();
    }
  }

  Set<MonoState> get _resolvedStates {
    final states = Set<MonoState>.of(_states);
    if (!_isEnabled) {
      states.add(MonoState.disabled);
    }
    return states;
  }

  Duration _motionDuration(BuildContext context, Duration duration) {
    return MonokitMotion.noAnimation(context) ? Duration.zero : duration;
  }

  /// The interaction-state-dependent visual, rebuilt in isolation by the
  /// [ListenableBuilder] in [build].
  Widget _buildVisual(
    BuildContext context,
    MonokitThemeData theme,
    MonoResolvedButtonStyle style,
    Set<MonoState> states,
    bool isPressed,
    bool isIconButton,
    Duration motionDuration,
  ) {
    Widget contents;
    if (widget.pending) {
      contents = SizedBox(
        width: style.iconSize,
        height: style.iconSize,
        child: MonoSpinner(size: style.iconSize, color: style.foreground),
      );
    } else if (isIconButton) {
      contents = IconTheme.merge(
        data: IconThemeData(color: style.foreground, size: style.iconSize),
        child: Center(child: widget.child),
      );
    } else {
      final children = <Widget>[
        if (widget.leading != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: style.foreground, size: style.iconSize),
            child: widget.leading!,
          ),
          SizedBox(width: theme.spacing.sm),
        ],
        // Flexible lets a long label shrink/ellipsize inside a width-bounded
        // button (full-width buttons, stretched card columns). Note this means
        // MonoButton is not intrinsic-safe — do not place it where an ancestor
        // measures intrinsic width (IntrinsicWidth, some table columns).
        Flexible(child: widget.child),
        if (widget.trailing != null) ...[
          SizedBox(width: theme.spacing.sm),
          IconTheme.merge(
            data: IconThemeData(color: style.foreground, size: style.iconSize),
            child: widget.trailing!,
          ),
        ],
      ];
      contents = Row(mainAxisSize: MainAxisSize.min, children: children);
    }

    return AnimatedOpacity(
      opacity: style.opacity,
      duration: motionDuration,
      curve: theme.motion.curve,
      child: AnimatedScale(
        scale: isPressed ? theme.components.button.pressedScale : 1,
        duration: motionDuration,
        curve: theme.motion.curve,
        child: AnimatedContainer(
          duration: motionDuration,
          curve: theme.motion.curve,
          constraints: BoxConstraints(
            minWidth: isIconButton
                ? monoScaledExtent(context, style.minimumHeight)
                : 0,
            minHeight: monoScaledExtent(context, style.minimumHeight),
          ),
          padding: style.padding,
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: style.borderRadius,
            border: style.borderColor == null
                ? null
                : Border.all(color: style.borderColor!),
            boxShadow: states.contains(MonoState.focusVisible)
                ? theme.focus.ringShadow(theme.colors.ring)
                : null,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: style.textStyle,
              child: contents,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final motionDuration = _motionDuration(context, theme.motion.fast);
    final isIconButton = widget.iconOnly;

    // Only this leaf rebuilds on hover/press/focus ticks; the Semantics and
    // FocusableActionDetector below stay stable.
    final Widget visual = ListenableBuilder(
      listenable: _statesTick,
      builder: (BuildContext context, Widget? _) {
        final states = _resolvedStates;
        final style = _styleResolver.resolve(
          theme: theme,
          variant: widget.variant,
          size: widget.size,
          states: states,
          iconOnly: widget.iconOnly,
        );
        final isPressed = states.contains(MonoState.pressed);
        return _buildVisual(
          context,
          theme,
          style,
          states,
          isPressed,
          isIconButton,
          motionDuration,
        );
      },
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.pending
          ? '${widget.semanticLabel ?? 'Button'} loading'
          : widget.semanticLabel,
      liveRegion: widget.pending,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        enabled: _isEnabled,
        mouseCursor: _isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onShowHoverHighlight: (value) => _setState(MonoState.hovered, value),
        onShowFocusHighlight: (value) =>
            _setState(MonoState.focusVisible, value),
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: _isEnabled ? _activate : null,
          onTapDown: _isEnabled
              ? (_) => _setState(MonoState.pressed, true)
              : null,
          onTapUp: _isEnabled
              ? (_) => _setState(MonoState.pressed, false)
              : null,
          onTapCancel: _isEnabled
              ? () => _setState(MonoState.pressed, false)
              : null,
          child: visual,
        ),
      ),
    );
  }
}
