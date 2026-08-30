import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_focus_trap.dart';
import '../primitives/mono_overlay_focus.dart';
import '../theme/monokit_theme.dart';

/// The overlay primitive.
///
/// Any surface that covers content and takes the user's whole attention routes
/// through here, so the four things a modal owes are implemented once rather
/// than four times slightly differently:
///
/// 1. A focus trap for its lifetime.
/// 2. A background excluded from focus, pointer **and** semantics *together* —
///    excluding one and not the others leaves the overlay reachable by the
///    modality that was missed, which is how a "modal" ends up dismissible by
///    a screen reader and nothing else.
/// 3. Focus restored to whatever opened it, if that is still on screen.
/// 4. A dismiss control assistive technology can actually find. A bare tap
///    target is invisible to it, which turns every modal into a trap with no
///    announced exit.
///
/// **It does not manage its own presence.** A surface that animates out has to
/// outlive its own open state, so the consumer decides when `MonoModal` is
/// mounted: it arms on mount and restores on unmount. That also means the
/// composing surface owns its position and motion, and entry, gesture and exit
/// have a single driver.
class MonoModal extends StatefulWidget {
  const MonoModal({
    super.key,
    required this.child,
    required this.onClose,
    this.semanticLabel,
    this.barrierLabel,
    this.barrierOpacity = 1.0,
    this.placement = MonoModalPlacement.center,
    this.dismissible = true,
  });

  /// The surface. Not wrapped: the consumer's own element carries the dialog
  /// role and the transform, so nothing sits between the layer and the surface.
  final Widget child;

  final VoidCallback onClose;

  /// The accessible name of the surface.
  final String? semanticLabel;

  /// The accessible name of the dismiss barrier. Defaults to the theme's
  /// `close` label rather than a hardcoded English string.
  final String? barrierLabel;

  /// So a drag can drive the barrier's opacity without the modal owning the
  /// gesture.
  final double barrierOpacity;

  final MonoModalPlacement placement;

  /// Whether Escape and the barrier dismiss. A modal that must be answered
  /// sets this false — and then owes the user an explicit way out inside the
  /// surface.
  final bool dismissible;

  @override
  State<MonoModal> createState() => _MonoModalState();
}

/// Where the surface sits in the layer.
enum MonoModalPlacement { center, end }

class _MonoModalState extends State<MonoModal> {
  final MonoOverlayFocusController _focus = MonoOverlayFocusController();

  @override
  void initState() {
    super.initState();
    // Capture the trigger *before* anything excludes the background: exclusion
    // blurs whatever had focus, so reading it afterwards reads nothing.
    _focus.captureForOpen();
    _focus.requestRestoreOnClose();
  }

  @override
  void dispose() {
    _focus.restoreIfRequested(mounted: false);
    super.dispose();
  }

  void _dismiss() {
    if (widget.dismissible) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final labels = theme.labels;

    // Shortcuts sits *above* the focus trap on purpose. A key event travels
    // up from whatever holds focus, and the trap's scope is what holds it — so
    // a Shortcuts placed inside the trap is never on the path and Escape
    // silently does nothing.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (DismissIntent intent) {
              _dismiss();
              return null;
            },
          ),
        },
        child: MonoFocusTrap(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // The barrier is a real, labelled control — not a bare gesture
              // target. It is first in the layer so the surface's own content
              // is traversed before the exit: the way out is the last stop,
              // not the first thing between the user and the surface.
              Semantics(
                container: true,
                label: widget.barrierLabel ?? labels.close,
                button: true,
                onTap: widget.dismissible ? _dismiss : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.dismissible ? _dismiss : null,
                  child: Opacity(
                    opacity: widget.barrierOpacity.clamp(0.0, 1.0),
                    child: ColoredBox(color: theme.colors.overlayScrim),
                  ),
                ),
              ),
              Align(
                alignment: switch (widget.placement) {
                  MonoModalPlacement.center => Alignment.center,
                  MonoModalPlacement.end => Alignment.bottomCenter,
                },
                child: Semantics(
                  scopesRoute: true,
                  explicitChildNodes: true,
                  namesRoute: widget.semanticLabel != null,
                  label: widget.semanticLabel,
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Applies the exclusion triad to background content while a modal is open.
///
/// The three have to move together. Excluding semantics alone leaves the
/// background clickable; excluding pointer alone leaves it announced and
/// focusable. There is no correct subset.
class MonoModalBarrierScope extends StatelessWidget {
  const MonoModalBarrierScope({
    super.key,
    required this.child,
    required this.excluded,
  });

  final Widget child;

  /// Whether a modal is currently covering this content.
  final bool excluded;

  @override
  Widget build(BuildContext context) {
    if (!excluded) return child;
    return ExcludeFocus(
      child: IgnorePointer(child: ExcludeSemantics(child: child)),
    );
  }
}
