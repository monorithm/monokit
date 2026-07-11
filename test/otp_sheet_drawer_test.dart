import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child) {
  final MonokitThemeData theme = MonokitThemeData.light();
  return MonokitTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.colors.background,
      onGenerateRoute: (RouteSettings settings) => PageRouteBuilder<void>(
        settings: settings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> primary,
              Animation<double> secondary,
            ) => Center(child: child),
      ),
    ),
  );
}

class _ControlledOverlayHarness extends StatefulWidget {
  const _ControlledOverlayHarness({super.key, required this.isDrawer});

  final bool isDrawer;

  @override
  State<_ControlledOverlayHarness> createState() =>
      _ControlledOverlayHarnessState();
}

class _ControlledOverlayHarnessState extends State<_ControlledOverlayHarness> {
  bool _open = false;
  String _content = 'initial';

  void open() => setState(() => _open = true);

  void updateContent() => setState(() => _content = 'updated');

  void close() => setState(() => _open = false);

  @override
  Widget build(BuildContext context) {
    final String kind = widget.isDrawer ? 'Drawer' : 'Sheet';
    final Widget child = Text('$kind content: $_content');
    return widget.isDrawer
        ? MonoDrawer(
            open: _open,
            child: MonoDrawerContent(child: child),
          )
        : MonoSheet(
            open: _open,
            child: MonoSheetContent(child: child),
          );
  }
}

Future<void> _expectControlledOverlaySync(
  WidgetTester tester, {
  required bool isDrawer,
}) async {
  final GlobalKey<_ControlledOverlayHarnessState> key =
      GlobalKey<_ControlledOverlayHarnessState>();
  final String kind = isDrawer ? 'Drawer' : 'Sheet';
  await tester.pumpWidget(
    _host(_ControlledOverlayHarness(key: key, isDrawer: isDrawer)),
  );

  key.currentState!.open();
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text('$kind content: initial'), findsOneWidget);

  key.currentState!.updateContent();
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text('$kind content: updated'), findsOneWidget);

  key.currentState!.close();
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text('$kind content: updated'), findsNothing);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('OTP distributes pasted values and completes', (
    WidgetTester tester,
  ) async {
    String? changed;
    String? completed;
    await tester.pumpWidget(
      _host(
        MonoInputOtp(
          length: 4,
          onChanged: (String value) => changed = value,
          onCompleted: (String value) => completed = value,
        ),
      ),
    );

    await tester.tap(find.byType(EditableText).first);
    await tester.enterText(find.byType(EditableText).first, '1234');
    await tester.pump();

    expect(changed, '1234');
    expect(completed, '1234');
  });

  testWidgets('sheet and drawer open then dismiss with Escape', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            MonoSheet(
              trigger: MonoSheetTrigger(child: Text('Open sheet')),
              child: MonoSheetContent(child: Text('Sheet content')),
            ),
            MonoDrawer(
              trigger: MonoDrawerTrigger(child: Text('Open drawer')),
              child: MonoDrawerContent(child: Text('Drawer content')),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsNothing);

    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();
    expect(find.text('Drawer content'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Drawer content'), findsNothing);
  });

  testWidgets(
    'drawer defers controlled overlay synchronization after rebuild',
    (WidgetTester tester) async {
      await _expectControlledOverlaySync(tester, isDrawer: true);
    },
  );

  testWidgets('sheet defers controlled overlay synchronization after rebuild', (
    WidgetTester tester,
  ) async {
    await _expectControlledOverlaySync(tester, isDrawer: false);
  });
}
