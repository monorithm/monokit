import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

import '_support/host.dart';

/// Contracts for the 2.1 residuals — the two variant ladders the 2.0 plan
/// specified but 2.0 shipped without, and the accordion height the motion
/// doctrine had left on a curve.
void main() {
  group('MonoBadgeVariant', () {
    test('is the state vocabulary and nothing else', () {
      // 2.0 still carried primary/secondary/outline: three ways to say "no
      // particular status", one of which drew a border the grouped surface
      // model had abolished. If this list grows a brand or shape variant
      // again, that is the regression.
      expect(MonoBadgeVariant.values, <MonoBadgeVariant>[
        MonoBadgeVariant.neutral,
        MonoBadgeVariant.success,
        MonoBadgeVariant.warning,
        MonoBadgeVariant.danger,
        MonoBadgeVariant.info,
        MonoBadgeVariant.live,
      ]);
    });

    test('neutral is the default and resolves to the quiet fill', () {
      final theme = MonokitThemeData.light();
      const resolver = MonoBadgeStyleResolver();

      final neutral = resolver.resolve(
        theme: theme,
        variant: MonoBadgeVariant.neutral,
        size: MonoBadgeSize.md,
      );
      expect(neutral.background, theme.colors.fill);
      expect(neutral.foreground, theme.colors.foreground);

      // The old default was an emerald fill, which competed with the primary
      // button for attention. A badge reports state; it does not solicit.
      expect(
        const MonoBadge(child: Text('x')).variant,
        MonoBadgeVariant.neutral,
      );
      expect(neutral.background, isNot(theme.colors.primary));
    });

    test('danger keeps the contrast-safe soft/text pairing', () {
      final theme = MonokitThemeData.dark();
      final danger = const MonoBadgeStyleResolver().resolve(
        theme: theme,
        variant: MonoBadgeVariant.danger,
        size: MonoBadgeSize.md,
      );
      expect(danger.background, theme.colors.dangerSoft);
      expect(danger.foreground, theme.colors.dangerText);
    });
  });

  group('MonoTabsVariant', () {
    test('is {line, segmented} with line first', () {
      expect(MonoTabsVariant.values, <MonoTabsVariant>[
        MonoTabsVariant.line,
        MonoTabsVariant.segmented,
      ]);
    });

    testWidgets('defaults to line, which adds no second filled surface', (
      tester,
    ) async {
      final theme = MonokitThemeData.light();
      List<MonoTab> tabs() => <MonoTab>[
        MonoTab.text(value: 'a', label: 'A', content: const Text('Panel A')),
        MonoTab.text(value: 'b', label: 'B', content: const Text('Panel B')),
      ];

      await tester.pumpWidget(monokitHost(MonoTabs(tabs: tabs())));
      expect(
        tester.widget<MonoTabs>(find.byType(MonoTabs)).variant,
        MonoTabsVariant.line,
      );
      // The trigger list is undecorated under `line`: on a card that is
      // already the focus, a filled strip would be a competing surface.
      final lineFills = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (b) => (b.decoration as BoxDecoration).color == theme.colors.fill,
          );
      expect(lineFills, isEmpty);

      await tester.pumpWidget(
        monokitHost(MonoTabs(tabs: tabs(), variant: MonoTabsVariant.segmented)),
      );
      await tester.pumpAndSettle();
      final segmentedFills = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (b) => (b.decoration as BoxDecoration).color == theme.colors.fill,
          );
      expect(segmentedFills, isNotEmpty);
    });
  });

  group('MonoAccordion height', () {
    Widget accordion() => monokitHost(
      SizedBox(
        width: 400,
        child: MonoAccordion(
          items: <MonoAccordionItem>[
            MonoAccordionItem.text(
              value: 'one',
              title: 'One',
              content: const SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );

    double panelHeight(WidgetTester tester) =>
        tester.getSize(find.byType(Align).last).height;

    testWidgets('springs open over several frames rather than snapping', (
      tester,
    ) async {
      await tester.pumpWidget(accordion());
      expect(panelHeight(tester), 0);

      await tester.tap(find.text('One'));
      await tester.pump();
      final atStart = panelHeight(tester);

      await tester.pump(const Duration(milliseconds: 40));
      final midway = panelHeight(tester);

      await tester.pumpAndSettle();
      final resting = panelHeight(tester);

      // Partway open: neither still shut nor already finished. Asserted
      // relationally rather than against a number, because the resting height
      // is the content plus the panel's bottom padding token.
      expect(atStart, lessThan(midway));
      expect(midway, lessThan(resting));
      expect(resting, greaterThan(0));
    });

    testWidgets('overshoots past its resting height on the way open', (
      tester,
    ) async {
      await tester.pumpWidget(accordion());
      await tester.tap(find.text('One'));
      await tester.pump();

      var peak = 0.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        peak = peak > panelHeight(tester) ? peak : panelHeight(tester);
      }

      await tester.pumpAndSettle();
      final resting = panelHeight(tester);

      // The ceiling on heightFactor is deliberately left open so the spring
      // reads as momentum. If someone clamps it to 1, this is what notices.
      expect(peak, greaterThan(resting));
    });

    testWidgets('honours reduced motion by arriving immediately', (
      tester,
    ) async {
      await tester.pumpWidget(
        MonokitApp(
          theme: MonokitThemeData.light(),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: MonoAccordion(
                    items: <MonoAccordionItem>[
                      MonoAccordionItem.text(
                        value: 'one',
                        title: 'One',
                        content: const SizedBox(height: 120),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('One'));
      await tester.pump();
      final afterOneFrame = panelHeight(tester);

      await tester.pumpAndSettle();
      expect(afterOneFrame, panelHeight(tester));
      expect(afterOneFrame, greaterThan(0));
    });

    testWidgets('adopts its resting state on mount without animating', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 400,
            child: MonoAccordion(
              defaultValue: 'one',
              items: <MonoAccordionItem>[
                MonoAccordionItem.text(
                  value: 'one',
                  title: 'One',
                  content: const SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ),
      );
      // First frame, no settle: an accordion that animates itself open on
      // mount is a distraction, so the spring starts at rest.
      final onMount = panelHeight(tester);
      await tester.pumpAndSettle();
      expect(onMount, panelHeight(tester));
      expect(onMount, greaterThan(0));
    });
  });
}
