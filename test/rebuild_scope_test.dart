import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

void main() {
  testWidgets('MonoPressable delivers hover state to its scoped leaf', (
    tester,
  ) async {
    Set<MonoState> lastStates = <MonoState>{};
    var leafBuilds = 0;
    await tester.pumpWidget(
      monokitHost(
        MonoPressable(
          onPressed: () {},
          child: (BuildContext context, Set<MonoState> states) {
            leafBuilds++;
            lastStates = states;
            return const SizedBox(width: 120, height: 44);
          },
        ),
      ),
    );
    final int buildsBeforePress = leafBuilds;
    expect(lastStates.contains(MonoState.pressed), isFalse);

    // Press updates MonoState.pressed via the states controller, which the
    // scoped ListenableBuilder observes — rebuilding only this leaf.
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(SizedBox)),
    );
    await tester.pump();
    expect(lastStates.contains(MonoState.pressed), isTrue);
    expect(leafBuilds, greaterThan(buildsBeforePress));

    await gesture.up();
    await tester.pump();
    expect(lastStates.contains(MonoState.pressed), isFalse);
  });

  testWidgets('MonoButton still reacts to press after rebuild scoping', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      monokitHost(MonoButton(onPressed: () => taps++, child: const Text('Go'))),
    );
    await tester.tap(find.text('Go'));
    await tester.pump();
    expect(taps, 1);
    // A press gesture mid-way still updates without throwing.
    final TestGesture g = await tester.startGesture(
      tester.getCenter(find.text('Go')),
    );
    await tester.pump();
    await g.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
