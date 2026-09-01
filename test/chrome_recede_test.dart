import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

void main() {
  Widget scope({
    MonoChromePolicy policy = MonoChromePolicy.resting,
    Object? subject,
    bool inhibited = false,
    bool summoned = false,
    Duration idle = const Duration(seconds: 10),
  }) => monokitHost(
    MonoChromeScope(
      policy: policy,
      subject: subject,
      inhibited: inhibited,
      summoned: summoned,
      idleDelay: idle,
      child: const SizedBox(
        width: 300,
        height: 400,
        child: Stack(
          children: <Widget>[
            MonoChrome(child: Text('Call')),
            MonoChrome(subjectTruth: true, child: Text('LIVE')),
          ],
        ),
      ),
    ),
  );

  double chromeOpacity(WidgetTester tester, String label) => tester
      .widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      )
      .opacity;

  group('the three policies', () {
    testWidgets('persistent never rests, however long the watch', (
      tester,
    ) async {
      await tester.pumpWidget(scope(policy: MonoChromePolicy.persistent));
      await tester.pump(const Duration(minutes: 5));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 1);
    });

    testWidgets('resting hides after the idle delay', (tester) async {
      await tester.pumpWidget(scope());
      expect(chromeOpacity(tester, 'Call'), 1);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 0);
    });

    testWidgets('hidden is absent until summoned', (tester) async {
      await tester.pumpWidget(scope(policy: MonoChromePolicy.hidden));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 0);

      await tester.pumpWidget(
        scope(policy: MonoChromePolicy.hidden, summoned: true),
      );
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 1);
    });
  });

  group('the clock belongs to the item', () {
    testWidgets('a new subject arrives with its chrome', (tester) async {
      await tester.pumpWidget(scope(subject: 1));
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 0);

      // Advancing is a new subject, and the timer starts over.
      await tester.pumpWidget(scope(subject: 2));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 1);
    });

    testWidgets('the delay never cuts an item short', (tester) async {
      // The meta line needs the full ten seconds; a rest at three would bury
      // its second fact.
      await tester.pumpWidget(scope());
      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 1);
    });
  });

  group('what never recedes', () {
    testWidgets('subject truth stays through a rest', (tester) async {
      await tester.pumpWidget(scope());
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 0);
      // The live badge is subject truth, not convenience.
      expect(find.text('LIVE'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('LIVE'),
          matching: find.byType(AnimatedOpacity),
        ),
        findsNothing,
        reason: 'subject truth is not wrapped in the fade at all',
      );
    });

    testWidgets('an inhibited scope holds chrome up', (tester) async {
      // Paused, buffering, an overlay open, a field focused, a pointer over a
      // control — all report through one flag.
      await tester.pumpWidget(scope(inhibited: true));
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();
      expect(chromeOpacity(tester, 'Call'), 1);
    });
  });

  testWidgets('hidden chrome leaves the traversal order', (tester) async {
    await tester.pumpWidget(scope());
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    final excluded = tester.widget<ExcludeSemantics>(
      find
          .ancestor(
            of: find.text('Call'),
            matching: find.byType(ExcludeSemantics),
          )
          .first,
    );
    expect(excluded.excluding, isTrue);
  });

  group('hold to clear is a sustain, not a toggle', () {
    Offset translationOf(WidgetTester tester, String label) {
      final t = tester.widget<Transform>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Transform))
            .first,
      );
      return Offset(
        t.transform.getTranslation().x,
        t.transform.getTranslation().y,
      );
    }

    testWidgets('clear while the finger is down, back on release', (
      tester,
    ) async {
      await tester.pumpWidget(scope());
      expect(chromeOpacity(tester, 'Call'), 1);

      // The host centres its child, so press where the media actually is.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MonoChromeScope)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(
        chromeOpacity(tester, 'Call'),
        0,
        reason: 'the screen is clear while held',
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(
        chromeOpacity(tester, 'Call'),
        1,
        reason: 'a sustain returns on release; a toggle would not',
      );
    });

    testWidgets('a held peek does not move; a timed recede does', (
      tester,
    ) async {
      // The divergence: the spec gives recede a translation toward the edge.
      // A momentary peek keeps its position, because the finger is still on
      // the glass and every control must be where the thumb left it.
      await tester.pumpWidget(scope());
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(MonoChromeScope)),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(translationOf(tester, 'Call'), Offset.zero);
      await gesture.up();
      await tester.pumpAndSettle();

      // Now let it rest on the clock instead.
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(
        translationOf(tester, 'Call').dy,
        greaterThan(0),
        reason: 'a timed recede travels toward its own edge as it fades',
      );
    });
  });
}
