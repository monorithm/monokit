import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child) => MonokitApp(
  theme: MonokitThemeData.light(),
  home: Center(child: SizedBox(width: 300, child: child)),
);

void main() {
  testWidgets('counter shows current/max and updates as you type', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const MonoInput(maxLength: 10, showCounter: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('0/10'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'abc');
    await tester.pump();
    expect(find.text('3/10'), findsOneWidget);
  });

  testWidgets('no counter widget unless showCounter is set', (tester) async {
    await tester.pumpWidget(_host(const MonoInput(maxLength: 10)));
    await tester.pumpAndSettle();
    expect(find.text('0/10'), findsNothing);
  });

  testWidgets('length is exposed to semantics even without a visible counter', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const MonoInput(maxLength: 20)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'hello');
    await tester.pump();

    final SemanticsData data = tester
        .getSemantics(find.byType(EditableText))
        .getSemanticsData();
    expect(data.maxValueLength, 20);
    expect(data.currentValueLength, 5);
    handle.dispose();
  });
}
