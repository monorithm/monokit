import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

class _ControlledOverlayHarness extends StatefulWidget {
  const _ControlledOverlayHarness({
    super.key,
    required this.initialContent,
    required this.overlayBuilder,
  });

  final String initialContent;
  final Widget Function(bool open, String content) overlayBuilder;

  @override
  State<_ControlledOverlayHarness> createState() =>
      _ControlledOverlayHarnessState();
}

class _ControlledOverlayHarnessState extends State<_ControlledOverlayHarness> {
  bool _open = false;
  late String _content;

  @override
  void initState() {
    super.initState();
    _content = widget.initialContent;
  }

  void setOpen(bool value) {
    setState(() => _open = value);
  }

  void updateContent(String value) {
    setState(() => _content = value);
  }

  @override
  Widget build(BuildContext context) => widget.overlayBuilder(_open, _content);
}

void main() {
  final theme = MonokitThemeData.light();

  Future<void> verifyControlledUpdate(
    WidgetTester tester, {
    required String initialContent,
    required String updatedContent,
    required Widget Function(bool open, String content) overlayBuilder,
  }) async {
    final key = GlobalKey<_ControlledOverlayHarnessState>();
    await tester.pumpWidget(
      MonokitApp(
        theme: theme,
        home: Center(
          child: _ControlledOverlayHarness(
            key: key,
            initialContent: initialContent,
            overlayBuilder: overlayBuilder,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    key.currentState!.setOpen(true);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text(initialContent), findsOneWidget);

    key.currentState!.updateContent(updatedContent);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text(updatedContent), findsOneWidget);

    key.currentState!.setOpen(false);
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(find.text(updatedContent), findsNothing);
  }

  testWidgets('popover synchronizes controlled updates after the frame', (
    tester,
  ) async {
    await verifyControlledUpdate(
      tester,
      initialContent: 'Initial popover overlay',
      updatedContent: 'Updated popover overlay',
      overlayBuilder: (open, content) => MonoPopover(
        open: open,
        trigger: const Text('Popover trigger'),
        child: MonoPopoverContent(child: Text(content)),
      ),
    );
  });

  testWidgets('tooltip synchronizes controlled updates after the frame', (
    tester,
  ) async {
    await verifyControlledUpdate(
      tester,
      initialContent: 'Initial tooltip overlay',
      updatedContent: 'Updated tooltip overlay',
      overlayBuilder: (open, content) => MonoTooltip(
        open: open,
        message: 'Tooltip message',
        content: Text(content),
        child: const Text('Tooltip trigger'),
      ),
    );
  });

  testWidgets('hover card synchronizes controlled updates after the frame', (
    tester,
  ) async {
    await verifyControlledUpdate(
      tester,
      initialContent: 'Initial hover card overlay',
      updatedContent: 'Updated hover card overlay',
      overlayBuilder: (open, content) => MonoHoverCard(
        open: open,
        card: MonoHoverCardContent(child: Text(content)),
        child: const Text('Hover card trigger'),
      ),
    );
  });

  testWidgets('context menu synchronizes controlled updates after the frame', (
    tester,
  ) async {
    await verifyControlledUpdate(
      tester,
      initialContent: 'Initial context menu overlay',
      updatedContent: 'Updated context menu overlay',
      overlayBuilder: (open, content) => MonoContextMenu(
        open: open,
        menu: MonoContextMenuContent(child: Text(content)),
        child: const Text('Context menu trigger'),
      ),
    );
  });
}
