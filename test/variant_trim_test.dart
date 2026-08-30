import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Contracts for the residuals cleared after 2.0 — the two variant ladders the
/// 2.0 plan specified but 2.0 shipped without, the accordion height the motion
/// doctrine had left on a curve, and the badge status treatment that had
/// drifted away from every other status-bearing component.
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
      expect(neutral.background, theme.colors.muted);
      expect(neutral.foreground, theme.colors.foreground);

      // The old default was an emerald fill, which competed with the primary
      // button for attention. A badge reports state; it does not solicit.
      expect(
        const MonoBadge(child: Text('x')).variant,
        MonoBadgeVariant.neutral,
      );
      expect(neutral.background, isNot(theme.colors.primary));
    });

    test('every semantic status is a soft fill with its own text colour', () {
      // Through 2.1 only `danger` was soft; success, warning and info were
      // saturated fills on `onStatus`. A row of status badges came out half
      // shouting and half whispering, with the quiet one being the alarm.
      // Asserted per-family rather than as one lump so a failure names the
      // status that drifted.
      for (final theme in <MonokitThemeData>[
        MonokitThemeData.light(),
        MonokitThemeData.dark(),
      ]) {
        final c = theme.colors;
        final expected = <MonoBadgeVariant, (Color, Color)>{
          MonoBadgeVariant.success: (c.successSoft, c.successText),
          MonoBadgeVariant.warning: (c.warningSoft, c.warningText),
          MonoBadgeVariant.danger: (c.destructiveSoft, c.destructiveText),
          MonoBadgeVariant.info: (c.infoSoft, c.infoText),
        };
        expected.forEach((variant, pair) {
          final style = const MonoBadgeStyleResolver().resolve(
            theme: theme,
            variant: variant,
            size: MonoBadgeSize.md,
          );
          expect(
            (style.background, style.foreground),
            pair,
            reason:
                '$variant in ${theme.brightness} must use the soft fill '
                'and its contrast-safe text, like MonoAlert already does',
          );
        });
      }
    });

    test('live stays loud — it is a signal, not a status', () {
      // The one deliberate exception to the soft rule. If someone "unifies"
      // this too, the live indicator stops reading as live.
      final theme = MonokitThemeData.dark();
      final live = const MonoBadgeStyleResolver().resolve(
        theme: theme,
        variant: MonoBadgeVariant.live,
        size: MonoBadgeSize.md,
      );
      expect(live.background, theme.colors.live);
      expect(live.foreground, theme.colors.liveForeground);
    });

    test('badges and alerts agree on what a status looks like', () {
      // The two status-bearing components must not diverge again. MonoAlert
      // uses the solid role only as a border accent; the badge is borderless,
      // so it shares just the fill and text.
      final theme = MonokitThemeData.light();
      final badge = const MonoBadgeStyleResolver().resolve(
        theme: theme,
        variant: MonoBadgeVariant.success,
        size: MonoBadgeSize.md,
      );
      expect(badge.background, theme.colors.successSoft);
      expect(badge.foreground, theme.colors.successText);
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
            (b) => (b.decoration as BoxDecoration).color == theme.colors.muted,
          );
      expect(lineFills, isEmpty);

      await tester.pumpWidget(
        monokitHost(MonoTabs(tabs: tabs(), variant: MonoTabsVariant.segmented)),
      );
      await tester.pumpAndSettle();
      final segmentedFills = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where(
            (b) => (b.decoration as BoxDecoration).color == theme.colors.muted,
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
