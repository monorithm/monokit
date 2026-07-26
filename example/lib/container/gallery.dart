import 'package:monokit/monokit.dart';

import '../kit/responsive/viewport_controller.dart';
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
  final ViewportController _viewport = ViewportController();

  @override
  void dispose() {
    _theme.dispose();
    _viewport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      theme: _theme,
      viewport: _viewport,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) => MonokitApp.router(
          title: 'Monokit',
          // Demonstrates the restoration hook: pairs with a router that sets
          // its own restorationScopeId to restore location across process death.
          restorationScopeId: 'gallery',
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
