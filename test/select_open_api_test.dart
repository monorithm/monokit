import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

void main() {
  final List<MonoSelectOption<int>> options = <MonoSelectOption<int>>[
    MonoSelectOption<int>.text(value: 0, label: 'One'),
    MonoSelectOption<int>.text(value: 1, label: 'Two'),
    MonoSelectOption<int>.text(value: 2, label: 'Three'),
  ];

  testWidgets('controlled open shows the popup and reports close requests', (
    tester,
  ) async {
    final List<bool> openChanges = <bool>[];
    Widget build(bool open) => MonokitApp(
      theme: MonokitThemeData.light(),
      home: Center(
        child: MonoSelect<int>(
          options: options,
          open: open,
          onOpenChange: openChanges.add,
        ),
      ),
    );

    await tester.pumpWidget(build(true));
    await tester.pumpAndSettle();
    // The popup is open because open: true was supplied.
    expect(find.bySemanticsLabel('Select options'), findsOneWidget);

    // Tapping an option requests a close via onOpenChange (controlled: the
    // widget does not close itself).
    await tester.tap(find.text('Two').last);
    await tester.pump();
    expect(openChanges.contains(false), isTrue);
  });

  testWidgets('defaultOpen opens the popup initially (uncontrolled)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: Center(
          child: MonoSelect<int>(options: options, defaultOpen: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Select options'), findsOneWidget);
  });
}
