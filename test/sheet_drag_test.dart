import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

import '_support/host.dart';

/// The sheet used to draw a grab handle over a surface with no drag gesture at
/// all — dismissal was scrim-tap or Escape only. These cover the gesture that
/// handle now affords.
void main() {
  Widget sheetHost({bool dismissible = true}) => monokitHost(
    MonoSheet(
      dismissible: dismissible,
      trigger: const MonoSheetTrigger(child: Text('Open sheet')),
      child: const MonoSheetContent(child: Text('Sheet content')),
    ),
  );

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);
  }

  /// The drag handle is the grab target.
  Finder handle() => find.byWidgetPredicate(
    (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
  );

  testWidgets('a downward fling dismisses the sheet', (tester) async {
    await tester.pumpWidget(sheetHost());
    await openSheet(tester);

    await tester.fling(handle(), const Offset(0, 300), 2000);
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsNothing);
  });

  testWidgets('a small drag that is released springs back open', (
    tester,
  ) async {
    await tester.pumpWidget(sheetHost());
    await openSheet(tester);

    // Nudge it down a little and let go gently: projection stays nearer the
    // open stop, so it should return rather than dismiss.
    final gesture = await tester.startGesture(tester.getCenter(handle()));
    await gesture.moveBy(const Offset(0, 20));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('a hard flick past the midpoint still dismisses', (tester) async {
    await tester.pumpWidget(sheetHost());
    await openSheet(tester);

    // Released while barely moved but travelling fast — deciding on the
    // projected position rather than the released position is the point.
    final gesture = await tester.startGesture(tester.getCenter(handle()));
    await gesture.moveBy(const Offset(0, 12));
    await tester.pump(const Duration(milliseconds: 8));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 8));
    await gesture.moveBy(const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 8));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsNothing);
  });

  testWidgets('a non-dismissible sheet exposes no drag gesture', (
    tester,
  ) async {
    await tester.pumpWidget(sheetHost(dismissible: false));
    await openSheet(tester);

    expect(handle(), findsNothing);
    expect(find.text('Sheet content'), findsOneWidget);
  });

  testWidgets('reduced motion still opens and dismisses, without animating', (
    tester,
  ) async {
    // The override has to be installed *inside* MonokitApp — WidgetsApp builds
    // its own MediaQuery from the view, which would shadow an outer one.
    await tester.pumpWidget(
      monokitHost(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: const MonoSheet(
              trigger: MonoSheetTrigger(child: Text('Open sheet')),
              child: MonoSheetContent(child: Text('Sheet content')),
            ),
          ),
        ),
      ),
    );

    // Two pumps, not pumpAndSettle. The first frame inserts the overlay entry
    // (that cost is there with or without motion); the second must already
    // show the sheet seated rather than part-way through a transition.
    await tester.tap(find.text('Open sheet'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Sheet content'), findsOneWidget);

    // Bounded pumps rather than pumpAndSettle: one to deliver the release, one
    // for the overlay entry to be removed. If motion were still running this
    // would not be enough.
    await tester.fling(handle(), const Offset(0, 300), 2000);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.text('Sheet content'), findsNothing);
  });
}
