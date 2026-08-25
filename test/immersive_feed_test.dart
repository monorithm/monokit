import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

Widget _host(Widget child) {
  final data = MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(390, 700)),
      child: MonokitTheme(
        data: data,
        child: DefaultTextStyle(
          style: data.typography.body.copyWith(color: data.colors.foreground),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('the initial item counts as seen', (tester) async {
    final seen = <int>[];
    await tester.pumpWidget(
      _host(
        MonoImmersiveFeed(
          itemCount: 3,
          onExposure: seen.add,
          itemBuilder: (context, index, phase) => Text('drop $index'),
        ),
      ),
    );
    await tester.pump();
    expect(seen, <int>[0]);
  });

  testWidgets('a settled swipe emits exactly one exposure and re-phases '
      'items', (tester) async {
    final seen = <int>[];
    final phases = <int, MonoFeedItemPhase>{};
    await tester.pumpWidget(
      _host(
        MonoImmersiveFeed(
          itemCount: 3,
          onExposure: seen.add,
          itemBuilder: (context, index, phase) {
            phases[index] = phase;
            return Text('drop $index');
          },
        ),
      ),
    );
    await tester.pump();
    expect(phases[0], MonoFeedItemPhase.active);
    expect(phases[1], MonoFeedItemPhase.near);

    await tester.fling(find.byType(PageView), const Offset(0, -600), 1200);
    await tester.pumpAndSettle();

    expect(seen, <int>[0, 1]);
    expect(phases[1], MonoFeedItemPhase.active);
    expect(phases[0], MonoFeedItemPhase.near);
  });

  testWidgets('data-saver switches neighbour keep-alive off', (tester) async {
    await tester.pumpWidget(
      _host(
        MonoImmersiveFeed(
          itemCount: 3,
          itemBuilder: (context, index, phase) => Text('drop $index'),
        ),
      ),
    );
    expect(
      tester.widget<PageView>(find.byType(PageView)).allowImplicitScrolling,
      isTrue,
    );

    await tester.pumpWidget(
      _host(
        MonoImmersiveFeed(
          itemCount: 3,
          dataSaver: true,
          itemBuilder: (context, index, phase) => Text('drop $index'),
        ),
      ),
    );
    expect(
      tester.widget<PageView>(find.byType(PageView)).allowImplicitScrolling,
      isFalse,
    );
  });

  testWidgets('position survives restoration', (tester) async {
    final seen = <int>[];
    await tester.pumpWidget(
      RootRestorationScope(
        restorationId: 'root',
        child: _host(
          MonoImmersiveFeed(
            itemCount: 3,
            restorationId: 'feed',
            onExposure: seen.add,
            itemBuilder: (context, index, phase) => Text('drop $index'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.fling(find.byType(PageView), const Offset(0, -600), 1200);
    await tester.pumpAndSettle();
    expect(seen, <int>[0, 1]);

    await tester.restartAndRestore();
    expect(find.text('drop 1'), findsOneWidget);
  });
}
