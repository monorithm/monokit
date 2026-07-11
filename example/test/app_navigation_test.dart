import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';
import 'package:monokit_example/container/app_container.dart';
import 'package:monokit_example/container/app_scope.dart';
import 'package:monokit_example/navigation/navigation.dart';
import 'package:monokit_example/widgets/shared/doc_widgets.dart';

const _routeTransition = Duration(milliseconds: 400);

/// A body marker (a `DocSection` name) unique to each section, proving the
/// correct page rendered rather than merely *a* page.
const Map<String, String> _markers = <String, String>{
  '/': 'MonokitApp · MonokitTheme · MonokitThemeData',
  '/foundations': 'Responsive behavior contract',
  '/actions-feedback': 'MonoButton',
  '/forms': 'MonoInputOtp',
  '/navigation': 'MonoNavigationMenu · MonoNavigationMenuItem',
  '/overlays': 'Interaction guide',
  '/messaging': 'MonoMessageScroller',
  '/primitives': 'MonoState · MonoStatesController · MonoStateProperty',
};

void _configureViewport(
  WidgetTester tester, [
  Size size = const Size(1440, 1200),
]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Advances past the route transition without `pumpAndSettle`, which would time
/// out on pages hosting infinite animations (spinners, skeleton shimmer).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(_routeTransition);
}

Future<void> _goto(WidgetTester tester, String location) async {
  router.go(location);
  await _settle(tester);
}

void main() {
  testWidgets('boots on the overview route inside a persistent shell', (
    tester,
  ) async {
    _configureViewport(tester);
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/');

    expect(find.byType(MonoScreen), findsOneWidget);
    expect(find.byType(DocPageContent), findsOneWidget);
    expect(find.text('Monokit for Flutter'), findsOneWidget);
  });

  testWidgets('every section renders its content under one persistent shell', (
    tester,
  ) async {
    _configureViewport(tester);
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/');

    final shell = tester.firstElement(find.byType(MonoScreen));

    for (final section in navSections) {
      await _goto(tester, section.location);

      expect(
        find.byType(DocPageContent),
        findsOneWidget,
        reason: '${section.location} should render a page body',
      );
      expect(
        find.text(_markers[section.location]!),
        findsOneWidget,
        reason: '${section.location} should show its marker section',
      );
      expect(
        tester.firstElement(find.byType(MonoScreen)),
        same(shell),
        reason: 'the shell should persist across ${section.location}',
      );
    }
  });

  testWidgets('the header theme toggle flips brightness', (tester) async {
    _configureViewport(tester);
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/forms');

    final controller = AppScope.of(
      tester.firstElement(find.byType(MonoScreen)),
    );
    expect(controller.isDark, isFalse);
    expect(find.text('Dark theme'), findsOneWidget);

    await tester.tap(find.text('Dark theme'));
    await _settle(tester);

    expect(controller.isDark, isTrue);
    expect(find.text('Light theme'), findsOneWidget);
    // The active section is unchanged by the toggle.
    expect(find.text(_markers['/forms']!), findsOneWidget);
  });

  testWidgets('the medium layout collapses the sidebar to an icon rail', (
    tester,
  ) async {
    _configureViewport(tester, const Size(880, 1200));
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/');

    // Expanded-only chrome is hidden; nav stays reachable via semantics label.
    expect(find.text('Monokit docs'), findsNothing);
    expect(find.bySemanticsLabel('Forms'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the compact layout renders every route without errors', (
    tester,
  ) async {
    _configureViewport(tester, const Size(390, 844));
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/');
    expect(tester.takeException(), isNull);

    for (final section in navSections) {
      await _goto(tester, section.location);
      expect(tester.takeException(), isNull, reason: section.location);
    }
  });

  testWidgets('documentation titles are exposed as semantic headings', (
    tester,
  ) async {
    _configureViewport(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const AppContainer());
    await _goto(tester, '/');

    expect(
      tester.getSemantics(find.text('Monokit for Flutter')),
      matchesSemantics(label: 'Monokit for Flutter', isHeader: true),
    );
    handle.dispose();
  });
}
