import 'package:flutter/widgets.dart';

/// App-level state shared by the shell: the active brightness.
///
/// A plain [ChangeNotifier] exposed through an [InheritedNotifier] — no
/// third-party state library.
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

/// Makes [AppThemeController] available to the shell and every route.
class AppScope extends InheritedNotifier<AppThemeController> {
  const AppScope({
    super.key,
    required AppThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context.');
    return scope!.notifier!;
  }
}
