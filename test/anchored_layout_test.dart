import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

MonoAnchoredLayoutDelegate _delegate({
  required Rect anchorRect,
  MonoPlacement placement = MonoPlacement.bottomStart,
  EdgeInsets padding = EdgeInsets.zero,
  EdgeInsets viewInsets = EdgeInsets.zero,
  double gap = 0,
  double margin = 8,
  bool matchAnchorWidth = false,
}) {
  return MonoAnchoredLayoutDelegate(
    anchorRect: anchorRect,
    placement: placement,
    textDirection: TextDirection.ltr,
    padding: padding,
    viewInsets: viewInsets,
    gap: gap,
    margin: margin,
    matchAnchorWidth: matchAnchorWidth,
  );
}

void main() {
  const Size screen = Size(800, 600);
  const BoxConstraints screenConstraints = BoxConstraints.tightFor(
    width: 800,
    height: 600,
  );

  group('MonoAnchoredLayoutDelegate constraints', () {
    test('caps maxHeight to the larger side beside the anchor', () {
      // Anchor near the bottom: above has ~452px, below has ~92px.
      final delegate = _delegate(
        anchorRect: const Rect.fromLTWH(100, 460, 200, 40),
      );
      final constraints = delegate.getConstraintsForChild(screenConstraints);
      expect(constraints.maxHeight, closeTo(460 - 8, 0.001));
      expect(constraints.maxHeight, lessThan(screen.height));
    });

    test('subtracts the keyboard from available space', () {
      final open = _delegate(
        anchorRect: const Rect.fromLTWH(100, 100, 200, 40),
      ).getConstraintsForChild(screenConstraints);
      final withKeyboard = _delegate(
        anchorRect: const Rect.fromLTWH(100, 100, 200, 40),
        viewInsets: const EdgeInsets.only(bottom: 300),
      ).getConstraintsForChild(screenConstraints);
      expect(
        withKeyboard.maxHeight,
        lessThan(open.maxHeight),
        reason: 'keyboard insets shrink the safe rect',
      );
    });

    test('matchAnchorWidth pins the width to the anchor', () {
      final constraints = _delegate(
        anchorRect: const Rect.fromLTWH(100, 100, 220, 40),
        matchAnchorWidth: true,
      ).getConstraintsForChild(screenConstraints);
      expect(constraints.minWidth, 220);
      expect(constraints.maxWidth, 220);
    });
  });

  group('MonoAnchoredLayoutDelegate position', () {
    test('flips above when the bottom side cannot fit the measured child', () {
      final delegate = _delegate(
        anchorRect: const Rect.fromLTWH(100, 500, 200, 40),
      );
      final position = delegate.getPositionForChild(
        screen,
        const Size(200, 200),
      );
      expect(
        position.dy + 200,
        lessThanOrEqualTo(500),
        reason: 'menu sits fully above the anchor',
      );
    });

    test('clamps horizontally for an anchor at the right edge', () {
      final delegate = _delegate(
        anchorRect: const Rect.fromLTWH(760, 100, 40, 40),
      );
      final position = delegate.getPositionForChild(
        screen,
        const Size(300, 100),
      );
      expect(position.dx + 300, lessThanOrEqualTo(800 - 8));
      expect(position.dx, greaterThanOrEqualTo(8));
    });

    test('keeps the child inside the safe rect above the keyboard', () {
      final delegate = _delegate(
        anchorRect: const Rect.fromLTWH(100, 250, 200, 40),
        viewInsets: const EdgeInsets.only(bottom: 300),
      );
      final position = delegate.getPositionForChild(
        screen,
        const Size(200, 150),
      );
      expect(position.dy + 150, lessThanOrEqualTo(600 - 300 - 8));
    });

    test('zero-size anchor (context menu tap point) stays on screen', () {
      final delegate = _delegate(
        anchorRect: const Rect.fromLTWH(795, 595, 0, 0),
      );
      final position = delegate.getPositionForChild(
        screen,
        const Size(240, 320),
      );
      expect(position.dx + 240, lessThanOrEqualTo(800 - 8));
      expect(position.dy + 320, lessThanOrEqualTo(600 - 8));
    });
  });

  group('anchored overlays end to end', () {
    testWidgets('select menu near the bottom edge stays on screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        MonokitApp(
          theme: MonokitThemeData.light(),
          home: Align(
            alignment: Alignment.bottomCenter,
            child: MonoSelect<int>(
              options: List<MonoSelectOption<int>>.generate(
                30,
                (int i) =>
                    MonoSelectOption<int>.text(value: i, label: 'Option $i'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MonoSelect<int>));
      await tester.pumpAndSettle();

      final Finder menu = find.bySemanticsLabel('Select options');
      expect(menu, findsOneWidget);
      final Rect menuRect = tester.getRect(menu);
      final Size screenSize =
          tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(menuRect.bottom, lessThanOrEqualTo(screenSize.height));
      expect(menuRect.top, greaterThanOrEqualTo(0));
      expect(menuRect.left, greaterThanOrEqualTo(0));
      expect(menuRect.right, lessThanOrEqualTo(screenSize.width));
    });

    testWidgets('long select opens with the selected option visible', (
      tester,
    ) async {
      await tester.pumpWidget(
        MonokitApp(
          theme: MonokitThemeData.light(),
          home: Center(
            child: MonoSelect<int>(
              value: 25,
              options: List<MonoSelectOption<int>>.generate(
                30,
                (int i) =>
                    MonoSelectOption<int>.text(value: i, label: 'Option $i'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MonoSelect<int>));
      await tester.pumpAndSettle();

      // The selected option's row is laid out inside the menu viewport.
      final Finder selected = find.text('Option 25').last;
      expect(selected, findsOneWidget);
      final Rect rowRect = tester.getRect(selected);
      final Rect menuRect = tester.getRect(
        find.bySemanticsLabel('Select options'),
      );
      expect(
        menuRect.contains(rowRect.center),
        isTrue,
        reason: 'selection scrolled into view on open',
      );
    });
  });
}
