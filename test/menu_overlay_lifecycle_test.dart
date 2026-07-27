import 'package:flutter_test/flutter_test.dart';
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

typedef _ControlledOverlayBuilder = Widget Function(bool open, String label);

Future<void> _expectControlledOverlayLifecycle(
  WidgetTester tester, {
  required _ControlledOverlayBuilder builder,
  required String initialLabel,
  required String updatedLabel,
}) async {
  late StateSetter rebuild;
  var open = false;
  var label = initialLabel;

  await tester.pumpWidget(
    _host(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          rebuild = setState;
          return builder(open, label);
        },
      ),
    ),
  );

  rebuild(() => open = true);
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text(initialLabel), findsOneWidget);
  expect(tester.takeException(), isNull);

  rebuild(() => label = updatedLabel);
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text(updatedLabel), findsOneWidget);
  expect(tester.takeException(), isNull);

  rebuild(() => open = false);
  await tester.pump();
  await tester.pumpAndSettle();
  expect(find.text(updatedLabel), findsNothing);
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets('combobox synchronizes controlled overlays after rebuilds', (
    WidgetTester tester,
  ) async {
    await _expectControlledOverlayLifecycle(
      tester,
      initialLabel: 'Initial combobox option',
      updatedLabel: 'Updated combobox option',
      builder: (bool open, String label) => MonoCombobox<String>(
        open: open,
        placeholder: 'Choose a combobox option',
        options: <MonoComboboxOption<String>>[
          MonoComboboxOption.text(value: 'option', label: label),
        ],
      ),
    );
  });

  testWidgets('dropdown menu synchronizes controlled overlays after rebuilds', (
    WidgetTester tester,
  ) async {
    await _expectControlledOverlayLifecycle(
      tester,
      initialLabel: 'Initial menu item',
      updatedLabel: 'Updated menu item',
      builder: (bool open, String label) => MonoDropdownMenu<String>(
        open: open,
        trigger: const Text('Open menu'),
        items: <MonoDropdownMenuItem<String>>[
          MonoDropdownMenuItem.text(value: 'item', label: label),
        ],
      ),
    );
  });

  testWidgets(
    'command palette synchronizes controlled overlays after rebuilds',
    (WidgetTester tester) async {
      await _expectControlledOverlayLifecycle(
        tester,
        initialLabel: 'Initial command',
        updatedLabel: 'Updated command',
        builder: (bool open, String label) => MonoCommandPalette(
          open: open,
          commands: <MonoCommand>[
            MonoCommand.text(id: 'command', label: label),
          ],
        ),
      );
    },
  );

  testWidgets('select defers open-entry refresh and removal after rebuilds', (
    WidgetTester tester,
  ) async {
    late StateSetter rebuild;
    var enabled = true;
    var label = 'Initial select option';

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            rebuild = setState;
            return MonoSelect<String>(
              enabled: enabled,
              placeholder: 'Choose a select option',
              options: <MonoSelectOption<String>>[
                MonoSelectOption.text(value: 'option', label: label),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Choose a select option'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Initial select option'), findsOneWidget);
    expect(tester.takeException(), isNull);

    rebuild(() => label = 'Updated select option');
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Updated select option'), findsOneWidget);
    expect(tester.takeException(), isNull);

    rebuild(() => enabled = false);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Updated select option'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
