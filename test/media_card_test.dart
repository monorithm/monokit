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
          child: Center(child: SizedBox(width: 180, child: child)),
        ),
      ),
    ),
  );
}

void main() {
  test('a non-live card without a state label is a programmer error', () {
    expect(
      () => MonoMediaCard(
        lifecycle: MonoMediaLifecycle.ended,
        title: const Text('Kente slippers'),
        price: 'GHS 240',
      ),
      throwsAssertionError,
    );
  });

  testWidgets('a live price and a historical price are typographically '
      'distinct', (tester) async {
    await tester.pumpWidget(
      _host(
        const MonoMediaCard(title: Text('Kente slippers'), price: 'GHS 240'),
      ),
    );
    final live = tester.widget<Text>(find.text('GHS 240'));
    expect(live.style?.fontWeight, FontWeight.w700);

    await tester.pumpWidget(
      _host(
        const MonoMediaCard(
          lifecycle: MonoMediaLifecycle.sold,
          stateLabel: 'Sold',
          title: Text('Ahenema'),
          price: 'Sold at GHS 250',
        ),
      ),
    );
    final historical = tester.widget<Text>(find.text('Sold at GHS 250'));
    expect(historical.style?.fontWeight, isNot(FontWeight.w700));
    final theme = MonokitThemeData.light();
    expect(historical.style?.color, theme.colors.mutedForeground);
  });

  testWidgets('a non-live card carries its state label chip', (tester) async {
    await tester.pumpWidget(
      _host(
        const MonoMediaCard(
          lifecycle: MonoMediaLifecycle.ended,
          stateLabel: 'Ended 3d ago',
          title: Text('Batik tote'),
          price: 'Last at GHS 90',
        ),
      ),
    );
    expect(find.text('Ended 3d ago'), findsOneWidget);
  });

  testWidgets('no media renders the declared placeholder, not an empty box', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const MonoMediaCard(title: Text('Kente slippers'), price: 'GHS 240'),
      ),
    );
    expect(find.byType(MonoIcon), findsOneWidget);
  });
}
