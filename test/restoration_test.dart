import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

void main() {
  testWidgets('MonoInput restores its text across a restart', (tester) async {
    await tester.pumpWidget(
      const RootRestorationScope(
        restorationId: 'root',
        child: MonokitTestApp(),
      ),
    );

    await tester.enterText(find.byType(EditableText), 'draft in progress');
    await tester.pump();
    expect(find.text('draft in progress'), findsOneWidget);

    // Simulate the OS killing and relaunching the app.
    await tester.restartAndRestore();

    expect(
      find.text('draft in progress'),
      findsOneWidget,
      reason: 'owned controller text survived the restart',
    );
  });

  testWidgets('MonoInput without a restorationId does not restore', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RootRestorationScope(
        restorationId: 'root',
        child: MonokitTestApp(restorationId: null),
      ),
    );
    await tester.enterText(find.byType(EditableText), 'ephemeral');
    await tester.pump();
    await tester.restartAndRestore();
    expect(find.text('ephemeral'), findsNothing);
  });
}

class MonokitTestApp extends StatelessWidget {
  const MonokitTestApp({super.key, this.restorationId = 'field'});
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: MonokitTheme(
          data: MonokitThemeData.light(),
          child: Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 300,
                    child: MonoInput(restorationId: restorationId),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
