import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child, {EdgeInsets viewPadding = EdgeInsets.zero}) {
  final data = MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: MediaQueryData(
        size: const Size(800, 600),
        viewPadding: viewPadding,
      ),
      child: MonokitTheme(
        data: data,
        child: DefaultTextStyle(
          style: data.typography.body.copyWith(color: data.colors.foreground),
          child: Center(child: child),
        ),
      ),
    ),
  );
}

const _items = <MonoBottomNavItem>[
  MonoBottomNavItem(icon: MonoIcons.add, label: 'Create'),
  MonoBottomNavItem(icon: MonoIcons.play, label: 'Play'),
  MonoBottomNavItem(icon: MonoIcons.user, label: 'Profile'),
];

void main() {
  testWidgets('renders icon-only destinations and reports taps by index', (
    tester,
  ) async {
    final taps = <int>[];
    await tester.pumpWidget(
      _host(
        MonoBottomNav(items: _items, selectedIndex: 1, onSelected: taps.add),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(MonoBottomNav),
        matching: find.byType(MonoIcon),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byType(MonoBottomNav),
        matching: find.byType(Text),
      ),
      findsNothing,
    );

    await tester.tap(find.byType(MonoPressable).at(2));
    // Re-tapping the selected destination still fires — hosts use it for
    // "re-tap resets the branch stack".
    await tester.tap(find.byType(MonoPressable).at(1));
    expect(taps, <int>[2, 1]);
  });

  testWidgets('announces label, button and selected state per destination', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(MonoBottomNav(items: _items, selectedIndex: 1, onSelected: (_) {})),
    );

    expect(find.bySemanticsLabel('Primary navigation'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Play')),
      isSemantics(
        label: 'Play',
        isButton: true,
        isSelected: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Profile')),
      isSemantics(isButton: true, isSelected: false),
    );
    handle.dispose();
  });

  testWidgets('destinations meet the minimum touch target', (tester) async {
    await tester.pumpWidget(
      _host(MonoBottomNav(items: _items, selectedIndex: 0, onSelected: (_) {})),
    );

    for (var index = 0; index < _items.length; index++) {
      expect(
        tester.getSize(find.byType(MonoPressable).at(index)).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  testWidgets('pads itself clear of the bottom system inset', (tester) async {
    await tester.pumpWidget(
      _host(MonoBottomNav(items: _items, selectedIndex: 0, onSelected: (_) {})),
    );
    final flushHeight = tester.getSize(find.byType(MonoBottomNav)).height;

    await tester.pumpWidget(
      _host(
        MonoBottomNav(items: _items, selectedIndex: 0, onSelected: (_) {}),
        viewPadding: const EdgeInsets.only(bottom: 34),
      ),
    );
    final insetHeight = tester.getSize(find.byType(MonoBottomNav)).height;

    expect(insetHeight - flushHeight, 34);
  });

  testWidgets('a disabled destination is inert', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(
      _host(
        MonoBottomNav(
          items: const <MonoBottomNavItem>[
            MonoBottomNavItem(icon: MonoIcons.add, label: 'Create'),
            MonoBottomNavItem(
              icon: MonoIcons.user,
              label: 'Profile',
              enabled: false,
            ),
          ],
          selectedIndex: 0,
          onSelected: taps.add,
        ),
      ),
    );

    await tester.tap(find.byType(MonoPressable).at(1));
    expect(taps, isEmpty);
  });
}
