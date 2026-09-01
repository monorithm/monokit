import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

void main() {
  group('MonoMetaLine', () {
    testWidgets('shows one fact at a time and completes the set once', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoMetaLine(
            facts: <String>['2h ago · Osu, 400m · 1/3', 'Here since June'],
          ),
        ),
      );

      // Every fact is laid out twice: an invisible ghost that reserves the
      // width, and the live one inside the switcher. The ghosts are siblings
      // of the switcher, so scoping to its descendants finds only what is
      // actually being shown.
      Finder showing(String text) => find.descendant(
        of: find.byType(AnimatedSwitcher),
        matching: find.text(text),
      );

      expect(showing('2h ago · Osu, 400m · 1/3'), findsOneWidget);
      expect(showing('Here since June'), findsNothing);

      // Two facts across ten seconds is five each.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(showing('Here since June'), findsOneWidget);
      expect(showing('2h ago · Osu, 400m · 1/3'), findsNothing);

      // The set completes exactly once: it does not wrap back to the first.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(showing('Here since June'), findsOneWidget);
      expect(
        showing('2h ago · Osu, 400m · 1/3'),
        findsNothing,
        reason: 'the set completes once; it is not a carousel',
      );
    });

    testWidgets('reserves the width of its longest fact', (tester) async {
      Future<double> widthOf(List<String> facts) async {
        await tester.pumpWidget(monokitHost(MonoMetaLine(facts: facts)));
        await tester.pumpAndSettle();
        return tester.getSize(find.byType(MonoMetaLine)).width;
      }

      final short = await widthOf(<String>['1/3']);
      final withLonger = await widthOf(<String>['1/3', 'Here since June']);
      expect(
        withLonger,
        greaterThan(short),
        reason: 'the box is the widest fact, so the caption never reflows',
      );
    });

    testWidgets('a stopped item has a still caption', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoMetaLine(
            running: false,
            facts: <String>['first', 'second'],
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 20));
      await tester.pumpAndSettle();
      // Still on the first: same clock as the item, and the item is paused.
      expect(
        find.descendant(
          of: find.byType(AnimatedSwitcher),
          matching: find.text('first'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the whole set is one label, and not a live region', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoMetaLine(
            facts: <String>['2h ago', 'Here since June'],
            semanticLabel: '2 hours ago. Here since June.',
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('2 hours ago. Here since June.'),
        findsOneWidget,
      );
      // A live region would interrupt a screen reader every five seconds.
      final node = tester.getSemantics(find.byType(MonoMetaLine));
      expect(node.getSemanticsData().flagsCollection.isLiveRegion, isFalse);
    });
  });

  group('MonoUploadSlot', () {
    testWidgets('a filled slot carries its position', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          MonoUploadSlot.filled(
            position: 1,
            onPressed: () {},
            child: const SizedBox.expand(),
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
    });

    testWidgets('an empty slot draws the ring, a filled one does not', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(MonoUploadSlot.empty(onPressed: () {})),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpWidget(
        monokitHost(
          MonoUploadSlot.filled(
            onPressed: () {},
            child: const SizedBox.expand(),
          ),
        ),
      );
      // The ring is the shape of a thing that could exist; once the slot holds
      // something there is nothing left to promise.
      expect(
        find.descendant(
          of: find.byType(MonoUploadSlot),
          matching: find.byType(ClipRRect),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a disabled slot does not fire', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        monokitHost(
          MonoUploadSlot.empty(enabled: false, onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(MonoUploadSlot), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('the document row names the thing and what a good one is', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          MonoUploadSlot.document(
            title: 'Add a photo or a PDF',
            hint: 'All four corners visible',
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Add a photo or a PDF'), findsOneWidget);
      expect(find.text('All four corners visible'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Add a photo or a PDF. All four corners visible'),
        findsOneWidget,
      );
      // The row sits on the two-line rhythm.
      expect(
        tester.getSize(find.byType(MonoUploadSlot)).height,
        greaterThanOrEqualTo(
          const MonokitDensity(mode: MonoDensity.touch).row2,
        ),
      );
    });
  });
}
