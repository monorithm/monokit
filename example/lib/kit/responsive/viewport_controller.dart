import 'package:flutter/widgets.dart';

/// A named viewport the shell (and scenarios) can be pinned to. `fluid` lets the
/// real window drive layout; the others frame the content as a device so the
/// breakpoint story is legible on any screen.
enum ViewportMode {
  fluid('Fluid', null, null),
  phone('Phone', 402, 874),
  tablet('Tablet', 834, 1112),
  desktop('Desktop', 1280, 832);

  const ViewportMode(this.label, this.width, this.height);

  /// Human label for the switcher.
  final String label;

  /// Logical width the framed canvas reports, or null for `fluid`.
  final double? width;

  /// Logical height the framed canvas reports, or null for `fluid`.
  final double? height;

  bool get isFramed => width != null;
}

/// Drives the global device switcher. A plain [ChangeNotifier], shared through
/// [AppScope] alongside the theme controller — no third-party state library.
class ViewportController extends ChangeNotifier {
  ViewportController({this._mode = ViewportMode.fluid});

  ViewportMode _mode;

  ViewportMode get mode => _mode;

  void set(ViewportMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }
}
