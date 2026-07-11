import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../navigation/navigation.dart';
import 'app_scope.dart';

/// The app root: owns the theme controller, exposes it via [AppScope], and
/// drives the router through [MonokitApp.router].
class AppContainer extends StatefulWidget {
  const AppContainer({super.key});

  @override
  State<AppContainer> createState() => _AppContainerState();
}

class _AppContainerState extends State<AppContainer> {
  final AppThemeController _theme = AppThemeController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _theme,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) => MonokitApp.router(
          title: 'Monokit documentation',
          theme: MonokitThemeData.light(),
          darkTheme: MonokitThemeData.dark(),
          themeMode: _theme.isDark
              ? MonokitThemeMode.dark
              : MonokitThemeMode.light,
          routerConfig: router,
        ),
      ),
    );
  }
}
