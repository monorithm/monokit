import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

void main() {
  group('heading semantics', () {
    testWidgets('MonoDialogHeader title is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(const MonoDialogHeader(title: Text('Settings'))),
      );
      expect(
        tester.getSemantics(find.text('Settings')),
        isSemantics(isHeader: true, label: 'Settings'),
      );
      handle.dispose();
    });

    testWidgets('MonoCardTitle is a heading', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(const MonoCardTitle(child: Text('Revenue'))),
      );
      expect(
        tester.getSemantics(find.text('Revenue')),
        isSemantics(isHeader: true, label: 'Revenue'),
      );
      handle.dispose();
    });

    testWidgets('MonoHeading wraps arbitrary content', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(monokitHost(const MonoHeading(Text('Team'))));
      expect(
        tester.getSemantics(find.text('Team')),
        isSemantics(isHeader: true),
      );
      handle.dispose();
    });
  });

  group('role semantics', () {
    testWidgets('tab triggers are in a mutually exclusive group', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoTabs(
            tabs: <MonoTab>[
              MonoTab(
                value: 'a',
                label: const Text('First'),
                semanticLabel: 'First tab',
                content: const Text('Panel A'),
              ),
              MonoTab(
                value: 'b',
                label: const Text('Second'),
                semanticLabel: 'Second tab',
                content: const Text('Panel B'),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('First tab')),
        isSemantics(isInMutuallyExclusiveGroup: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Second tab')),
        isSemantics(isInMutuallyExclusiveGroup: true, isSelected: false),
      );
      handle.dispose();
    });
  });

  group('focus ring tokens', () {
    test('MonokitFocus exposes defaults and copyWith', () {
      const focus = MonokitFocus();
      // The Atlas draws `outline: 2px solid var(--ring)` at `outline-offset:
      // 3px`, solid rather than a translucent band.
      expect(focus.ringWidth, 2);
      expect(focus.ringOffset, 3);
      expect(focus.ringAlpha, 1.0);
      expect(focus.copyWith(ringWidth: 4).ringWidth, 4);
      expect(focus.copyWith(ringWidth: 4).ringOffset, 3);
      expect(focus.copyWith(ringAlpha: 0.4).ringAlpha, 0.4);
    });

    test('MonokitThemeData threads the focus group through copyWith/==', () {
      final base = MonokitThemeData.light();
      final wide = base.copyWith(focus: const MonokitFocus(ringWidth: 4));
      expect(wide.focus.ringWidth, 4);
      expect(wide == base, isFalse);
      expect(base.copyWith() == base, isTrue);
    });

    testWidgets('MonoFocusRing reads ringWidth from the theme token', (
      tester,
    ) async {
      final theme = MonokitThemeData.light().copyWith(
        focus: const MonokitFocus(ringWidth: 5, ringOffset: 6),
      );
      await tester.pumpWidget(
        monokitHost(
          const MonoFocusRing(
            focused: true,
            child: SizedBox.square(dimension: 24),
          ),
          theme: theme,
        ),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border!.top.width, 5);
    });
  });

  group('label tokens', () {
    testWidgets('MonokitLabels override flows to the command palette', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final theme = MonokitThemeData.light().copyWith(
        labels: const MonokitLabels(commandPalette: 'Kommandopalette'),
      );
      await tester.pumpWidget(
        monokitHost(
          MonoCommandPalette(
            open: true,
            commands: <MonoCommand>[
              MonoCommand(id: 'new', label: const Text('New')),
            ],
          ),
          theme: theme,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.bySemanticsLabel('Kommandopalette'), findsOneWidget);
      handle.dispose();
    });

    test('MonokitLabels tabPanel builder and copyWith', () {
      const labels = MonokitLabels();
      expect(labels.tabPanel(3), 'Tab panel 3');
      expect(labels.copyWith(close: 'Schließen').close, 'Schließen');
      expect(labels.copyWith(close: 'Schließen').next, 'Next');
    });

    testWidgets('sheet trigger falls back to the openSheet label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final theme = MonokitThemeData.light().copyWith(
        labels: const MonokitLabels(openSheet: 'Blatt öffnen'),
      );
      await tester.pumpWidget(
        monokitHost(
          MonoSheet(
            trigger: const MonoSheetTrigger(child: Text('Open')),
            child: const SizedBox.shrink(),
          ),
          theme: theme,
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Blatt öffnen')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('an explicit semanticLabel still wins over the token', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          MonoSheet(
            trigger: const MonoSheetTrigger(
              semanticLabel: 'Custom open',
              child: Text('Open'),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Custom open')), findsOneWidget);
      handle.dispose();
    });
  });

  group('overlay focus restore', () {
    testWidgets('MonoOverlayFocusController restores the captured node', (
      tester,
    ) async {
      final probe = FocusNode(debugLabel: 'probe');
      final overlayNode = FocusNode(debugLabel: 'overlay');
      addTearDown(probe.dispose);
      addTearDown(overlayNode.dispose);

      await tester.pumpWidget(
        monokitHost(
          Column(
            children: <Widget>[
              Focus(
                focusNode: probe,
                child: const SizedBox.square(dimension: 8),
              ),
              Focus(
                focusNode: overlayNode,
                child: const SizedBox.square(dimension: 8),
              ),
            ],
          ),
        ),
      );
      probe.requestFocus();
      await tester.pump();
      expect(probe.hasFocus, isTrue);

      final controller = MonoOverlayFocusController();
      controller.captureForOpen();
      controller.requestRestoreOnClose();
      // Simulate focus moving into an overlay while it is open.
      overlayNode.requestFocus();
      await tester.pump();
      expect(probe.hasFocus, isFalse);

      controller.restoreIfRequested(mounted: true);
      await tester.pump();
      expect(probe.hasFocus, isTrue, reason: 'focus returns to captured node');
    });

    test('falls back to the trigger when the captured node is gone', () {
      final trigger = FocusNode(debugLabel: 'trigger');
      addTearDown(trigger.dispose);
      final controller = MonoOverlayFocusController(
        triggerFocusNode: () => trigger,
      );
      // No captureForOpen(): captured node is null, so the fallback is used.
      controller.requestRestoreOnClose();
      controller.restoreIfRequested(mounted: true);
      // Without a live tree the request is a no-op focus-wise, but it must not
      // throw and must consume the pending restore.
      expect(controller.willRestoreOnClose, isFalse);
    });

    test('does not restore when not requested', () {
      final controller = MonoOverlayFocusController();
      controller.captureForOpen();
      controller.restoreIfRequested(mounted: true);
      expect(controller.willRestoreOnClose, isFalse);
    });
  });
}
