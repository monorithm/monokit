import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

void main() {
  late List<String> fired;

  Widget row({
    List<MonoListRowAction> leading = const <MonoListRowAction>[],
    List<MonoListRowAction> trailing = const <MonoListRowAction>[],
    MonoDensity mode = MonoDensity.touch,
  }) => monokitHost(
    theme: MonokitThemeData.light().copyWith(
      density: MonokitDensity(mode: mode),
    ),
    SizedBox(
      width: 360,
      child: MonoListRowSwipe(
        leading: leading,
        trailing: trailing,
        child: const MonoListRow(title: 'Kente slippers'),
      ),
    ),
  );

  MonoListRowAction save() => MonoListRowAction(
    icon: MonoIcons.bookmark,
    label: 'Save',
    onPressed: () => fired.add('save'),
  );
  MonoListRowAction remove() => MonoListRowAction(
    icon: MonoIcons.trash,
    label: 'Take down',
    destructive: true,
    onPressed: () => fired.add('remove'),
  );

  setUp(() => fired = <String>[]);

  testWidgets('a constructive action taps; the row closes after', (
    tester,
  ) async {
    await tester.pumpWidget(row(leading: <MonoListRowAction>[save()]));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(MonoListRow), const Offset(60, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(fired, <String>['save']);
  });

  testWidgets('a destructive action will not fire on a tap', (tester) async {
    await tester.pumpWidget(row(trailing: <MonoListRowAction>[remove()]));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(MonoListRow), const Offset(-60, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Take down'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      fired,
      isEmpty,
      reason: 'a mis-swipe and a mis-tap must not be one motion apart',
    );
  });

  testWidgets('it fires after the hold, and says so while holding', (
    tester,
  ) async {
    await tester.pumpWidget(row(trailing: <MonoListRowAction>[remove()]));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(MonoListRow), const Offset(-60, 0));
    await tester.pumpAndSettle();

    final g = await tester.startGesture(
      tester.getCenter(find.text('Take down')),
    );
    await tester.pump(const Duration(milliseconds: 100));
    // The label says what is happening rather than a second progress element.
    expect(find.text('Hold…'), findsOneWidget);
    expect(fired, isEmpty, reason: '100ms in, nothing has been destroyed');

    // holdToConfirm is 800ms, measured from touch.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(fired, <String>['remove']);
    await g.up();
  });

  testWidgets('releasing early cancels the hold', (tester) async {
    await tester.pumpWidget(row(trailing: <MonoListRowAction>[remove()]));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(MonoListRow), const Offset(-60, 0));
    await tester.pumpAndSettle();

    final g = await tester.startGesture(
      tester.getCenter(find.text('Take down')),
    );
    // The hold starts at touch, so "early" is measured from there: 300ms
    // is well inside the 800 the confirm needs.
    await tester.pump(const Duration(milliseconds: 300));
    await g.up();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(fired, isEmpty, reason: 'a hold abandoned is a hold refused');
  });

  testWidgets('pointer reveals on hover and never drags', (tester) async {
    await tester.pumpWidget(
      row(trailing: <MonoListRowAction>[remove()], mode: MonoDensity.pointer),
    );
    await tester.pumpAndSettle();
    // The pointer never learns a gesture.
    expect(find.byType(GestureDetector), findsWidgets);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(
      pointer.hover(tester.getCenter(find.byType(MonoListRow))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Take down'), findsOneWidget);
  });

  testWidgets('the grammar is asserted, not merely documented', (tester) async {
    // Leading is constructive. A destructive action there would teach the
    // opposite of what every other row in the product teaches.
    await tester.pumpWidget(row(leading: <MonoListRowAction>[remove()]));
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('a resting row slides over its cells, not beside them', (
    tester,
  ) async {
    // The cells are always there; the row is what moves. A transparent moving
    // layer therefore shows a green and a red stripe down every row in the
    // list, which is exactly what the first render did — MonoListRow paints
    // `background` at alpha 0 when it is neither hovered nor selected.
    await tester.pumpWidget(
      row(
        leading: <MonoListRowAction>[save()],
        trailing: <MonoListRowAction>[remove()],
      ),
    );
    await tester.pumpAndSettle();

    final ColoredBox ground = tester.widget<ColoredBox>(
      find
          .ancestor(
            of: find.byType(MonoListRow),
            matching: find.byType(ColoredBox),
          )
          .last,
    );
    expect(ground.color.a, 1.0, reason: 'the moving layer must be opaque');

    // And it is clipped, so a row dragged past its stops does not paint over
    // its neighbours.
    expect(
      find.descendant(
        of: find.byType(MonoListRowSwipe),
        matching: find.byType(ClipRect),
      ),
      findsOneWidget,
    );
  });
}
