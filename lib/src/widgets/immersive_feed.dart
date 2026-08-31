import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../primitives/mono_width_scope.dart';
import '../theme/monokit_layout.dart';
import '../theme/monokit_theme.dart';

/// How near an item is to the viewport, for its own resource decisions.
///
/// The feed owns windowing; the item owns its media. An [active] item decodes
/// and plays; a [near] item may prefetch (never under data-saver); a [far]
/// item releases what it holds. This split keeps the memory contract in one
/// place while leaving codec choices to the tenant.
enum MonoFeedItemPhase { active, near, far }

/// Builds one feed item, told how near it is to the viewport.
typedef MonoFeedItemBuilder =
    Widget Function(BuildContext context, int index, MonoFeedItemPhase phase);

/// A full-viewport vertical media feed — a primitive, not a component.
///
/// From the proposal register (ImmersiveFeed):
///
/// * **Layout.** One item fills the viewport; the feed snaps per item. The
///   item presentation composes as the child; the feed imposes no chrome.
/// * **Gesture.** Vertical swipe advances and is the only gesture axis in the
///   region. Arrow keys and page up/down are first-class alternatives; the
///   mouse wheel pages through the host's scroll behavior.
/// * **Resource policy.** The builder receives a [MonoFeedItemPhase]; the
///   current item is [MonoFeedItemPhase.active], its immediate neighbours are
///   [MonoFeedItemPhase.near] and are kept alive for prefetch, everything
///   else is released by the viewport. Under [dataSaver] neighbours are not
///   kept alive — prefetch depth is a mode decision, not an optimisation.
/// * **Exposure.** The feed emits [onExposure] once per settled item — it is
///   the only thing that knows what was actually seen. The initial item
///   counts as seen.
/// * **Reduced motion.** Keyboard paging jumps without animated physics;
///   nothing is removed.
/// * **State restoration.** Give the feed a [restorationId] and the position
///   survives navigation away and back.
class MonoImmersiveFeed extends StatefulWidget {
  const MonoImmersiveFeed({
    super.key,
    this.itemCount,
    required this.itemBuilder,
    this.onExposure,
    this.dataSaver = false,
    this.initialIndex = 0,
    this.restorationId,
    this.semanticLabel = 'Feed',
  }) : assert(itemCount == null || itemCount >= 0),
       assert(initialIndex >= 0);

  /// Number of items, or null for an unbounded feed.
  final int? itemCount;

  final MonoFeedItemBuilder itemBuilder;

  /// Called with an item's index each time it becomes the settled, visible
  /// item. Any "seen" metric belongs on this event.
  final ValueChanged<int>? onExposure;

  /// When true, neighbours are not kept alive and items should not prefetch.
  /// The mode is a first-class input: pass it down, don't infer it.
  final bool dataSaver;

  /// The item shown first when no restored position exists.
  final int initialIndex;

  /// Restoration bucket for the feed position.
  final String? restorationId;

  final String semanticLabel;

  @override
  State<MonoImmersiveFeed> createState() => _MonoImmersiveFeedState();
}

/// Page physics that never travels past the adjacent item: the fling's
/// direction picks the neighbour, its energy is spent on the settle.
class _SnapPerItemPhysics extends PageScrollPhysics {
  const _SnapPerItemPhysics({super.parent});

  @override
  _SnapPerItemPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapPerItemPhysics(parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    final page = position.pixels / position.viewportDimension;
    final double targetPage;
    if (velocity < -tolerance.velocity) {
      targetPage = page.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      targetPage = page.ceilToDouble();
    } else {
      targetPage = page.roundToDouble();
    }
    final target = (targetPage * position.viewportDimension).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}

class _MonoImmersiveFeedState extends State<MonoImmersiveFeed>
    with RestorationMixin {
  late final RestorableInt _index = RestorableInt(widget.initialIndex);
  PageController? _controller;
  bool _announcedInitial = false;

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_index, 'index');
    _controller ??= PageController(initialPage: _index.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Restoration may be disabled for the subtree; the controller must exist
    // either way.
    _controller ??= PageController(initialPage: _index.value);
    if (!_announcedInitial) {
      _announcedInitial = true;
      final count = widget.itemCount;
      if (count == null || _index.value < count) {
        final initial = _index.value;
        _lastExposed = initial;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onExposure?.call(initial);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _index.dispose();
    super.dispose();
  }

  MonoFeedItemPhase _phaseFor(int index) {
    final distance = (index - _index.value).abs();
    if (distance == 0) return MonoFeedItemPhase.active;
    if (distance == 1) return MonoFeedItemPhase.near;
    return MonoFeedItemPhase.far;
  }

  int _lastExposed = -1;

  void _onPageChanged(int index) {
    // Re-phase as the viewport moves; exposure waits for the settle — an
    // item scrolled past was never actually seen.
    if (index == _index.value) return;
    setState(() => _index.value = index);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final page = _controller?.page;
      if (page != null) {
        final settled = page.round();
        if (settled != _lastExposed) {
          _lastExposed = settled;
          widget.onExposure?.call(settled);
        }
      }
    }
    return false;
  }

  void _page(int delta) {
    final controller = _controller!;
    final target = _index.value + delta;
    final count = widget.itemCount;
    if (target < 0 || (count != null && target >= count)) return;
    if (MonokitMotion.noAnimation(context)) {
      controller.jumpToPage(target);
      return;
    }
    final motion = MonokitTheme.of(context).motion;
    controller.animateToPage(
      target,
      duration: motion.slow,
      curve: motion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Compact is full bleed. At medium and up the column caps and centres —
    // the letterboxing MonoRecomposition draws, and the reason
    // `MonokitContainers.feed` exists: "the reason a post does not stretch to
    // 1200px on a tablet". Width buys context around the subject, never a
    // wider subject.
    final bool letterboxed = MonoWidthScope.of(
      context,
    ).atLeast(MonoWidthClass.medium);

    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowDown:
            case LogicalKeyboardKey.pageDown:
              _page(1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowUp:
            case LogicalKeyboardKey.pageUp:
              _page(-1);
              return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            // Snap per item: one swipe advances one item, however hard the
            // fling. Skipping items would also corrupt the exposure record.
            // Page snapping is off because the default snap physics would
            // wrap these and take the ballistic back over.
            pageSnapping: false,
            physics: const _SnapPerItemPhysics(),
            // Keeping the neighbour alive is what "prefetch" means at the
            // widget layer; data-saver turns it off.
            allowImplicitScrolling: !widget.dataSaver,
            itemCount: widget.itemCount,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final Widget item = widget.itemBuilder(
                context,
                index,
                _phaseFor(index),
              );
              if (!letterboxed) return item;
              // Inside the column the item is compact again, whatever the
              // window is: a 480 measure composes like a phone.
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: MonokitContainers.feed,
                  ),
                  child: MonoWidthScope(
                    width: MonokitContainers.feed,
                    child: item,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
