import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/monokit_layout.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// One action revealed by swiping a row, or by hovering it at pointer density.
///
/// **Leading is constructive, trailing is destructive.** That is the grammar,
/// and it is not a suggestion: a user who has learned that the left swipe
/// saves and the right swipe deletes has learned it everywhere, and a row that
/// reverses them costs someone a post.
@immutable
class MonoListRowAction {
  const MonoListRowAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final MonoIconData icon;

  /// Shown under the icon, and spoken. Icon-only is not permitted here — a
  /// swipe reveals a shape the user has never been taught.
  final String label;

  final VoidCallback onPressed;

  /// Destructive actions require a hold rather than a tap. See
  /// [MonoListRowSwipe] for why a tap is not enough.
  final bool destructive;
}

/// Wraps a row with the swipe grammar.
///
/// **Touch swipes; pointer hovers.** The same actions, two idioms — a pointer
/// never learns a gesture, so at pointer density the cells appear on hover
/// instead and the row does not drag at all.
///
/// **A destructive action is held, not tapped.** `holdToConfirm` is 800ms, and
/// the label says so while the finger is down. A swipe is already a coarse
/// gesture; pairing it with a single tap to destroy something means a
/// mis-swipe and a mis-tap are one motion apart. The hold is what puts
/// distance between the two.
///
/// At most two cells per side, each [MonokitList.swipeActionCell] wide — 72,
/// deliberately wider than the 44 minimum, because a cell is aimed at while
/// the finger is already moving.
///
/// **The moving layer is opaque, and that is load-bearing.** The cells are not
/// revealed by appearing; they are always there, and the row slides off them.
/// [MonoListRow] paints a fully transparent ground at rest, so a swipe row
/// composed without [ground] shows a green and a red stripe down every row in
/// the list, permanently. The first render of this component did exactly that.
class MonoListRowSwipe extends StatefulWidget {
  const MonoListRowSwipe({
    super.key,
    required this.child,
    this.leading = const <MonoListRowAction>[],
    this.trailing = const <MonoListRowAction>[],
    this.ground,
  });

  final Widget child;

  /// What the row slides over, painted under [child]. Defaults to the page
  /// ground; pass `colors.card` for a row inside a card, so the cells stay
  /// hidden against the surface the row actually sits on.
  final Color? ground;

  /// Constructive actions, revealed by swiping from the leading edge.
  final List<MonoListRowAction> leading;

  /// Destructive actions, revealed by swiping from the trailing edge. Each
  /// marked [MonoListRowAction.destructive] is held rather than tapped.
  final List<MonoListRowAction> trailing;

  @override
  State<MonoListRowSwipe> createState() => _MonoListRowSwipeState();
}

