import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

enum MonoProgressType { linear, circular }

/// Token-aware determinate or indeterminate progress feedback.
class MonoProgress extends StatefulWidget {
  const MonoProgress({
    super.key,
    this.value,
    this.type = MonoProgressType.linear,
    this.width,
    this.height,
    this.color,
    this.trackColor,
    this.strokeWidth,
    this.semanticLabel = 'Progress',
  }) : assert(value == null || (value >= 0 && value <= 1));

  /// A value from 0 to 1. Omit it for an indeterminate indicator.
  final double? value;
  final MonoProgressType type;
  final double? width;
  final double? height;
  final Color? color;
  final Color? trackColor;
  final double? strokeWidth;
  final String? semanticLabel;

  @override
  State<MonoProgress> createState() => _MonoProgressState();
}

class _MonoProgressState extends State<MonoProgress>
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
  void didUpdateWidget(covariant MonoProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    final theme = MonokitTheme.of(context);
    _controller.duration = theme.motion.progressLoop;
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.value == null &&
        !disabled &&
        TickerMode.valuesOf(context).enabled) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final foreground = widget.color ?? theme.colors.primary;
    final background = widget.trackColor ?? theme.colors.muted;
    final value = widget.value;
    final excluded = widget.semanticLabel == null;
    final indicator = switch (widget.type) {
      MonoProgressType.linear => _LinearMonoProgress(
        animation: _controller,
        value: value,
        color: foreground,
        trackColor: background,
        height: widget.height ?? theme.spacing.sm,
        width: widget.width,
        radius: theme.radii.full,
      ),
      MonoProgressType.circular => _CircularMonoProgress(
        animation: _controller,
        value: value,
        color: foreground,
        trackColor: background,
        size: widget.width ?? widget.height ?? theme.spacing.xxl,
        strokeWidth: widget.strokeWidth ?? theme.spacing.xs / 2,
      ),
    };
    final semantics = Semantics(
      label: widget.semanticLabel,
      value: value == null ? null : '${(value * 100).round()}%',
      child: indicator,
    );
    return excluded ? ExcludeSemantics(child: indicator) : semantics;
  }
}

class _LinearMonoProgress extends StatelessWidget {
  const _LinearMonoProgress({
    required this.animation,
    required this.value,
    required this.color,
    required this.trackColor,
    required this.height,
    required this.width,
    required this.radius,
  });

  final Animation<double> animation;
  final double? value;
  final Color color;
  final Color trackColor;
  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: trackColor,
          child: value == null
              ? AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) => Align(
                    alignment: Alignment(-1 + animation.value * 2, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.35,
                      heightFactor: 1,
                      child: ColoredBox(color: color),
                    ),
                  ),
                )
              : Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: value,
                    heightFactor: 1,
                    child: ColoredBox(color: color),
                  ),
                ),
        ),
      ),
    );
  }
}

class _CircularMonoProgress extends StatelessWidget {
  const _CircularMonoProgress({
    required this.animation,
    required this.value,
    required this.color,
    required this.trackColor,
    required this.size,
    required this.strokeWidth,
  });

  final Animation<double> animation;
  final double? value;
  final Color color;
  final Color trackColor;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          painter: _MonoProgressPainter(
            value: value ?? 0.72,
            rotation: value == null ? animation.value * math.pi * 2 : 0,
            color: color,
            trackColor: trackColor,
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _MonoProgressPainter extends CustomPainter {
  const _MonoProgressPainter({
    required this.value,
    required this.rotation,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final double rotation;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math
        .max(0.0, size.shortestSide / 2 - strokeWidth / 2)
        .toDouble();
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final indicator = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      rect,
      -math.pi / 2 + rotation,
      math.pi * 2 * value,
      false,
      indicator,
    );
  }

  @override
  bool shouldRepaint(covariant _MonoProgressPainter oldDelegate) {
    return value != oldDelegate.value ||
        rotation != oldDelegate.rotation ||
        color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
