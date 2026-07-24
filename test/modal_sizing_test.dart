import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

void main() {
  Widget host(Widget child) =>
      MonokitApp(theme: MonokitThemeData.light(), home: child);

  /// Simulates a software keyboard at the view level, the way a real platform
  /// reports it, so overlay entries see it through the root MediaQuery.
  void showKeyboard(WidgetTester tester, double height) {
    tester.view.viewInsets = FakeViewPadding(
      bottom: height * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.reset);
  }

  Size logicalScreen(WidgetTester tester) =>
      tester.view.physicalSize / tester.view.devicePixelRatio;

  testWidgets('tall dialog scrolls instead of overflowing', (tester) async {
    await tester.pumpWidget(
      host(
        MonoDialog(
          open: true,
          child: MonoDialogContent(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                40,
                (int i) => SizedBox(height: 40, child: Text('Row $i')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 40 x 40px rows = 1600px of content: must not throw and the surface
    // must stay within the screen.
    expect(tester.takeException(), isNull);
    final Size screen = logicalScreen(tester);
    final Rect surface = tester.getRect(find.byType(MonoDialogContent));
    expect(surface.height, lessThanOrEqualTo(screen.height));
    expect(surface.top, greaterThanOrEqualTo(0));
    expect(surface.bottom, lessThanOrEqualTo(screen.height));
  });

  testWidgets('dialog stays above the software keyboard', (tester) async {
    showKeyboard(tester, 300);
    await tester.pumpWidget(
      host(
        MonoDialog(
          open: true,
          child: MonoDialogContent(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(
                20,
                (int i) => SizedBox(height: 40, child: Text('Row $i')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    final Size screen = logicalScreen(tester);
    final Rect surface = tester.getRect(find.byType(MonoDialogContent));
    expect(
      surface.bottom,
      lessThanOrEqualTo(screen.height - 300),
      reason: 'dialog is lifted clear of the keyboard inset',
    );
  });

  testWidgets('tall sheet caps its height and scrolls', (tester) async {
    await tester.pumpWidget(
      host(
        MonoSheet(
          open: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(
              40,
              (int i) => SizedBox(height: 40, child: Text('Sheet row $i')),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    final Rect surface = tester.getRect(find.text('Sheet row 0'));
    expect(surface.top, greaterThanOrEqualTo(0));
  });

  testWidgets('sheet rides above the software keyboard', (tester) async {
    showKeyboard(tester, 300);
    await tester.pumpWidget(
      host(
        MonoSheet(
          open: true,
          child: const SizedBox(height: 120, child: Text('Form field')),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    final Size screen = logicalScreen(tester);
    final Rect field = tester.getRect(find.text('Form field'));
    expect(
      field.bottom,
      lessThanOrEqualTo(screen.height - 300),
      reason: 'sheet content sits above the keyboard inset',
    );
  });
}
