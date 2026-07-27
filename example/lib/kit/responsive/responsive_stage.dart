import 'package:monokit/monokit.dart';

/// A named breakpoint preset, resolved live against [MonokitBreakpoints].
class _Preset {
  const _Preset(this.label, this.width);
  final String label;
  final double width;
}

const List<_Preset> _presets = <_Preset>[
  _Preset('Compact', 375),
  _Preset('Medium', 768),
  _Preset('Expanded', 1024),
  _Preset('Wide', 1440),
];

/// The interactive breakpoint stage — the showcase's headline demonstration
/// device. A component sits inside a frame whose width the user can drag or snap
/// to a preset; the framed subtree is given an overridden [MediaQuery] so real
/// Monokit widgets (which read `MediaQuery`/`LayoutBuilder`) reflow *live* at the
/// chosen width. The active breakpoint is named against [theme.breakpoints].
class ResponsiveStage extends StatefulWidget {
  const ResponsiveStage({
    super.key,
    required this.child,
    this.height = 440,
    this.initialWidth = 1024,
    this.minWidth = 320,
  });

  /// The component under test. Rebuilt inside the overridden [MediaQuery].
  final Widget child;

  /// Fixed height of the stage viewport, in logical pixels.
  final double height;

  /// Starting frame width.
  final double initialWidth;

  /// Smallest frame width the handle allows.
  final double minWidth;

  @override
  State<ResponsiveStage> createState() => _ResponsiveStageState();
}

class _ResponsiveStageState extends State<ResponsiveStage> {
  late double _width = widget.initialWidth;

  String _breakpointName(MonokitBreakpoints bp, double w) {
    if (w < bp.compact) return 'compact';
    if (w < bp.medium) return 'medium';
    if (w < bp.expanded) return 'expanded';
    return 'wide';
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final bp = theme.breakpoints;

    return LayoutBuilder(
      builder: (context, constraints) {
        // On a compact outer viewport the drag-stage adds no value (you are
        // already at a small breakpoint) and its frame would crush the child.
        // Degrade to a plain, full-width framed child.
        if (constraints.maxWidth < bp.medium) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.page,
              borderRadius: BorderRadius.circular(theme.radii.md),
              border: Border.all(color: theme.colors.separator),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radii.md),
              child: SizedBox(height: widget.height, child: widget.child),
            ),
          );
        }
        const handleWidth = 20.0;
        // The frame Row lives inside the stage's padding, so the space actually
        // available to the frame is the outer width minus that padding and the
        // drag handle. Subtracting both keeps the Row from overflowing when the
        // frame is dragged to its maximum.
        final chrome = handleWidth + theme.spacing.md * 2;
        final maxWidth = (constraints.maxWidth - chrome).clamp(
          widget.minWidth,
          double.infinity,
        );
        final width = _width.clamp(widget.minWidth, maxWidth);
        final name = _breakpointName(bp, width);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Toolbar(
              // The clamped width drives the readout; the intended width drives
              // which preset reads as active (so a preset wider than the pane
              // doesn't collide with another that clamped to the same max).
              width: width,
              intendedWidth: _width,
              breakpoint: name,
              onPreset: (w) => setState(() => _width = w),
            ),
            SizedBox(height: theme.spacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.fill,
                borderRadius: BorderRadius.circular(theme.radii.lg),
                border: Border.all(color: theme.colors.separator),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: SizedBox(
                  height: widget.height,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _Frame(
                        width: width,
                        height: widget.height,
                        child: widget.child,
                      ),
                      _DragHandle(
                        onDrag: (dx) => setState(() {
                          _width = (width + dx).clamp(
                            widget.minWidth,
                            maxWidth,
                          );
                        }),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.width,
    required this.intendedWidth,
    required this.breakpoint,
    required this.onPreset,
  });

  final double width;
  final double intendedWidth;
  final String breakpoint;
  final ValueChanged<double> onPreset;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Wrap(
      spacing: theme.spacing.sm,
      runSpacing: theme.spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final preset in _presets)
          // MonoButton fills bounded width; IntrinsicWidth keeps each preset a
          // shrink-wrapped chip inside the Wrap.
          IntrinsicWidth(
            child: MonoButton(
              variant: (intendedWidth - preset.width).abs() < 1
                  ? MonoButtonVariant.secondary
                  : MonoButtonVariant.ghost,
              size: MonoButtonSize.sm,
              onPressed: () => onPreset(preset.width),
              child: Text(preset.label),
            ),
          ),
        MonoBadge(
          variant: MonoBadgeVariant.outline,
          child: Text('$breakpoint · ${width.round()}pt'),
        ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.page,
          borderRadius: BorderRadius.circular(theme.radii.md),
          border: Border.all(color: theme.colors.separator),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radii.md),
          child: MediaQuery(
            // The subtree believes it lives in a `width`-wide, inset-free
            // viewport, so MonoScreen and anchored overlays reflow authentically.
            data: media.copyWith(
              size: Size(width, height),
              padding: EdgeInsets.zero,
              viewPadding: EdgeInsets.zero,
              viewInsets: EdgeInsets.zero,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.onDrag});
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => onDrag(d.delta.dx),
        child: SizedBox(
          width: 20,
          child: Center(
            child: Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colors.foregroundMuted,
                borderRadius: BorderRadius.circular(theme.radii.full),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
