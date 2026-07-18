import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../navigation/router.dart';
import 'app_scope.dart';

/// Root of the gallery: owns the theme controller, exposes it via [AppScope]
/// (above the router so the shell's toggle can reach it), and installs the
/// Monokit theme through [MonokitApp.router].
class MonokitGallery extends StatefulWidget {
  const MonokitGallery({super.key});

  @override
  State<MonokitGallery> createState() => _MonokitGalleryState();
}

class _MonokitGalleryState extends State<MonokitGallery> {
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
          title: 'Monokit',
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
