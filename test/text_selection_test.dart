import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

void main() {
  testWidgets('long-press shows the token-styled copy/paste toolbar', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final controller = TextEditingController(text: 'Hello world');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: Center(
          child: SizedBox(width: 300, child: MonoInput(controller: controller)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byType(EditableText));
    await tester.pumpAndSettle();
    // The gesture is done; reset the platform before assertions so a failure
    // never leaves the foundation override set.
    debugDefaultTargetPlatformOverride = null;

    // The Monokit toolbar surfaces the platform actions.
    expect(find.byType(MonoTextSelectionToolbar), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('selection controls are wired into the EditableText', (
    tester,
  ) async {
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: const Center(child: SizedBox(width: 300, child: MonoInput())),
      ),
    );
    await tester.pumpAndSettle();

    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.selectionControls, isA<MonoTextSelectionControls>());
    expect(editable.contextMenuBuilder, isNotNull);
  });

  testWidgets('disabled interactive selection removes the controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: const Center(
          child: SizedBox(
            width: 300,
            child: MonoInput(enableInteractiveSelection: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final EditableText editable = tester.widget<EditableText>(
      find.byType(EditableText),
    );
    expect(editable.selectionControls, isNull);
    expect(editable.contextMenuBuilder, isNull);
  });
}
