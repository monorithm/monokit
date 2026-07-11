import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

/// Demo state for the primitives section.
class PrimitivesState extends ChangeNotifier {
  final MonoStatesController states = MonoStatesController();
  final MonoOverlayController overlayController = MonoOverlayController();
  MonoOverlayHandle? _overlayHandle;
  bool _focusRing = false;

  bool get focusRing => _focusRing;

  void toggleState(MonoState state) {
    states.toggle(state);
    notifyListeners();
  }

  void toggleFocusRing() {
    _focusRing = !_focusRing;
    notifyListeners();
  }

  void showRawOverlay() {
    if (_overlayHandle?.isMounted ?? false) {
      return;
    }
    _overlayHandle = overlayController.showBuilder(
      (overlayContext) => Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: MonoAlert(
            variant: MonoAlertVariant.info,
            title: const Text('MonoOverlayHandle'),
            description: const Text(
              'This surface is managed by MonoOverlayController.',
            ),
            action: MonoPressable(
              onPressed: () => _overlayHandle?.dismiss(),
              child: (context, states) => const Text('Dismiss'),
            ),
          ),
        ),
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    states.dispose();
    overlayController.dispose();
    super.dispose();
  }
}

class PrimitivesScope extends InheritedNotifier<PrimitivesState> {
  const PrimitivesScope({
    super.key,
    required PrimitivesState state,
    required super.child,
  }) : super(notifier: state);

  static PrimitivesState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PrimitivesScope>();
    assert(scope != null, 'No PrimitivesScope found in context.');
    return scope!.notifier!;
  }
}