class _MonoListRowSwipeState extends State<MonoListRowSwipe> {
  double _offset = 0;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    assert(
      widget.leading.length <= 2 && widget.trailing.length <= 2,
      'At most two swipe actions per side. A third is not reachable in one '
      'gesture, so it belongs in the row\'s own menu.',
    );
    assert(
      !widget.leading.any((MonoListRowAction a) => a.destructive),
      'Leading is constructive. A destructive action goes on the trailing '
      'edge, where the grammar has taught the user to expect it.',
    );
  }

  double get _leadingExtent =>
      widget.leading.length * MonokitList.swipeActionCell;
  double get _trailingExtent =>
      widget.trailing.length * MonokitList.swipeActionCell;

  void _onUpdate(DragUpdateDetails d) {
    final double next = _offset + d.delta.dx;
    // Rubber-band past the end stops rather than hard-clamping: the row still
    // answers the finger, it just stops promising more than it has.
    final double clamped = next > _leadingExtent
        ? _leadingExtent + (next - _leadingExtent) * _rubberBand
        : next < -_trailingExtent
        ? -_trailingExtent + (next + _trailingExtent) * _rubberBand
        : next;
    setState(() => _offset = clamped);
  }

  static const double _rubberBand = 0.55;
  static const double _commitFraction = 0.30;
  static const double _commitVelocity = 700;

  void _onEnd(DragEndDetails d) {
    final double v = d.velocity.pixelsPerSecond.dx;
    final double extent = _offset > 0 ? _leadingExtent : _trailingExtent;
    if (extent == 0) {
      setState(() => _offset = 0);
      return;
    }
    final bool travelled = _offset.abs() > extent * _commitFraction;
    final bool flicked = v.abs() > _commitVelocity;
    final bool open = flicked
        ? (v > 0) == (_offset > 0) && _offset != 0
        : travelled;
    setState(() {
      _offset = open ? (_offset > 0 ? _leadingExtent : -_trailingExtent) : 0;
    });
  }

  void _close() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final bool isTouch = theme.density.isTouch;
    final bool rtl = Directionality.of(context) == TextDirection.rtl;

    // At pointer the cells are revealed by hover, not by a drag. The pointer
    // never learns a gesture.
    final double revealed = isTouch
        ? _offset
        : _hovered
        ? -_trailingExtent
        : 0;

    Widget cells(List<MonoListRowAction> actions, bool atLeadingEdge) {
      if (actions.isEmpty) return const SizedBox.shrink();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final MonoListRowAction a in actions)
            _SwipeCell(action: a, onDone: _close),
        ],
      );
    }

    final Widget row = ClipRect(
      // A row dragged past its stops would otherwise paint over its
      // neighbours.
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            top: 0,
            bottom: 0,
            start: 0,
            child: cells(widget.leading, true),
          ),
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            child: cells(widget.trailing, false),
          ),
          Transform.translate(
            offset: Offset(rtl ? -revealed : revealed, 0),
            child: ColoredBox(
              color: widget.ground ?? theme.colors.background,
              child: widget.child,
            ),
          ),
        ],
      ),
    );

    if (!isTouch) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: row,
      );
    }

    return GestureDetector(
      // Opaque: the whole row answers the finger. deferToChild would mean a
      // swipe that started on the gap between the title and the chevron
      // reached nothing.
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: _onUpdate,
      onHorizontalDragEnd: _onEnd,
      child: row,
    );
  }
}

/// One action cell. Destructive cells are held; the rest are tapped.
class _SwipeCell extends StatefulWidget {
  const _SwipeCell({required this.action, required this.onDone});

  final MonoListRowAction action;
  final VoidCallback onDone;

  @override
  State<_SwipeCell> createState() => _SwipeCellState();
}

class _SwipeCellState extends State<_SwipeCell> {
  Timer? _hold;
  bool _holding = false;

  /// `interaction.timings.holdToConfirm` — medium-risk destructive controls.
  static const Duration _holdToConfirm = Duration(milliseconds: 800);

  @override
  void dispose() {
    _hold?.cancel();
    super.dispose();
  }

  void _startHold() {
    setState(() => _holding = true);
    _hold = Timer(_holdToConfirm, () {
      if (!mounted) return;
      setState(() => _holding = false);
      widget.action.onPressed();
      widget.onDone();
    });
  }

  void _cancelHold() {
    _hold?.cancel();
    _hold = null;
    if (_holding) setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final a = widget.action;
    final Color ground = a.destructive
        ? theme.colors.destructive
        : theme.colors.primary;
    final Color ink = a.destructive
        ? theme.colors.destructiveForeground
        : theme.colors.primaryForeground;

    // While held, the label says what is happening. A progress bar would be a
    // second thing to read; the word is enough and it is already there.
    final String label = _holding ? theme.labels.holding : a.label;

    return Semantics(
      button: true,
      label: a.destructive ? '${a.label}. Hold to confirm' : a.label,
      onTap: a.destructive ? null : _fire,
      // A raw Listener rather than long-press callbacks. A sustain is not a
      // long press: the hold begins the instant the finger lands and ends the
      // instant it lifts, with no recognizer arena in between deciding whether
      // the gesture "counted". onLongPressUp only fires once a long press has
      // been recognised, so a release at 300ms went unheard entirely.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: a.destructive ? (_) => _startHold() : null,
        onPointerUp: a.destructive ? (_) => _cancelHold() : null,
        onPointerCancel: a.destructive ? (_) => _cancelHold() : null,
        // A finger that slides off is a finger that changed its mind.
        onPointerMove: a.destructive
            ? (PointerMoveEvent e) {
                if (e.delta.distance > 2) _cancelHold();
              }
            : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: a.destructive ? null : _fire,
          child: Container(
            width: MonokitList.swipeActionCell,
            alignment: Alignment.center,
            color: ground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MonoIcon(a.icon, color: ink),
                SizedBox(height: theme.spacing.xs),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.labelMedium.copyWith(color: ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _fire() {
    widget.action.onPressed();
    widget.onDone();
  }
}
