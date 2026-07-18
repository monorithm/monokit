import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Wraps an overlay's content so it fades **in** on mount and **out** on close,
/// instead of snapping. When [visible] flips false the wrapper reverses its
/// transition and calls [onExited] once it settles — the owner then removes the
/// `OverlayEntry`. Honors reduced-motion (collapses to an instant swap).
///
/// Layout-transparent, so an anchored follower inside still positions normally.
class MonoOverlayFade extends StatefulWidget {
  const MonoOverlayFade({
    super.key,
    required this.visible,
    required this.onExited,
    required this.child,
    this.duration,
  });

  final bool visible;
  final VoidCallback onExited;
  final Widget child;
  final Duration? duration;

  @override
  State<MonoOverlayFade> createState() => _MonoOverlayFadeState();
}

class _MonoOverlayFadeState extends State<MonoOverlayFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener(_onStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = MonokitTheme.of(context);
    _controller.duration = theme.motion.reduced(
      context,
      widget.duration ?? theme.motion.base,
    );
    if (widget.visible && _controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant MonoOverlayFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.visible) {
      widget.onExited();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _controller,
        curve: MonokitTheme.of(context).motion.standard,
      ),
      child: widget.child,
    );
  }
}
