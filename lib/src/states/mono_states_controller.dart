import 'package:flutter/foundation.dart';

import 'mono_state.dart';

/// A small, framework-neutral controller for interactive component state.
class MonoStatesController extends ChangeNotifier {
  MonoStatesController([
    Iterable<MonoState> initialStates = const <MonoState>[],
  ]) : _states = Set<MonoState>.of(initialStates);

  final Set<MonoState> _states;

  /// An immutable snapshot of the active states.
  Set<MonoState> get states => Set<MonoState>.unmodifiable(_states);

  bool contains(MonoState state) => _states.contains(state);

  bool update(MonoState state, bool value) {
    final didChange = value ? _states.add(state) : _states.remove(state);
    if (didChange) {
      notifyListeners();
    }
    return didChange;
  }

  bool add(MonoState state) => update(state, true);

  bool remove(MonoState state) => update(state, false);

  bool toggle(MonoState state) => update(state, !_states.contains(state));

  void setAll(Iterable<MonoState> states) {
    final next = Set<MonoState>.of(states);
    if (setEquals(_states, next)) {
      return;
    }
    _states
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void clear() {
    if (_states.isEmpty) {
      return;
    }
    _states.clear();
    notifyListeners();
  }
}
