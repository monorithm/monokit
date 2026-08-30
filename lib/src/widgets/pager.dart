import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../motion/mono_spring_controller.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// A real swipe, not a carousel.
///
/// The track follows the finger continuously, resists past the end stops, and
/// settles on the spatial spring seeded by the release velocity. Three details
/// are the whole component:
///
/// * **Commit is measured, not remembered.** Travel is read from the value the
///   gesture is accumulating, never from a value captured in an earlier build.
///   A flick whose move and release land in the same frame would otherwise be
///   judged on stale travel and silently refuse to commit — which reads to the
///   user as the widget ignoring them.
/// * **One axis.** Horizontal drag is claimed; vertical is left alone, so a
///   pager nested in a scroll view does not fight it. One gesture axis per
///   region is settled at design time, never by recognizer arbitration at
///   runtime.
/// * **The alternatives ship with the gesture.** Arrow keys always, and
///   chevrons at pointer density. A gesture without an equivalent is not
///   finished — it is a feature only some people have.
class MonoPager extends StatefulWidget {
  const MonoPager({
    super.key,
    required this.children,
    this.index = 0,
    this.onIndexChanged,
    this.semanticLabel,
  }) : assert(children.length > 0, 'A pager needs at least one pane.');

  /// One widget per pane.
  final List<Widget> children;

  /// The active pane. Controlled: keep it in your own state and update it from
  /// [onIndexChanged].
  final int index;

  final ValueChanged<int>? onIndexChanged;

  final String? semanticLabel;

  /// Commit past this fraction of the pager's width.
  static const double commitFraction = 0.3;

  /// …or above this release velocity, in logical pixels per second, however
  /// short the travel.
  static const double commitVelocity = 700;

  /// How much of a drag past the first or last pane is actually applied.
  static const double rubberBand = 0.55;

  @override
  State<MonoPager> createState() => _MonoPagerState();
}

class _MonoPagerState extends State<MonoPager>
    with SingleTickerProviderStateMixin {
  late final MonoSpringController _offset = MonoSpringController(vsync: this);

  /// Live drag travel in logical pixels. Deliberately a field and not state:
  /// the commit decision reads this, and it must be the value the gesture just
  /// wrote rather than whatever the last build saw.
  double _drag = 0;
  double _width = 1;

  final FocusNode _focus = FocusNode(debugLabel: 'MonoPager');

  @override
  void dispose() {
    _offset.dispose();
    _focus.dispose();
    super.dispose();
  }

  int get _last => widget.children.length - 1;

  void _go(int to) {
    final clamped = to.clamp(0, _last);
    if (clamped != widget.index) widget.onIndexChanged?.call(clamped);
  }

  void _onUpdate(DragUpdateDetails d) {
    var dx = d.delta.dx;
    final atStart = widget.index == 0 && _drag + dx > 0;
    final atEnd = widget.index == _last && _drag + dx < 0;
    if (atStart || atEnd) dx *= MonoPager.rubberBand;
    _drag += dx;
    _offset.jumpTo(_drag);
  }

  void _onEnd(DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dx;
    final travelled = _drag.abs() > _width * MonoPager.commitFraction;
    final flicked = velocity.abs() > MonoPager.commitVelocity;

    if (travelled || flicked) {
      // Direction comes from whichever signal fired. A flick is more recent
      // than the accumulated travel, so it wins when the two disagree.
      final backwards = flicked ? velocity > 0 : _drag > 0;
      _go(widget.index + (backwards ? -1 : 1));
    }

    _drag = 0;
    final theme = MonokitTheme.of(context);
    _offset.animateTo(
      0,
      spring: theme.motion.reducedSpring(context, theme.motion.spatial),
      withVelocity: velocity,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowLeft => _step(rtl ? 1 : -1),
      LogicalKeyboardKey.arrowRight => _step(rtl ? -1 : 1),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _step(int by) {
    _go(widget.index + by);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final showChevrons = !theme.density.isTouch;

    return Semantics(
      label: widget.semanticLabel,
      container: true,
      child: Focus(
        focusNode: _focus,
        onKeyEvent: _onKey,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            _width = constraints.maxWidth <= 0 ? 1 : constraints.maxWidth;
            return ClipRect(
              // The panes fill the pager, so the drag surface is the whole
              // frame rather than only as tall as the tallest child. A pager
              // you can only swipe on the text inside it is not a pager.
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: _onUpdate,
                    onHorizontalDragEnd: _onEnd,
                    // The track is deliberately wider than the frame — that
                    // is what makes it a track — so it is allowed to overflow
                    // and the ClipRect above trims it.
                    child: OverflowBox(
                      alignment: AlignmentDirectional.centerStart,
                      maxWidth: double.infinity,
                      child: AnimatedBuilder(
                        animation: _offset,
                        builder: (BuildContext context, Widget? child) {
                          return Transform.translate(
                            offset: Offset(
                              -widget.index * _width + _offset.value,
                              0,
                            ),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            for (int i = 0; i < widget.children.length; i++)
                              SizedBox(
                                width: _width,
                                child: ExcludeSemantics(
                                  excluding: i != widget.index,
                                  child: widget.children[i],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (showChevrons) ..._chevrons(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _chevrons(BuildContext context) {
    final theme = MonokitTheme.of(context);
    Widget arrow({required bool back, required AlignmentGeometry alignment}) {
      final enabled = back ? widget.index > 0 : widget.index < _last;
      return Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.sm),
          child: GestureDetector(
            onTap: enabled ? () => _step(back ? -1 : 1) : null,
            child: Opacity(
              opacity: enabled ? 1 : 0.35,
              child: MonoIcon(
                back ? MonoIcons.chevronLeft : MonoIcons.chevronRight,
                tooltip: back ? 'Previous' : 'Next',
              ),
            ),
          ),
        ),
      );
    }

    return <Widget>[
      arrow(back: true, alignment: AlignmentDirectional.centerStart),
      arrow(back: false, alignment: AlignmentDirectional.centerEnd),
    ];
  }
}
