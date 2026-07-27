import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';

/// A compact, token-aware indeterminate loading indicator.
///
/// [MonoSpinner] is painted with Widgets primitives instead of depending on
/// Material's progress indicator. It automatically stops when the platform has
/// requested reduced motion.
class MonoSpinner extends StatefulWidget {
  const MonoSpinner({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.animate = true,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  /// The square side length. When omitted, the compact spacing token is used.
  final double? size;

  /// Overrides the semantic primary color token.
  final Color? color;

  /// Overrides the token-derived line width.
  final double? strokeWidth;

  /// Whether the arc should rotate when motion is enabled.
  final bool animate;

  /// Accessible name announced while the spinner is live. Falls back to
  /// `MonokitTheme.of(context).labels.loading`, which is overridable and
  /// localisable — this used to hardcode the English string 'Loading', which
  /// is why `labels.loading` had no call sites.
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  State<MonoSpinner> createState() => _MonoSpinnerState();
}

class _MonoSpinnerState extends State<MonoSpinner>
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
  void didUpdateWidget(covariant MonoSpinner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
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
    _controller.duration = theme.motion.spinnerLoop;
    final animationsDisabled = MonokitMotion.noAnimation(context);
    final shouldAnimate =
        widget.animate &&
        !animationsDisabled &&
        TickerMode.valuesOf(context).enabled;
    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final size = widget.size ?? theme.spacing.lg;
    final strokeWidth = (widget.strokeWidth ?? theme.spacing.xs / 2)
        .clamp(1.0, size / 2)
        .toDouble();
    final color = widget.color ?? theme.colors.foreground;
    final animationsDisabled = MonokitMotion.noAnimation(context);
    final isAnimated = widget.animate && !animationsDisabled;

    final spinner = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size.square(size),
            painter: _MonoSpinnerPainter(
              progress: isAnimated ? _controller.value : 0,
              color: color,
              strokeWidth: strokeWidth,
            ),
          );
        },
      ),
    );

    if (widget.excludeFromSemantics) {
      return ExcludeSemantics(child: spinner);
    }
    return Semantics(
      label: widget.semanticLabel ?? MonokitTheme.of(context).labels.loading,
      liveRegion: true,
      child: spinner,
    );
  }
}

class _MonoSpinnerPainter extends CustomPainter {
  const _MonoSpinnerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2 + progress * math.pi * 2,
      math.pi * 1.35,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _MonoSpinnerPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
