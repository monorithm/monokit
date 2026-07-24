import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child) {
  final MonokitThemeData theme = MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: MonokitTheme(
        data: theme,
        child: DefaultTextStyle(style: theme.typography.body, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('button is intrinsic-safe inside IntrinsicWidth', (tester) async {
    await tester.pumpWidget(
      _host(
        Center(
          child: IntrinsicWidth(
            child: Column(
              children: <Widget>[
                MonoButton(onPressed: () {}, child: const Text('Short')),
                MonoButton(
                  onPressed: () {},
                  child: const Text('A longer label'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // Previously the Flexible child threw a "cannot compute intrinsics" error.
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled mid-press clears the pressed state', (tester) async {
    Widget build(bool enabled) => _host(
      Center(
        child: MonoButton(
          onPressed: enabled ? () {} : null,
          child: const Text('Tap'),
        ),
      ),
    );

    await tester.pumpWidget(build(true));
    // Begin a press but do not release.
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.text('Tap')),
    );
    await tester.pump();

    // Rebuild disabled while the press is still down.
    await tester.pumpWidget(build(false));
    await tester.pump();

    // No exception, and releasing on a now-disabled button is a no-op.
    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
