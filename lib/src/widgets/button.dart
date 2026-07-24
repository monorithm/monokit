import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../states/mono_state.dart';
import '../primitives/mono_text_scale.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'spinner.dart';

/// Visual treatments available to a [MonoButton].
enum MonoButtonVariant { primary, outline, secondary, ghost, destructive, link }

/// Density and icon-layout options available to a [MonoButton].
enum MonoButtonSize { xs, sm, md, lg, icon, iconXs, iconSm, iconLg }

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
    required this.showUnderline,
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
  final bool showUnderline;
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
  }) {
    final colors = theme.colors;
    final isHovered = states.contains(MonoState.hovered);
    final isPressed = states.contains(MonoState.pressed);
    final isDisabled = states.contains(MonoState.disabled);

    var background = colors.background.withValues(alpha: 0);
    var foreground = colors.foreground;
    Color? borderColor;
    var showUnderline = false;

    switch (variant) {
      case MonoButtonVariant.primary:
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
      case MonoButtonVariant.outline:
        borderColor = colors.border;
        if (isHovered || isPressed) {
          background = colors.accent;
          foreground = colors.accentForeground;
        }
        break;
      case MonoButtonVariant.secondary:
        background = colors.secondary;
        foreground = colors.secondaryForeground;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.foreground,
            isPressed ? 0.1 : 0.05,
          )!;
        }
        break;
      case MonoButtonVariant.ghost:
        if (isHovered || isPressed) {
          background = colors.accent;
          foreground = colors.accentForeground;
        }
        break;
      case MonoButtonVariant.destructive:
        background = colors.destructive;
        foreground = colors.destructiveForeground;
        if (isHovered || isPressed) {
          background = Color.lerp(
            background,
            colors.foreground,
            isPressed ? 0.16 : 0.08,
          )!;
        }
        break;
      case MonoButtonVariant.link:
        foreground = colors.primary;
        showUnderline =
            isHovered || isPressed || states.contains(MonoState.focused);
        break;
    }

    final sizeTokens = _MonoButtonSizeTokens.fromTheme(theme, size);
    return MonoResolvedButtonStyle(
      background: background,
      foreground: foreground,
      borderColor: borderColor,
      borderRadius: BorderRadius.circular(theme.radii.md),
      padding: sizeTokens.padding,
      minimumHeight: sizeTokens.minimumHeight < theme.density.minimumTarget
          ? theme.density.minimumTarget
          : sizeTokens.minimumHeight,
      iconSize: sizeTokens.iconSize,
      opacity: isDisabled ? 0.5 : 1,
      textStyle: theme.typography.button.copyWith(
        color: foreground,
        decoration: showUnderline
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
      showUnderline: showUnderline,
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
  ) {
    final spacing = theme.spacing;
    switch (size) {
      case MonoButtonSize.xs:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          minimumHeight: spacing.xxl + spacing.xs,
          iconSize: spacing.md,
        );
      case MonoButtonSize.sm:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          minimumHeight: spacing.xxxl,
          iconSize: spacing.lg,
        );
      case MonoButtonSize.md:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
          minimumHeight: spacing.lg + spacing.xl,
          iconSize: spacing.xl,
        );
      case MonoButtonSize.lg:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.symmetric(horizontal: spacing.xl),
          minimumHeight: spacing.huge,
          iconSize: spacing.xxl,
        );
      case MonoButtonSize.iconXs:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.zero,
          minimumHeight: spacing.xxl + spacing.xs,
          iconSize: spacing.md,
        );
      case MonoButtonSize.iconSm:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.zero,
          minimumHeight: spacing.xxxl,
          iconSize: spacing.lg,
        );
      case MonoButtonSize.icon:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.zero,
          minimumHeight: spacing.lg + spacing.xl,
          iconSize: spacing.xl,
        );
      case MonoButtonSize.iconLg:
        return _MonoButtonSizeTokens(
          padding: EdgeInsets.zero,
          minimumHeight: spacing.huge,
          iconSize: spacing.xxl,
        );
    }
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
    this.variant = MonoButtonVariant.primary,
    this.size = MonoButtonSize.md,
    this.isLoading = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  });

  /// Convenience constructor for an icon followed by an optional label.
  const MonoButton.icon({
    super.key,
    required Widget icon,
    Widget? label,
    this.onPressed,
    this.variant = MonoButtonVariant.primary,
    this.size = MonoButtonSize.md,
    this.isLoading = false,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
  }) : child = label ?? icon,
       leading = label == null ? null : icon,
       trailing = null;

  final Widget child;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final MonoButtonVariant variant;
  final MonoButtonSize size;
  final bool isLoading;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;

  @override
  State<MonoButton> createState() => _MonoButtonState();
}

class _MonoButtonState extends State<MonoButton> {
  final MonoButtonStyleResolver _styleResolver =
      const MonoButtonStyleResolver();
  final Set<MonoState> _states = <MonoState>{};
  late final FocusNode _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

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
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _internalFocusNode.dispose();
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
      setState(() {});
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
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false
        ? Duration.zero
        : duration;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final states = _resolvedStates;
    final style = _styleResolver.resolve(
      theme: theme,
      variant: widget.variant,
      size: widget.size,
      states: states,
    );
    final motionDuration = _motionDuration(context, theme.motion.fast);
    final isPressed = states.contains(MonoState.pressed);
    final isIconButton = switch (widget.size) {
      MonoButtonSize.icon ||
      MonoButtonSize.iconXs ||
      MonoButtonSize.iconSm ||
      MonoButtonSize.iconLg => true,
      _ => false,
    };

    Widget contents;
    if (widget.isLoading) {
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

    final visual = AnimatedOpacity(
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
                ? <BoxShadow>[
                    BoxShadow(
                      color: theme.colors.ring.withValues(alpha: 0.35),
                      spreadRadius: theme.components.button.focusRingWidth,
                    ),
                  ]
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

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.isLoading
          ? '${widget.semanticLabel ?? 'Button'} loading'
          : widget.semanticLabel,
      liveRegion: widget.isLoading,
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
