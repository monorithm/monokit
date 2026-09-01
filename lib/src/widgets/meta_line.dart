import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';

/// One fact at a time, on the item's own clock.
///
/// A feed item has more to say about itself than fits on one line — how fresh
/// it is, where it is, which of its photos you are looking at, how long the
/// shop has stood there. Stacking those is a paragraph over someone's media.
/// [MonoMetaLine] shows one, then the next, on the same clock the item already
/// runs, and the set completes **exactly once**: two facts across ten seconds
/// is five each, and nobody misses one.
///
/// Four things that are easy to get wrong and are the whole component:
///
/// * **It reserves the width of its longest fact.** A line that resizes as
///   facts trade drags the caption around under the reader's eye.
/// * **It is not a live region.** The whole set is one label, read once — a
///   live region would interrupt a screen reader every five seconds to say
///   something the user did not ask to hear again.
/// * **It stops when the item stops.** Same clock: a paused post has a still
///   caption. Reduced motion holds the first fact and never starts.
/// * **Never rotate what the user must act on.** A price, an error, a code.
///   Those hold still and always — put them in their own line, not this one.
class MonoMetaLine extends StatefulWidget {
  const MonoMetaLine({
    super.key,
    required this.facts,
    this.semanticLabel,
    this.cycle = const Duration(seconds: 10),
    this.running = true,
    this.onMedia = false,
    this.style,
  });

  /// The facts, in the order they are shown. The first is what a still line
  /// holds — put freshness and place there, and the slower facts after.
  final List<String> facts;

  /// The whole set as one sentence, read once. Defaults to the facts joined
  /// with a full stop; supply your own where the spoken form should differ
  /// from the written one ("400 metres away" for `400m`).
  final String? semanticLabel;

  /// How long the whole set takes. Divided evenly, so the dwell per fact is
  /// this over `facts.length`. Defaults to the ten seconds an immersive feed
  /// item holds, because that is the clock this is riding.
  final Duration cycle;

  /// Whether the clock is running. False holds the current fact — pass the
  /// item's own playing state so a paused post has a still caption.
  final bool running;

  /// Composes over media: the on-media inks rather than the muted ones.
  final bool onMedia;

  final TextStyle? style;

  @override
  State<MonoMetaLine> createState() => _MonoMetaLineState();
}

class _MonoMetaLineState extends State<MonoMetaLine> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Not a constructor assert: `facts.length` is not const-evaluable, and
    // making it one would stop `const MonoMetaLine(...)` compiling in the
    // feed item that builds one per post.
    assert(widget.facts.isNotEmpty, 'A meta line needs at least one fact.');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant MonoMetaLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facts.length != widget.facts.length) {
      _index = _index.clamp(0, widget.facts.length - 1);
    }
    if (oldWidget.running != widget.running ||
        oldWidget.cycle != widget.cycle ||
        oldWidget.facts.length != widget.facts.length) {
      _sync();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// The set completes once. There is no loop to restart, so once the last
  /// fact is showing the timer is done rather than idling.
  void _sync() {
    _timer?.cancel();
    _timer = null;

    final bool stillness =
        !widget.running ||
        widget.facts.length < 2 ||
        MonokitMotion.noAnimation(context);
    if (stillness || _index >= widget.facts.length - 1) return;

    final Duration dwell = Duration(
      microseconds: widget.cycle.inMicroseconds ~/ widget.facts.length,
    );
    _timer = Timer.periodic(dwell, (Timer t) {
      if (!mounted) return;
      setState(() => _index++);
      if (_index >= widget.facts.length - 1) {
        t.cancel();
        _timer = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final TextStyle resolved = (widget.style ?? theme.typography.labelMedium)
        .copyWith(
          color: widget.onMedia
              ? theme.colors.onMediaMuted
              : theme.colors.mutedText,
        );
    // Facts are counts, distances and clock time. Tabular figures keep them
    // from jittering as they trade.
    final TextStyle style = theme.typography.tabular(resolved);

    Widget fact(String text) =>
        Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Semantics(
      container: true,
      // Deliberately not a live region — see the class docs.
      label:
          widget.semanticLabel ??
          widget.facts.join('. ').replaceAll(RegExp(r'\.\.'), '.'),
      child: ExcludeSemantics(
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            // The box is the widest fact, painted invisibly. Without this the
            // line resizes on every swap and the caption crawls.
            for (final String f in widget.facts)
              Opacity(opacity: 0, child: fact(f)),
            AnimatedSwitcher(
              // Enters run one step longer than exits: the leaving fact
              // accelerates up and out, the arriving one decelerates up into
              // place, so the swap reads as words arriving rather than as a
              // second thing moving on the media.
              duration: theme.motion.reduced(context, theme.motion.enter),
              reverseDuration: theme.motion.reduced(
                context,
                theme.motion.state,
              ),
              switchInCurve: theme.motion.decelerate,
              switchOutCurve: theme.motion.accelerate,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    // Both directions rise: the leaving fact continues up and
                    // out, the arriving one comes up into place.
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.35),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_index),
                child: fact(widget.facts[_index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
