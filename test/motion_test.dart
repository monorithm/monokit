import 'dart:math' show sqrt;

import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

void main() {
  const motion = MonokitMotion();

  group('monoProject', () {
    test('projects a fling forward and a still finger nowhere', () {
      expect(monoProject(0.5, 0), 0.5);
      expect(monoProject(0.5, 1), greaterThan(0.5));
      expect(monoProject(0.5, -1), lessThan(0.5));
    });

    test('is why a hard flick past the midpoint still dismisses', () {
      // Released at 0.55 of the way open — nearer the open detent — but moving
      // toward dismissal fast. Deciding on projection rather than position is
      // the whole point.
      const detents = <double>[0.0, 1.0];
      expect(monoNearest(detents, 0.55), 1.0);
      expect(monoNearest(detents, monoProject(0.55, -4)), 0.0);
    });
  });

  group('monoRubberBand', () {
    test('resists, and never exceeds the dimension', () {
      expect(monoRubberBand(0, 800), 0);
      // Always less than the raw overshoot — that is the resistance.
      for (final overshoot in <double>[10, 100, 400, 5000]) {
        expect(monoRubberBand(overshoot, 800), lessThan(overshoot));
        expect(monoRubberBand(overshoot, 800), greaterThan(0));
        expect(monoRubberBand(overshoot, 800), lessThan(800));
      }
    });

    test('is symmetric about zero', () {
      expect(monoRubberBand(-120, 800), -monoRubberBand(120, 800));
    });

    test('resists harder the further you pull', () {
      final small = monoRubberBand(50, 800) / 50;
      final large = monoRubberBand(500, 800) / 500;
      expect(large, lessThan(small));
    });

    test('degenerate dimensions do not divide by zero', () {
      expect(monoRubberBand(100, 0), 0);
    });
  });

  group('monoNearest', () {
    test('picks the closest candidate', () {
      const detents = <double>[0.0, 0.5, 0.92];
      expect(monoNearest(detents, 0.1), 0.0);
      expect(monoNearest(detents, 0.4), 0.5);
      expect(monoNearest(detents, 0.8), 0.92);
    });
  });

  group('MonoSpringController', () {
    testWidgets('settles at its target', (tester) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);

      controller.animateTo(1, spring: motion.spatial);
      await tester.pumpAndSettle();

      expect(controller.value, closeTo(1, 0.001));
      expect(controller.isAnimating, isFalse);
    });

    testWidgets('a null spring jumps — this is how reduced motion works', (
      tester,
    ) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);

      controller.animateTo(1, spring: null);
      await tester.pump();

      expect(controller.value, 1);
      expect(controller.isAnimating, isFalse);
    });

    testWidgets('carries velocity across a stop and retarget', (tester) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);

      controller.animateTo(1, spring: motion.spatial);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));

      expect(controller.isAnimating, isTrue);
      final moving = controller.velocity;
      expect(moving, greaterThan(0), reason: 'should be travelling upward');

      // Grabbing mid-flight must not throw the motion away.
      controller.stop();
      expect(controller.isAnimating, isFalse);
      expect(
        controller.velocity,
        closeTo(moving, 0.001),
        reason: 'velocity is retained for the next retarget',
      );

      // Retarget backwards while still carrying upward velocity: a real spring
      // overshoots past the release point before turning around.
      final releasedAt = controller.value;
      controller.animateTo(0, spring: motion.spatial);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      expect(
        controller.value,
        greaterThan(releasedAt),
        reason: 'inherited velocity should carry it further before reversing',
      );

      await tester.pumpAndSettle();
      expect(controller.value, closeTo(0, 0.001));
    });

    testWidgets('an explicit velocity overrides the inherited one', (
      tester,
    ) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);

      controller.animateTo(1, withVelocity: 0, spring: motion.spatial);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 4));
      final gentle = controller.value;
      await tester.pumpAndSettle();

      controller.jumpTo(0);
      controller.animateTo(1, withVelocity: 8, spring: motion.spatial);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 4));
      expect(controller.value, greaterThan(gentle));

      await tester.pumpAndSettle();
    });

    testWidgets('jumpTo does not animate and clears retained velocity', (
      tester,
    ) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);

      controller.animateTo(1, spring: motion.spatial);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      controller.stop();
      expect(controller.velocity, isNot(0));

      controller.jumpTo(0.25);
      expect(controller.value, 0.25);
      expect(controller.velocity, 0);
      expect(controller.isAnimating, isFalse);
    });

    testWidgets('notifies listeners as it runs', (tester) async {
      final controller = MonoSpringController(vsync: const TestVSync());
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.animateTo(1, spring: motion.spatial);
      await tester.pumpAndSettle();

      expect(notifications, greaterThan(1));
    });
  });

  group('motion doctrine', () {
    test('springs are ordered snappiest to bounciest', () {
      // effect lands hardest, celebrate is the only under-damped one.
      expect(motion.effect.stiffness, greaterThan(motion.spatial.stiffness));
      expect(motion.celebrate.stiffness, lessThan(motion.spatial.stiffness));
    });

    test('only celebrate is under-damped', () {
      double ratio(SpringDescription s) =>
          s.damping / (2 * sqrt(s.mass * s.stiffness));
      // celebrate overshoots; the other two settle without one.
      expect(ratio(motion.celebrate), lessThan(1));
      expect(ratio(motion.spatial), closeTo(0.9, 0.001));
      expect(ratio(motion.effect), closeTo(1.0, 0.001));
    });
  });
}
