import 'package:flutter/widgets.dart';

import '../kit/responsive/viewport_controller.dart';

/// App-level state shared by the shell: the active brightness.
///
/// A plain [ChangeNotifier] exposed through [AppScope] — no third-party state
/// library.
class AppThemeController extends ChangeNotifier {
  AppThemeController({bool isDark = false}) : this._(isDark);

  AppThemeController._(this._isDark);

  bool _isDark;

  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// Makes the shell controllers — brightness ([AppThemeController]) and the
/// global device switcher ([ViewportController]) — available to every route.
///
/// Each controller is published through its own [InheritedNotifier] so a
/// dependent rebuilds only for the state it actually reads: a theme toggle does
/// not rebuild on a viewport change, and vice versa.
class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.theme,
    required this.viewport,
    required this.child,
  });

  final AppThemeController theme;
  final ViewportController viewport;
  final Widget child;

  /// The brightness controller. Named [of] for backwards compatibility with the
  /// original single-controller scope.
  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ThemeScope>();
    assert(scope != null, 'No AppScope found in context.');
    return scope!.notifier!;
  }

  /// The global device-switcher controller.
  static ViewportController viewportOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_ViewportScope>();
    assert(scope != null, 'No AppScope found in context.');
    return scope!.notifier!;
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeScope(
      notifier: theme,
      child: _ViewportScope(notifier: viewport, child: child),
    );
  }
}

class _ThemeScope extends InheritedNotifier<AppThemeController> {
  const _ThemeScope({required super.notifier, required super.child});
}

class _ViewportScope extends InheritedNotifier<ViewportController> {
  const _ViewportScope({required super.notifier, required super.child});
}
