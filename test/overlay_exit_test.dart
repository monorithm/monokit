import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

/// Anchored overlays must play an *exit* animation before their entry is
/// removed — not snap out. Proof: after a close is requested, the content is
/// still mounted mid-transition, and only gone once the animation settles.
void main() {
  Future<void> expectAnimatedExit(
    WidgetTester tester, {
    required String content,
    required Widget Function(bool open) build,
  }) async {
    var open = false;
    late StateSetter setOuter;
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return build(open);
            },
          ),
        ),
      ),
    );

    setOuter(() => open = true);
    await tester.pumpAndSettle();
    expect(find.text(content), findsOneWidget);

    // Request close, then advance less than the transition duration.
    setOuter(() => open = false);
    await tester.pump(); // post-frame: begin close (visible = false)
    await tester.pump(); // overlay rebuilds and starts reversing
    await tester.pump(const Duration(milliseconds: 40));
    expect(
      find.text(content),
      findsOneWidget,
      reason: 'content should still be mounted while exiting',
    );

    await tester.pumpAndSettle();
    expect(find.text(content), findsNothing);
  }

  testWidgets('popover animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'popover body',
      build: (open) => MonoPopover(
        open: open,
        trigger: const Text('trigger'),
        child: const MonoPopoverContent(child: Text('popover body')),
      ),
    );
  });

  testWidgets('hover card animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'hover body',
      build: (open) => MonoHoverCard(
        open: open,
        card: const MonoHoverCardContent(child: Text('hover body')),
        child: const Text('trigger'),
      ),
    );
  });

  testWidgets('context menu animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'menu body',
      build: (open) => MonoContextMenu(
        open: open,
        menu: const MonoContextMenuContent(child: Text('menu body')),
        child: const Text('trigger'),
      ),
    );
  });

  testWidgets('tooltip animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'tip body',
      build: (open) => MonoTooltip(
        open: open,
        message: 'tip',
        content: const Text('tip body'),
        child: const Text('trigger'),
      ),
    );
  });

  testWidgets('dialog animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'dialog body',
      build: (open) => MonoDialog(
        open: open,
        trigger: const Text('trigger'),
        child: const MonoDialogContent(child: Text('dialog body')),
      ),
    );
  });

  testWidgets('sheet animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'sheet body',
      build: (open) => MonoSheet(
        open: open,
        trigger: const Text('trigger'),
        child: const MonoSheetContent(child: Text('sheet body')),
      ),
    );
  });

  testWidgets('drawer animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'drawer body',
      build: (open) => MonoDrawer(
        open: open,
        trigger: const Text('trigger'),
        child: const Text('drawer body'),
      ),
    );
  });

  testWidgets('dropdown menu animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'menu item',
      build: (open) => MonoDropdownMenu<String>(
        open: open,
        trigger: const Text('trigger'),
        items: <MonoDropdownMenuItem<String>>[
          MonoDropdownMenuItem.text(value: 'x', label: 'menu item'),
        ],
      ),
    );
  });

  testWidgets('command palette animates out', (tester) async {
    await expectAnimatedExit(
      tester,
      content: 'palette item',
      build: (open) => MonoCommandPalette(
        open: open,
        commands: <MonoCommand>[
          MonoCommand.text(id: 'x', label: 'palette item'),
        ],
      ),
    );
  });
}
