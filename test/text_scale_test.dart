import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _scaled(Widget child, double scale) {
  final MonokitThemeData theme = MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: MonokitTheme(
        data: theme,
        child: DefaultTextStyle(
          style: theme.typography.body,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  Future<double> extentAt(WidgetTester tester, double scale) async {
    late double value;
    await tester.pumpWidget(
      _scaled(
        Builder(
          builder: (BuildContext context) {
            value = monoScaledExtent(context, 48);
            return const SizedBox.shrink();
          },
        ),
        scale,
      ),
    );
    return value;
  }

  testWidgets('monoScaledExtent grows with scale and clamps at 2x', (
    tester,
  ) async {
    final double base = await extentAt(tester, 1.0);
    final double mid = await extentAt(tester, 1.5);
    final double high = await extentAt(tester, 2.0);
    final double beyond = await extentAt(tester, 3.0);

    expect(base, 48, reason: 'unchanged at 1.0 scale');
    expect(mid, greaterThan(base));
    expect(high, greaterThan(mid));
    expect(beyond, high, reason: 'clamped at 2x');
  });

  testWidgets('fixed-height widgets do not overflow at 2x text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scaled(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MonoButton(onPressed: () {}, child: const Text('Submit')),
            const SizedBox(height: 8),
            const MonoBadge(child: Text('New')),
          ],
        ),
        2.0,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
