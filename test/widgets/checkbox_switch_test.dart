import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '../_support/host.dart';

void main() {
  group('MonoCheckbox', () {
    testWidgets('toggles and reports the new value on tap', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        monokitHost(
          StatefulBuilder(
            builder: (context, setState) => MonoCheckbox(
              value: value,
              onChanged: (v) => setState(() => value = v),
              label: const Text('Agree'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(value, isTrue);

      await tester.tap(find.text('Agree'));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('exposes checkbox + checked semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoCheckbox(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'On checkbox',
            label: const Text('On'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('On checkbox')),
        isSemantics(hasCheckedState: true, isChecked: true),
      );
      handle.dispose();
    });

    testWidgets('disabled checkbox does not fire onChanged', (tester) async {
      var fired = false;
      await tester.pumpWidget(
        monokitHost(MonoCheckbox(value: false, label: const Text('Locked'))),
      );
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();
      expect(fired, isFalse);
    });

    testWidgets('tristate cycles false → true → null', (tester) async {
      bool? value = false;
      await tester.pumpWidget(
        monokitHost(
          StatefulBuilder(
            builder: (context, setState) => MonoCheckbox(
              value: value,
              tristate: true,
              onChanged: (v) => setState(() => value = v),
              label: const Text('Tri'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Tri'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      await tester.tap(find.text('Tri'));
      await tester.pumpAndSettle();
      expect(value, isNull);
    });
  });

  group('MonoSwitch', () {
    testWidgets('toggles and reports the new value', (tester) async {
      bool value = false;
      await tester.pumpWidget(
        monokitHost(
          StatefulBuilder(
            builder: (context, setState) => MonoSwitch(
              value: value,
              onChanged: (v) => setState(() => value = v),
              label: const Text('Notify'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Notify'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets('exposes toggled semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoSwitch(
            value: true,
            onChanged: (_) {},
            semanticLabel: 'Wifi toggle',
            label: const Text('Wifi'),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Wifi toggle')),
        isSemantics(hasToggledState: true, isToggled: true),
      );
      handle.dispose();
    });
  });
}
