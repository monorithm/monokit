import 'package:flutter/widgets.dart';

import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';

/// A chat-focused scroll view that can stay pinned to the newest message.
///
/// When [autoScroll] is enabled, newly appended children advance the viewport
/// only if the reader was already near the latest message. That preserves a
/// reader's position while they inspect earlier history.
class MonoMessageScroller extends StatefulWidget {
  const MonoMessageScroller({
    super.key,
    this.children = const <Widget>[],
    this.controller,
    this.padding,
    this.physics,
    this.primary,
    this.reverse = false,
    this.shrinkWrap = false,
    this.clipBehavior = Clip.hardEdge,
    this.autoScroll = true,
    this.initialScrollToEnd = true,
    this.keepAtEndThreshold,
    this.scrollDuration,
    this.scrollCurve,
    this.onNearEndChanged,
    this.semanticLabel = 'Messages',
    this.empty,
  }) : assert(
         controller == null || primary != true,
         'A controller cannot be supplied when primary is true.',
       ),
       assert(keepAtEndThreshold == null || keepAtEndThreshold >= 0);

  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? primary;
  final bool reverse;
  final bool shrinkWrap;
  final Clip clipBehavior;

  /// Automatically follows appended messages while the reader is at the end.
  final bool autoScroll;
  final bool initialScrollToEnd;

  /// Distance in logical pixels that still counts as being at the latest end.
  final double? keepAtEndThreshold;
  final Duration? scrollDuration;
  final Curve? scrollCurve;
  final ValueChanged<bool>? onNearEndChanged;
  final String? semanticLabel;
  final Widget? empty;

  @override
  State<MonoMessageScroller> createState() => _MonoMessageScrollerState();
}

class _MonoMessageScrollerState extends State<MonoMessageScroller> {
  late ScrollController _controller;
  late bool _ownsController;
  bool _wasNearEnd = true;

  @override
  void initState() {
    super.initState();
    _setController(widget.controller);
    if (widget.initialScrollToEnd) {
      _scheduleScrollToEnd(force: true);
    }
  }

  @override
  void didUpdateWidget(covariant MonoMessageScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detachController();
      _setController(widget.controller);
      if (widget.initialScrollToEnd) {
        _scheduleScrollToEnd(force: true);
      }
      return;
    }

    final childrenAppended = widget.children.length > oldWidget.children.length;
    if (widget.autoScroll && childrenAppended && _wasNearEnd) {
      // Capture the old position before the new layout expands maxScrollExtent.
      _scheduleScrollToEnd(force: true);
    }
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _setController(ScrollController? supplied) {
    _ownsController = supplied == null;
    _controller = supplied ?? ScrollController();
    _controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNearEnd());
  }

  void _detachController() {
    _controller.removeListener(_handleScroll);
    if (_ownsController) {
      _controller.dispose();
    }
  }

  double _threshold(BuildContext context) {
    return widget.keepAtEndThreshold ?? MonokitTheme.of(context).spacing.huge;
  }

  bool _isNearEnd() {
    if (!_controller.hasClients) {
      return true;
    }
    final position = _controller.position;
    final threshold = _threshold(context);
    if (widget.reverse) {
      return position.pixels <= position.minScrollExtent + threshold;
    }
    return position.pixels >= position.maxScrollExtent - threshold;
  }

  void _handleScroll() => _syncNearEnd();

  void _syncNearEnd() {
    if (!mounted) {
      return;
    }
    final nearEnd = _isNearEnd();
    if (nearEnd == _wasNearEnd) {
      return;
    }
    _wasNearEnd = nearEnd;
    widget.onNearEndChanged?.call(nearEnd);
  }

  void _scheduleScrollToEnd({required bool force}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients || (!force && !_wasNearEnd)) {
        return;
      }
      final position = _controller.position;
      final target = widget.reverse
          ? position.minScrollExtent
          : position.maxScrollExtent;
      final theme = MonokitTheme.of(context);
      final motionDisabled = MonokitMotion.noAnimation(context);
      final duration = widget.scrollDuration ?? theme.motion.duration;
      if (motionDisabled || duration == Duration.zero) {
        _controller.jumpTo(target);
      } else {
        _controller.animateTo(
          target,
          duration: duration,
          curve: widget.scrollCurve ?? theme.motion.curve,
        );
      }
      _syncNearEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final content = widget.children.isEmpty && widget.empty != null
        ? widget.empty!
        : ListView(
            controller: _controller,
            padding:
                widget.padding ??
                EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.md,
                ),
            physics: widget.physics,
            primary: widget.primary,
            reverse: widget.reverse,
            shrinkWrap: widget.shrinkWrap,
            clipBehavior: widget.clipBehavior,
            children: widget.children,
          );
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      child: content,
    );
  }
}
