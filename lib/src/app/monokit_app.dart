import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';

/// Chooses which supplied Monokit theme is active.
enum MonokitThemeMode { system, light, dark }

/// A widgets-first application wrapper.
///
/// [MonokitApp] intentionally uses [WidgetsApp], rather than [MaterialApp],
/// so package users can opt into Material only where their application needs it.
/// It forwards WidgetsApp routing inputs and supplies a token-timed fade route
/// transition unless [pageRouteBuilder] is overridden.
class MonokitApp extends StatelessWidget {
  const MonokitApp({
    super.key,
    required this.theme,
    this.home,
    this.darkTheme,
    this.themeMode = MonokitThemeMode.system,
    this.title = '',
    this.locale,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.localizationsDelegates,
    this.navigatorKey,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.pageRouteBuilder,
    this.debugShowCheckedModeBanner = false,
    this.restorationScopeId,
  }) : routerConfig = null,
       routerDelegate = null,
       routeInformationParser = null,
       routeInformationProvider = null,
       backButtonDispatcher = null;

  /// Router-based constructor for Navigator 2.0 route stacks (e.g. go_router).
  ///
  /// Forwards [routerConfig] (or the individual router pieces) to
  /// [WidgetsApp.router] while still installing the Monokit theme and the
  /// default text style. Mirrors [MaterialApp.router] so package users can
  /// adopt declarative routing without pulling in Material.
  const MonokitApp.router({
    super.key,
    required this.theme,
    this.darkTheme,
    this.themeMode = MonokitThemeMode.system,
    this.title = '',
    this.locale,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.localizationsDelegates,
    this.routerConfig,
    this.routerDelegate,
    this.routeInformationParser,
    this.routeInformationProvider,
    this.backButtonDispatcher,
    this.debugShowCheckedModeBanner = false,
    this.restorationScopeId,
  }) : home = null,
       routes = const <String, WidgetBuilder>{},
       initialRoute = null,
       onGenerateRoute = null,
       onGenerateInitialRoutes = null,
       onUnknownRoute = null,
       pageRouteBuilder = null,
       navigatorKey = null,
       navigatorObservers = const <NavigatorObserver>[],
       assert(
         routerConfig != null || routerDelegate != null,
         'Provide routerConfig or routerDelegate.',
       );

  final MonokitThemeData theme;
  final MonokitThemeData? darkTheme;
  final MonokitThemeMode themeMode;
  final Widget? home;
  final String title;
  final Locale? locale;
  final Iterable<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final Map<String, WidgetBuilder> routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final PageRouteFactory? pageRouteBuilder;
  final bool debugShowCheckedModeBanner;
  final RouterConfig<Object>? routerConfig;
  final RouterDelegate<Object>? routerDelegate;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouteInformationProvider? routeInformationProvider;
  final BackButtonDispatcher? backButtonDispatcher;

  /// Establishes the root restoration scope and, for the router constructor,
  /// the [Router]'s `restorationScopeId` — so a declarative router (e.g.
  /// go_router with its own `restorationScopeId`) can restore the current
  /// location after the OS kills and relaunches a backgrounded app. Null
  /// (the default) leaves state restoration off, as before.
  final String? restorationScopeId;

  MonokitThemeData _resolveTheme(BuildContext context) {
    if (themeMode == MonokitThemeMode.light || darkTheme == null) {
      return theme;
    }
    if (themeMode == MonokitThemeMode.dark) {
      return darkTheme!;
    }
    final brightness = MediaQuery.maybeOf(context)?.platformBrightness;
    return brightness == Brightness.dark ? darkTheme! : theme;
  }

  PageRoute<T> _buildPageRoute<T>(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: theme.motion.duration,
      reverseTransitionDuration: theme.motion.duration,
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => builder(context),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(opacity: animation, child: child);
          },
    );
  }

  Widget _wrapTheme(BuildContext context, Widget? child) {
    final effectiveTheme = _resolveTheme(context);
    return MonokitTheme(
      data: effectiveTheme,
      child: DefaultTextStyle(
        style: effectiveTheme.typography.body.copyWith(
          color: effectiveTheme.colors.foreground,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (routerConfig != null || routerDelegate != null) {
      return WidgetsApp.router(
        color: theme.colors.background,
        routerConfig: routerConfig,
        routerDelegate: routerDelegate,
        routeInformationParser: routeInformationParser,
        routeInformationProvider: routeInformationProvider,
        backButtonDispatcher: backButtonDispatcher,
        restorationScopeId: restorationScopeId,
        title: title,
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        builder: (context, child) => _wrapTheme(context, child),
      );
    }
    assert(
      home != null || routes.isNotEmpty || onGenerateRoute != null,
      'Provide home, routes, or onGenerateRoute.',
    );
    assert(
      home == null || !routes.containsKey(Navigator.defaultRouteName),
      'Do not provide both home and a route for \'/\'.',
    );
    return WidgetsApp(
      color: theme.colors.background,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      pageRouteBuilder: pageRouteBuilder ?? _buildPageRoute,
      title: title,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: localizationsDelegates,
      navigatorKey: navigatorKey,
      navigatorObservers: navigatorObservers,
      restorationScopeId: restorationScopeId,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      builder: (context, child) => _wrapTheme(context, child),
    );
  }
}
