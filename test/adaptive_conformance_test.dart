import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Pins the adaptive behaviour the density group has described since 3.2.0 and
/// nothing consumed until now.
///
/// The failure these guard against is not a wrong number — it is a widget that
/// reads no density token at all and therefore renders identically on a phone
/// and a desktop. That is invisible to a golden (which runs at one density)
/// and to every test that only ever pumps one.
void main() {
  Widget atDensity(MonoDensity mode, Widget child) => monokitHost(
    MonokitTheme(
      data: MonokitThemeData.light().copyWith(
        density: MonokitDensity(mode: mode),
      ),
      child: child,
    ),
  );

  group('the density group carries what the boards use', () {
    test('chip, menu row, textarea and field inset resolve both ways', () {
      const touch = MonokitDensity(mode: MonoDensity.touch);
      const pointer = MonokitDensity(mode: MonoDensity.pointer);

      expect(touch.chip, 36);
      expect(pointer.chip, 32);
      expect(touch.menuRow, 44);
      expect(pointer.menuRow, 36);
      expect(touch.textareaMin, 88);
      expect(pointer.textareaMin, 72);
      expect(touch.fieldInset, 16);
      expect(pointer.fieldInset, 12);
    });
  });

  group('MonoListRow rides the row ladder', () {
    Future<double> heightOf(
      WidgetTester tester,
      MonoDensity mode, {
      String? subtitle,
      String? overline,
    }) async {
      await tester.pumpWidget(
        atDensity(
          mode,
          // mainAxisSize.min so the row takes its intrinsic height rather than
          // filling the host — the row only sets a minHeight.
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 360,
                child: MonoListRow(
                  title: 'Request a call',
                  subtitle: subtitle,
                  overline: overline,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester.getSize(find.byType(MonoListRow)).height;
    }

    testWidgets('48 / 64 / 88 at touch', (tester) async {
      expect(await heightOf(tester, MonoDensity.touch), 48);
      expect(await heightOf(tester, MonoDensity.touch, subtitle: 'Osu'), 64);
      expect(
        await heightOf(
          tester,
          MonoDensity.touch,
          subtitle: 'Osu',
          overline: 'Saved sellers',
        ),
        88,
      );
    });

    testWidgets('40 / 56 / 76 at pointer', (tester) async {
      // The whole point. Before this, every one of these was 48 or 64 because
      // the height came from a fixed spacing token.
      expect(await heightOf(tester, MonoDensity.pointer), 40);
      expect(await heightOf(tester, MonoDensity.pointer, subtitle: 'Osu'), 56);
      expect(
        await heightOf(
          tester,
          MonoDensity.pointer,
          subtitle: 'Osu',
          overline: 'Saved sellers',
        ),
        76,
      );
    });

    testWidgets('a row actually changes height between densities', (
      tester,
    ) async {
      final touch = await heightOf(tester, MonoDensity.touch);
      final pointer = await heightOf(tester, MonoDensity.pointer);
      expect(
        touch,
        greaterThan(pointer),
        reason: 'a row that ignores density renders the same at both',
      );
    });
  });

  testWidgets('the tab bar is chrome height, not a control', (tester) async {
    await tester.pumpWidget(
      monokitHost(
        SizedBox(
          width: 390,
          child: MonoBottomNav(
            selectedIndex: 0,
            onSelected: (_) {},
            items: const <MonoBottomNavItem>[
              MonoBottomNavItem(icon: MonoIcons.search, label: 'Search'),
              MonoBottomNavItem(icon: MonoIcons.settings, label: 'You'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(MonoBottomNav)).height,
      greaterThanOrEqualTo(MonokitChrome.tabBarHeight),
    );
    // "Labels always on" — an icon-only destination is a glyph nobody taught.
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
  });

  group('MonoTooltip is a pointer affordance', () {
    testWidgets('touch renders the child and the label, no overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        atDensity(
          MonoDensity.touch,
          const MonoTooltip(message: 'Saved', child: Text('star')),
        ),
      );
      await tester.pumpAndSettle();
      // The label still reaches assistive technology at touch.
      expect(find.byType(Semantics), findsWidgets);
      expect(find.text('star'), findsOneWidget);
      // But the tooltip's own hover/focus machinery is never built.
      expect(
        find.descendant(
          of: find.byType(MonoTooltip),
          matching: find.byType(Focus),
        ),
        findsNothing,
      );
    });

    testWidgets('pointer builds the hover path', (tester) async {
      await tester.pumpWidget(
        atDensity(
          MonoDensity.pointer,
          const MonoTooltip(message: 'Saved', child: Text('star')),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(MonoTooltip),
          matching: find.byType(Focus),
        ),
        findsWidgets,
      );
    });
  });

  test('radii match the surfaces the boards name', () {
    const r = MonokitRadii();
    // Card is lg; the centred modal and the sheet are xxl.
    expect(r.lg, 10);
    expect(r.xxl, 18);
  });

  group('menu rows ride the menu ladder', () {
    /// The minHeight the option row is actually built with.
    ///
    /// One density per test on purpose: an already-inserted overlay does not
    /// rebuild when the theme above it changes, so pumping both in one test
    /// measures the first one twice.
    Future<double> rowMinHeight(WidgetTester tester, MonoDensity mode) async {
      await tester.pumpWidget(
        monokitHost(
          theme: MonokitThemeData.light().copyWith(
            density: MonokitDensity(mode: mode),
          ),
          SizedBox(
            width: 320,
            child: MonoSelect<String>(
              open: true,
              options: const <MonoSelectOption<String>>[
                MonoSelectOption<String>(value: 'a', label: Text('Starter')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boxes = tester.widgetList<AnimatedContainer>(
        find.ancestor(
          of: find.text('Starter'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      return boxes
          .map((AnimatedContainer c) => c.constraints?.minHeight ?? 0)
          .fold<double>(0, (double a, double b) => a > b ? a : b);
    }

    testWidgets('44 at touch', (tester) async {
      // Both select and dropdown_menu pinned this at spacing.xxxl — a fixed
      // 32, short of both steps and under the minimum target at touch.
      expect(await rowMinHeight(tester, MonoDensity.touch), 44);
    });

    testWidgets('36 at pointer', (tester) async {
      expect(await rowMinHeight(tester, MonoDensity.pointer), 36);
    });

    test('a menu row clears the target a finger needs', () {
      const touch = MonokitDensity(mode: MonoDensity.touch);
      expect(touch.menuRow, greaterThanOrEqualTo(touch.minTarget));
    });
  });
}
