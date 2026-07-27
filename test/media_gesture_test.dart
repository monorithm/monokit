import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

import '_support/host.dart';

void main() {
  Widget page(int i) => SizedBox.expand(child: Text('page $i'));

  group('MonoFeedPager', () {
    testWidgets('inherits the app scroll physics rather than the platform '
        'default', (tester) async {
      // MonokitApp installs no ScrollBehavior before 2.0, so a PageView fell
      // through to Flutter's platform-conditional physics — bouncy on iOS,
      // clamping on Android, for the same widget.
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            height: 400,
            width: 300,
            child: MonoFeedPager(itemCount: 3, itemBuilder: (_, i) => page(i)),
          ),
        ),
      );

      // Assert the *resolved* physics on the position, not the widget's
      // declared physics: Scrollable composes widget.physics.applyTo(config),
      // so the inherited behaviour only appears down the position's chain.
      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      var found = false;
      for (ScrollPhysics? p = position.physics; p != null; p = p.parent) {
        if (p is BouncingScrollPhysics) found = true;
      }
      expect(
        found,
        isTrue,
        reason: 'MonokitScrollBehavior should supply BouncingScrollPhysics',
      );

      // And it must be the monokit behaviour doing it, not a platform default.
      final context = tester.element(find.byType(Scrollable));
      expect(ScrollConfiguration.of(context), isA<MonokitScrollBehavior>());
    });

    testWidgets('snaps a fling to the next page', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            height: 400,
            width: 300,
            child: MonoFeedPager(itemCount: 3, itemBuilder: (_, i) => page(i)),
          ),
        ),
      );
      expect(find.text('page 0'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(0, -300), 1200);
      await tester.pumpAndSettle();

      expect(find.text('page 1'), findsOneWidget);
      expect(find.text('page 0'), findsNothing);
    });
  });

  group('MonoGalleryViewer', () {
    testWidgets('is inert without onDismiss', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            height: 400,
            width: 300,
            child: MonoGalleryViewer(
              itemCount: 2,
              itemBuilder: (_, i) => page(i),
            ),
          ),
        ),
      );
      // No drag-dismiss gesture is installed at all.
      expect(
        find.byWidgetPredicate(
          (w) => w is GestureDetector && w.onVerticalDragUpdate != null,
        ),
        findsNothing,
      );
    });

    testWidgets('a downward fling dismisses', (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            height: 400,
            width: 300,
            child: MonoGalleryViewer(
              itemCount: 2,
              itemBuilder: (_, i) => page(i),
              onDismiss: () => dismissed++,
            ),
          ),
        ),
      );

      await tester.fling(find.text('page 0'), const Offset(0, 260), 900);
      await tester.pumpAndSettle();

      expect(dismissed, 1);
    });

    testWidgets('a small drag released gently springs back and does not '
        'dismiss', (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            height: 400,
            width: 300,
            child: MonoGalleryViewer(
              itemCount: 2,
              itemBuilder: (_, i) => page(i),
              onDismiss: () => dismissed++,
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('page 0')),
      );
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dismissed, 0);
    });
  });
}
