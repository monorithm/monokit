import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';

/// Shapes supported by [MonoSkeleton].
enum MonoSkeletonShape { rectangle, circle }

/// An animated placeholder that uses the muted and background semantic tokens.
class MonoSkeleton extends StatefulWidget {
  const MonoSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = MonoSkeletonShape.rectangle,
    this.animate = true,
    this.sweepOnce = false,
    this.semanticLabel = 'Loading',
    this.excludeFromSemantics = false,
  });

  /// A shorthand for a circular skeleton, useful while avatars load.
  const MonoSkeleton.circle({
    super.key,
    double? size,
    this.animate = true,
    this.semanticLabel = 'Loading',
    this.excludeFromSemantics = false,
  }) : width = size,
       height = size,
       borderRadius = null,
       sweepOnce = false,
       shape = MonoSkeletonShape.circle;

  final double? width;
  final double? height;
  final double? borderRadius;
  final MonoSkeletonShape shape;
  final bool animate;

  /// One sweep instead of a loop.
  ///
  /// The distinction is load-bearing and easy to lose: **a looping shimmer
  /// means loading; a single sweep means settled.** A surface that is
  /// reconciling — the server has the write, the read model is catching up —
  /// sweeps once and stops. A surface that is still waiting loops. Rendering
  /// one as the other tells the user the opposite of what is true.
  final bool sweepOnce;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  State<MonoSkeleton> createState() => _MonoSkeletonState();
}

class _MonoSkeletonState extends State<MonoSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant MonoSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate ||
        oldWidget.sweepOnce != widget.sweepOnce) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    final theme = MonokitTheme.of(context);
    _controller.duration = theme.motion.shimmerLoop;
    final animationsDisabled = MonokitMotion.noAnimation(context);
    final shouldAnimate =
        widget.animate &&
        !animationsDisabled &&
        TickerMode.valuesOf(context).enabled;
    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        if (widget.sweepOnce) {
          _controller.forward(from: 0);
        } else {
          _controller.repeat();
        }
      }
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final animationsDisabled = MonokitMotion.noAnimation(context);
    final animate = widget.animate && !animationsDisabled;
    final width = widget.width;
    final height = widget.height ?? theme.spacing.lg;
    final borderRadius = switch (widget.shape) {
      MonoSkeletonShape.rectangle => BorderRadius.circular(
        widget.borderRadius ?? theme.radii.md,
      ),
      MonoSkeletonShape.circle => BorderRadius.circular(theme.radii.full),
    };
    final baseColor = theme.colors.muted;
    final highlightColor = Color.lerp(
      baseColor,
      theme.colors.background,
      0.62,
    )!;

    final skeleton = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = animate ? _controller.value : 0.5;
          final beginX = -1.5 + progress * 3;
          return SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment(beginX, 0),
                  end: Alignment(beginX + 1, 0),
                  colors: <Color>[baseColor, highlightColor, baseColor],
                  stops: const <double>[0.2, 0.5, 0.8],
                ),
              ),
            ),
          );
        },
      ),
    );

    if (widget.excludeFromSemantics) {
      return ExcludeSemantics(child: skeleton);
    }
    return Semantics(label: widget.semanticLabel, child: skeleton);
  }
}
