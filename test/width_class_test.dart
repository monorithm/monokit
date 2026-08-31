import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Width class resolution — the specification's own largest recorded gap until
/// now: the enum existed, and nothing computed it or provided it.
void main() {
  group('the thresholds cut four bands', () {
    test('classOf walks the boundaries', () {
      expect(MonokitBreakpoint.classOf(0), MonoWidthClass.compact);
      expect(MonokitBreakpoint.classOf(390), MonoWidthClass.compact);
      expect(MonokitBreakpoint.classOf(599.9), MonoWidthClass.compact);
      expect(MonokitBreakpoint.classOf(600), MonoWidthClass.medium);
      expect(MonokitBreakpoint.classOf(959.9), MonoWidthClass.medium);
      expect(MonokitBreakpoint.classOf(960), MonoWidthClass.expanded);
      expect(MonokitBreakpoint.classOf(1279.9), MonoWidthClass.expanded);
      expect(MonokitBreakpoint.classOf(1280), MonoWidthClass.wide);
      expect(MonokitBreakpoint.classOf(4000), MonoWidthClass.wide);
    });

    test('each class carries its columns and inset', () {
      expect(MonoWidthClass.compact.columns, 4);
      expect(MonoWidthClass.medium.columns, 8);
      expect(MonoWidthClass.expanded.columns, 12);
      expect(MonoWidthClass.wide.columns, 12);

      expect(MonoWidthClass.compact.pageInset, 16);
      expect(MonoWidthClass.medium.pageInset, 24);
      expect(MonoWidthClass.expanded.pageInset, 32);
      expect(MonoWidthClass.wide.pageInset, 32);
    });

    test('atLeast reads the way the boards are written', () {
      expect(MonoWidthClass.medium.atLeast(MonoWidthClass.medium), isTrue);
      expect(MonoWidthClass.expanded.atLeast(MonoWidthClass.medium), isTrue);
      expect(MonoWidthClass.compact.atLeast(MonoWidthClass.medium), isFalse);
    });
  });

  group('MonoWidthScope resolves per region', () {
    testWidgets('a scope measures its own box, not the window', (tester) async {
      late MonoWidthClass seen;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 400,
            child: MonoWidthScope(
              child: Builder(
                builder: (context) {
                  seen = MonoWidthScope.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(seen, MonoWidthClass.compact);
    });

    testWidgets('one screen can hold two classes at once', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // The case the whole design exists for. A 280 sidebar beside a 900 pane:
      // asking the window would call both of them expanded and compose the
      // sidebar as though it had 900px.
      late MonoWidthClass sidebar;
      late MonoWidthClass pane;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            // 280 sidebar leaves 1120 for the pane: compact beside expanded.
            width: 1400,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MonokitContainers.sidebar,
                  child: MonoWidthScope(
                    child: Builder(
                      builder: (context) {
                        sidebar = MonoWidthScope.of(context);
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: MonoWidthScope(
                    child: Builder(
                      builder: (context) {
                        pane = MonoWidthScope.of(context);
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(sidebar, MonoWidthClass.compact);
      expect(pane, MonoWidthClass.expanded);
      expect(
        sidebar,
        isNot(pane),
        reason: 'a per-window answer would make these equal',
      );
    });

    testWidgets('an unbounded scope defers to the window, not to infinity', (
      tester,
    ) async {
      late MonoWidthClass seen;
      await tester.pumpWidget(
        monokitHost(
          Row(
            children: <Widget>[
              // Unconstrained horizontally: maxWidth is infinite here.
              MonoWidthScope(
                child: Builder(
                  builder: (context) {
                    seen = MonoWidthScope.of(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      );
      expect(
        seen,
        isNot(MonoWidthClass.wide),
        reason: 'classOf(infinity) would be wide, which is meaningless here',
      );
    });

    testWidgets('MonokitApp installs a root scope', (tester) async {
      late MonoWidthClass? rooted;
      await tester.pumpWidget(
        monokitHost(
          Builder(
            builder: (context) {
              rooted = MonoWidthScope.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // An app that never splits its layout gets the right class for free.
      expect(rooted, isNotNull);
    });

    testWidgets('maybeOf is null outside any scope, and of falls back', (
      tester,
    ) async {
      late MonoWidthClass? bare;
      late MonoWidthClass fallback;
      // Deliberately not MonokitApp: this is the "someone dropped a monokit
      // widget into a foreign tree" case, where the window is all there is.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(700, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                bare = MonoWidthScope.maybeOf(context);
                fallback = MonoWidthScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(bare, isNull);
      expect(fallback, MonoWidthClass.medium, reason: 'the window, at 700');
    });

    testWidgets('the class follows a resize', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1600, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final classes = <MonoWidthClass>[];
      Widget probe(double width) => monokitHost(
        SizedBox(
          width: width,
          child: MonoWidthScope(
            child: Builder(
              builder: (context) {
                classes.add(MonoWidthScope.of(context));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(probe(1400));
      await tester.pumpWidget(probe(500));
      expect(classes.first, MonoWidthClass.wide);
      expect(classes.last, MonoWidthClass.compact);
    });
  });

  testWidgets('MonoPageInset pads by the resolved class', (tester) async {
    for (final (double width, double expected) in <(double, double)>[
      (390, 16),
      (700, 24),
      (1000, 32),
      (1400, 32),
    ]) {
      await tester.pumpWidget(
        monokitHost(
          MonoWidthScope(
            width: width,
            child: const MonoPageInset(child: SizedBox(height: 10)),
          ),
        ),
      );
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(MonoPageInset),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        (padding.padding as EdgeInsets).left,
        expected,
        reason: 'width $width should inset $expected',
      );
    }
  });

  group('width class composes real components', () {
    testWidgets('an alert caps at a text measure at medium and up', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<double> alertWidth(double scope) async {
        await tester.pumpWidget(
          monokitHost(
            MonoWidthScope(
              width: scope,
              child: const SizedBox(
                width: 1200,
                child: MonoAlert(description: Text('You are offline.')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.getSize(find.byType(DecoratedBox).first).width;
      }

      // Compact spans its container; medium and up stop at the measure.
      expect(await alertWidth(390), 1200);
      expect(await alertWidth(800), MonokitContainers.content);
      expect(await alertWidth(1400), MonokitContainers.content);
    });

    testWidgets('the feed letterboxes rather than widening the subject', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<double> itemWidth(double scope) async {
        await tester.pumpWidget(
          monokitHost(
            MonoWidthScope(
              width: scope,
              child: SizedBox(
                width: 1200,
                height: 800,
                child: MonoImmersiveFeed(
                  itemCount: 3,
                  itemBuilder: (context, index, phase) =>
                      const SizedBox.expand(child: Text('post')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester.getSize(find.text('post').first).width;
      }

      expect(await itemWidth(390), 1200, reason: 'compact is full bleed');
      expect(
        await itemWidth(1000),
        MonokitContainers.feed,
        reason: 'the reason a post does not stretch to 1200px on a tablet',
      );
    });
  });
}
