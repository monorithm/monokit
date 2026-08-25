import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

Widget _host(Widget child) {
  final data = MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: MonokitTheme(
        data: data,
        child: DefaultTextStyle(
          style: data.typography.body.copyWith(color: data.colors.foreground),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('always renders the tier name as text', (tester) async {
    await tester.pumpWidget(
      _host(const MonoTrustBadge(tier: 2, tierCount: 3, label: 'City ring')),
    );
    expect(find.text('City ring'), findsOneWidget);
  });

  testWidgets('announces tier position, and lapsed when it applies', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const MonoTrustBadge(tier: 1, tierCount: 3, label: 'Street ring')),
    );
    expect(find.bySemanticsLabel('Street ring, tier 1 of 3'), findsOneWidget);

    await tester.pumpWidget(
      _host(
        const MonoTrustBadge(
          tier: 2,
          tierCount: 3,
          label: 'City ring',
          lapsed: true,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('City ring, tier 2 of 3, lapsed'),
      findsOneWidget,
    );
  });

  testWidgets('lapsed mutes without changing geometry', (tester) async {
    await tester.pumpWidget(
      _host(const MonoTrustBadge(tier: 2, tierCount: 3, label: 'City ring')),
    );
    final active = tester.getSize(find.byType(MonoTrustBadge));

    await tester.pumpWidget(
      _host(
        const MonoTrustBadge(
          tier: 2,
          tierCount: 3,
          label: 'City ring',
          lapsed: true,
        ),
      ),
    );
    expect(tester.getSize(find.byType(MonoTrustBadge)), active);
  });

  test('a tier above the ladder is a programmer error', () {
    expect(
      () => MonoTrustBadge(tier: 4, tierCount: 3, label: 'Nation ring'),
      throwsAssertionError,
    );
  });
}
