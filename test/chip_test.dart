import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// [MonoChip] had no tests at all, which is how it drifted from the colour
/// standard without anything noticing: it inverted on selection (foreground
/// fill, page-coloured text) while `02-color-and-surface.md` had already
/// assigned "selected chips" to the `primary`/`primarySoft` soft grammar.
/// These pin the treatment to the tokens rather than to literal colours, so a
/// palette change moves them and a grammar change breaks them.
/// The capsule's own fill. The chip nests several Containers (the focus ring
/// puts one outside the painted body), so this takes the first that actually
/// carries a colour rather than the first in tree order.
Color _fillOf(WidgetTester tester) {
  for (final Container box in tester.widgetList<Container>(
    find.descendant(
      of: find.byType(MonoChip),
      matching: find.byType(Container),
    ),
  )) {
    final Decoration? decoration = box.decoration;
    if (decoration is BoxDecoration && decoration.color != null) {
      return decoration.color!;
    }
  }
  fail('the chip painted no filled Container');
}

TextStyle _labelStyleOf(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style!;

void main() {
  group('MonoChip selection', () {
    testWidgets('selected takes the soft brand fill under the brand ink - the '
        'grammar the colour standard assigns to a selected chip', (
      tester,
    ) async {
      final MonokitThemeData theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          MonoChip(label: 'City', selected: true, onPressed: () {}),
          theme: theme,
        ),
      );

      expect(_fillOf(tester), theme.colors.primarySoft);
      expect(_labelStyleOf(tester, 'City').color, theme.colors.primaryText);
    });

    testWidgets('selected is NOT an inverted pill - a solid foreground fill '
        'would outrank the primary button beside it', (tester) async {
      final MonokitThemeData theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          MonoChip(label: 'City', selected: true, onPressed: () {}),
          theme: theme,
        ),
      );

      expect(_fillOf(tester), isNot(theme.colors.foreground));
      expect(
        _labelStyleOf(tester, 'City').color,
        isNot(theme.colors.background),
      );
    });

    testWidgets('unselected sits on the de-emphasis well under the plain '
        'foreground', (tester) async {
      final MonokitThemeData theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          MonoChip(label: 'City', onPressed: () {}),
          theme: theme,
        ),
      );

      expect(_fillOf(tester), theme.colors.muted);
      expect(_labelStyleOf(tester, 'City').color, theme.colors.foreground);
    });

    testWidgets('selection survives without colour: the label thickens and '
        'the node reports selected', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(MonoChip(label: 'City', selected: true, onPressed: () {})),
      );
      expect(_labelStyleOf(tester, 'City').fontWeight, FontWeight.w500);

      await tester.pumpWidget(
        monokitHost(MonoChip(label: 'Street', onPressed: () {})),
      );
      expect(_labelStyleOf(tester, 'Street').fontWeight, FontWeight.w400);

      await tester.pumpWidget(
        monokitHost(MonoChip(label: 'City', selected: true, onPressed: () {})),
      );
      // `isSemantics`, the partial matcher: it asserts the selected flag
      // without also pinning the whole action set, which is not what this
      // test is about.
      expect(
        tester.getSemantics(find.byType(MonoChip)),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('both weights darken toward their own ink on press - no fill '
        'in this kit lightens under the finger', (tester) async {
      final MonokitThemeData theme = MonokitThemeData.light();
      for (final bool selected in <bool>[true, false]) {
        await tester.pumpWidget(
          monokitHost(
            MonoChip(label: 'City', selected: selected, onPressed: () {}),
            theme: theme,
          ),
        );
        final Color resting = _fillOf(tester);

        final Color ink = selected
            ? theme.colors.primaryText
            : theme.colors.foreground;

        final TestGesture gesture = await tester.createGesture();
        await gesture.down(tester.getCenter(find.byType(MonoChip)));
        await tester.pump();
        final Color pressed = _fillOf(tester);
        await gesture.up();
        await tester.pump();

        expect(pressed, isNot(resting), reason: 'selected=$selected inert');
        // Toward its OWN ink. While selection inverted, the selected chip
        // lerped toward `background` instead - the one fill in the kit that
        // got lighter under the finger.
        expect(
          pressed,
          Color.lerp(resting, ink, 0.1),
          reason: 'selected=$selected did not move toward its ink',
        );
      }
    });

    testWidgets('dark mode keeps the same grammar, not the same values', (
      tester,
    ) async {
      final MonokitThemeData dark = MonokitThemeData.dark();
      await tester.pumpWidget(
        monokitHost(
          MonoChip(label: 'City', selected: true, onPressed: () {}),
          theme: dark,
        ),
      );

      expect(_fillOf(tester), dark.colors.primarySoft);
      expect(_labelStyleOf(tester, 'City').color, dark.colors.primaryText);
      expect(dark.colors.primarySoft, isNot(MonokitColors.light().primarySoft));
    });
  });
}
