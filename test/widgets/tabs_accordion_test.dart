import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '../_support/host.dart';

void main() {
  group('MonoTabs', () {
    testWidgets('switches the visible panel and reports the value', (
      tester,
    ) async {
      String? selected;
      await tester.pumpWidget(
        monokitHost(
          MonoTabs(
            defaultValue: 'a',
            onChanged: (v) => selected = v,
            tabs: <MonoTab>[
              MonoTab(
                value: 'a',
                label: const Text('First'),
                content: const Text('Panel A'),
              ),
              MonoTab(
                value: 'b',
                label: const Text('Second'),
                content: const Text('Panel B'),
              ),
            ],
          ),
        ),
      );
      expect(find.text('Panel A'), findsOneWidget);
      expect(find.text('Panel B'), findsNothing);

      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(find.text('Panel B'), findsOneWidget);
      expect(find.text('Panel A'), findsNothing);
    });

    testWidgets('a disabled tab cannot be selected', (tester) async {
      String? selected;
      await tester.pumpWidget(
        monokitHost(
          MonoTabs(
            defaultValue: 'a',
            onChanged: (v) => selected = v,
            tabs: <MonoTab>[
              MonoTab(
                value: 'a',
                label: const Text('First'),
                content: const Text('Panel A'),
              ),
              MonoTab(
                value: 'b',
                enabled: false,
                label: const Text('Locked'),
                content: const Text('Panel B'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
      expect(find.text('Panel A'), findsOneWidget);
    });
  });

  group('MonoAccordion', () {
    testWidgets('single mode expands one item and collapses the previous', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoAccordion(
            items: <MonoAccordionItem>[
              MonoAccordionItem(
                value: 'one',
                title: const Text('Section one'),
                semanticLabel: 'one-trigger',
                content: const Text('Body one'),
              ),
              MonoAccordionItem(
                value: 'two',
                title: const Text('Section two'),
                semanticLabel: 'two-trigger',
                content: const Text('Body two'),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('one-trigger')),
        isSemantics(isExpanded: false),
      );

      await tester.tap(find.text('Section one'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('one-trigger')),
        isSemantics(isExpanded: true),
      );

      await tester.tap(find.text('Section two'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('two-trigger')),
        isSemantics(isExpanded: true),
      );
      // Single mode: the first section collapses.
      expect(
        tester.getSemantics(find.bySemanticsLabel('one-trigger')),
        isSemantics(isExpanded: false),
      );
      handle.dispose();
    });

    testWidgets('multiple mode keeps several items open', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoAccordion(
            type: MonoAccordionType.multiple,
            items: <MonoAccordionItem>[
              MonoAccordionItem(
                value: 'one',
                title: const Text('Section one'),
                semanticLabel: 'one-trigger',
                content: const Text('Body one'),
              ),
              MonoAccordionItem(
                value: 'two',
                title: const Text('Section two'),
                semanticLabel: 'two-trigger',
                content: const Text('Body two'),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Section one'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Section two'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('one-trigger')),
        isSemantics(isExpanded: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('two-trigger')),
        isSemantics(isExpanded: true),
      );
      handle.dispose();
    });
  });
}
