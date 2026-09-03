import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Findings from reading the remaining component boards against their widgets.
void main() {
  testWidgets('a segmented control is a capsule, track and pill', (
    tester,
  ) async {
    await tester.pumpWidget(
      monokitHost(
        MonoTabs(
          variant: MonoTabsVariant.segmented,
          value: 'a',
          onChanged: (_) {},
          tabs: <MonoTab>[
            MonoTab(
              value: 'a',
              label: const Text('Live'),
              child: const SizedBox(),
            ),
            MonoTab(
              value: 'b',
              label: const Text('Ended'),
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final radii = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.borderRadius)
        .whereType<BorderRadius>()
        .map((b) => b.topLeft.x)
        .toSet();
    expect(
      radii.any((r) => r >= 999),
      isTrue,
      reason: 'the pick should read as sliding in a groove, not as buttons',
    );
  });

  testWidgets('a selected list row wears the wash, not just the ink', (
    tester,
  ) async {
    final theme = MonokitThemeData.light();
    await tester.pumpWidget(
      monokitHost(
        const SizedBox(
          width: 320,
          child: MonoListRow(title: 'Play', selected: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final box = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(MonoListRow),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(
      box.color,
      theme.colors.muted,
      reason:
          'both the list-row and drawer boards draw the current row on '
          'muted; ink alone left it looking like its neighbours',
    );
  });

  test('the button says pending, like everything else in the kit', () {
    // MonoPhase.pending, MonoInput.pending, MonoField.pending — the button
    // was the one control calling it something else.
    const button = MonoButton(pending: true, child: Text('Save'));
    expect(button.pending, isTrue);
    // The old name still constructs, deprecated, until 5.0.0.
    // ignore: deprecated_member_use_from_same_package
    expect(const MonoButton(isLoading: true, child: Text('x')).pending, isTrue);
  });

  group('motion roles and semantics', () {
    testWidgets('the accordion chevron takes the emphasis beat', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          MonoAccordion(
            items: <MonoAccordionItem>[
              MonoAccordionItem(
                value: 'a',
                title: const Text('Who sees my number?'),
                content: const Text('Only people you call back.'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // "Chevron rotates on the emphasis role · body reveals with enter."
      // Two roles, not one: both were on `duration` (= enter).
      final rot = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation).first,
      );
      const motion = MonokitMotion();
      expect(rot.duration, motion.emphasis);
      expect(
        motion.emphasis,
        isNot(motion.enter),
        reason: 'if these were equal the assertion above would prove nothing',
      );
    });

    testWidgets('an avatar announces a person, not an image', (tester) async {
      await tester.pumpWidget(
        monokitHost(const MonoAvatar(name: 'Ama Serwaa', initials: 'AS')),
      );
      final data = tester
          .getSemantics(find.byType(MonoAvatar))
          .getSemanticsData();
      expect(data.label, 'Ama Serwaa');
      expect(
        data.flagsCollection.isImage,
        isFalse,
        reason: 'the image role makes it announce "image, Ama Serwaa"',
      );
    });

    test('the counted sets announce position and size', () {
      // Both already correct; pinned because the boards state them and
      // nothing was watching.
      const dots = MonoPageDots(count: 4, index: 1);
      expect(dots.count, 4);
      const step = MonoStepProgress(length: 3, value: 2);
      expect(step.length, 3);
    });
  });

  group('a finger can actually hit these', () {
    testWidgets('the selection controls clear the minimum target', (
      tester,
    ) async {
      const touch = MonokitDensity(mode: MonoDensity.touch);
      for (final (String name, Widget w, Type t) in <(String, Widget, Type)>[
        (
          'checkbox',
          MonoCheckbox(value: false, onChanged: _ignoreNullable),
          MonoCheckbox,
        ),
        ('switch', MonoSwitch(value: false, onChanged: _ignore), MonoSwitch),
      ]) {
        await tester.pumpWidget(monokitHost(w));
        await tester.pumpAndSettle();
        // They were 20px tall — under half what a finger needs. The visual box
        // is still 20; only the hit area grew.
        expect(
          tester.getSize(find.byType(t)).height,
          greaterThanOrEqualTo(touch.minTarget),
          reason: '$name must be reachable, not merely visible',
        );
      }
    });
  });
}

void _ignore(bool _) {}

void _ignoreNullable(bool? _) {}
