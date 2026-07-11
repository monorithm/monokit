import 'package:flutter/widgets.dart';

/// Demo state for the actions & feedback section.
class FeedbackState extends ChangeNotifier {
  double _progress = 0.62;
  bool _skeletonsAnimate = true;

  double get progress => _progress;
  bool get skeletonsAnimate => _skeletonsAnimate;

  void advanceProgress() {
    _progress += 0.1;
    if (_progress > 1) {
      _progress = 0;
    }
    notifyListeners();
  }

  void setSkeletonsAnimate(bool value) {
    _skeletonsAnimate = value;
    notifyListeners();
  }
}

class FeedbackScope extends InheritedNotifier<FeedbackState> {
  const FeedbackScope({
    super.key,
    required FeedbackState state,
    required super.child,
  }) : super(notifier: state);

  static FeedbackState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FeedbackScope>();
    assert(scope != null, 'No FeedbackScope found in context.');
    return scope!.notifier!;
  }
}
