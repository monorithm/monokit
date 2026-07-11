import 'package:flutter/widgets.dart';

/// Demo state for the overlays section.
///
/// Holds the controlled open flags for the composed dialog and alert dialog,
/// plus the most recent menu/command action label. Every mutation notifies
/// listeners so the [OverlaysScope] subtree rebuilds, mirroring the original
/// `setState` behavior.
class OverlaysState extends ChangeNotifier {
  bool _dialogOpen = false;
  bool get dialogOpen => _dialogOpen;
  void setDialogOpen(bool value) {
    _dialogOpen = value;
    notifyListeners();
  }

  bool _alertDialogOpen = false;
  bool get alertDialogOpen => _alertDialogOpen;
  void setAlertDialogOpen(bool value) {
    _alertDialogOpen = value;
    notifyListeners();
  }

  String _lastAction = 'No menu action has been selected yet.';
  String get lastAction => _lastAction;
  void recordAction(String action) {
    _lastAction = action;
    notifyListeners();
  }
}

class OverlaysScope extends InheritedNotifier<OverlaysState> {
  const OverlaysScope({
    super.key,
    required OverlaysState state,
    required super.child,
  }) : super(notifier: state);

  static OverlaysState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OverlaysScope>();
    assert(scope != null, 'No OverlaysScope found in context.');
    return scope!.notifier!;
  }
}
