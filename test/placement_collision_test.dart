import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

/// The collision resolver behind anchored-overlay flipping.
void main() {
  const Size viewport = Size(400, 800);

  test('flips a bottom placement up when it would overflow below', () {
    const Rect nearBottom = Rect.fromLTWH(0, 720, 100, 40);
    expect(
      MonoPlacement.bottomStart.resolveWithin(
        nearBottom,
        viewport,
        estimate: 240,
      ),
      MonoPlacement.topStart,
    );
  });

  test('keeps a bottom placement when there is room below', () {
    const Rect nearTop = Rect.fromLTWH(0, 40, 100, 40);
    expect(
      MonoPlacement.bottomEnd.resolveWithin(nearTop, viewport, estimate: 240),
      MonoPlacement.bottomEnd,
    );
  });

  test('keeps the preferred side when neither side has room', () {
    const Rect middle = Rect.fromLTWH(0, 380, 100, 40);
    expect(
      MonoPlacement.bottomStart.resolveWithin(middle, viewport, estimate: 500),
      MonoPlacement.bottomStart,
    );
  });

  test('flips a right placement to the left near the right edge', () {
    const Rect nearRight = Rect.fromLTWH(360, 380, 40, 40);
    expect(
      MonoPlacement.rightStart.resolveWithin(
        nearRight,
        viewport,
        estimate: 240,
      ),
      MonoPlacement.leftStart,
    );
  });

  test('opposite mirrors across the trigger, preserving alignment', () {
    expect(MonoPlacement.bottomEnd.opposite, MonoPlacement.topEnd);
    expect(MonoPlacement.leftStart.opposite, MonoPlacement.rightStart);
  });
}
