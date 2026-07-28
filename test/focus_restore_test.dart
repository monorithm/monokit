import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

import '_support/host.dart';

/// Focus *restoration* when an overlay closes.
///
/// Returning focus to whoever held it is a keyboard-navigation contract, and
/// every anchored overlay honours it. The wrinkle is touch: restoring focus to
/// a text field also re-opens the software keyboard, so a phone user who opened
/// a sheet from a form got the keyboard thrown back in their face on every
/// close. Desktop restores fully; touch restores to the trigger instead.
void main() {
  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  /// A controlled sheet driven by [open] rather than by tapping a trigger.
  ///
  /// Tapping a trigger is itself a tap *outside* the field, so it would drop
  /// focus before the overlay ever captured it — that is the dismissal contract
  /// working, but it would leave these tests measuring the wrong thing. Driving
  /// `open` directly isolates what happens on close.
  Widget sheetPage(FocusNode node, {required bool open}) {
    return monokitHost(
      MonoScreen(
        body: Column(
          children: <Widget>[
            MonoInput(focusNode: node, placeholder: 'Type here'),
            MonoSheet(
              open: open,
              child: const MonoSheetContent(child: Text('Sheet body')),
            ),
          ],
        ),
      ),
    );
  }

  group('a closing overlay does not re-raise the keyboard', () {
    for (final TargetPlatform platform in <TargetPlatform>[
      TargetPlatform.iOS,
      TargetPlatform.android,
    ]) {
      testWidgets('$platform: sheet close leaves the field unfocused', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          final FocusNode node = FocusNode(debugLabel: 'field');
          addTearDown(node.dispose);
          await tester.pumpWidget(sheetPage(node, open: false));
          node.requestFocus();
          await tester.pumpAndSettle();
          expect(node.hasFocus, isTrue);

          await tester.pumpWidget(sheetPage(node, open: true));
          await tester.pumpAndSettle();
          expect(
            node.hasFocus,
            isFalse,
            reason: 'the modal focus trap takes focus, dropping the keyboard',
          );

          await tester.pumpWidget(sheetPage(node, open: false));
          await tester.pumpAndSettle();
          expect(
            node.hasFocus,
            isFalse,
            reason: 'restoring into the field would pop the keyboard back up',
          );
        });
      });
    }

    testWidgets('desktop still restores focus into the field', (tester) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final FocusNode node = FocusNode(debugLabel: 'field');
        addTearDown(node.dispose);
        await tester.pumpWidget(sheetPage(node, open: false));
        node.requestFocus();
        await tester.pumpAndSettle();

        await tester.pumpWidget(sheetPage(node, open: true));
        await tester.pumpAndSettle();
        expect(node.hasFocus, isFalse);

        await tester.pumpWidget(sheetPage(node, open: false));
        await tester.pumpAndSettle();
        expect(
          node.hasFocus,
          isTrue,
          reason: 'there is a real keyboard here; the tab order matters',
        );
      });
    });

    testWidgets('touch still restores focus to a non-text control', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        final FocusNode node = FocusNode(debugLabel: 'button');
        addTearDown(node.dispose);
        await tester.pumpWidget(
          monokitHost(
            MonoScreen(
              body: Column(
                children: <Widget>[
                  MonoButton(
                    focusNode: node,
                    onPressed: () {},
                    child: const Text('Plain button'),
                  ),
                  MonoSheet(
                    trigger: const Text('Open sheet'),
                    child: const MonoSheetContent(child: Text('Sheet body')),
                  ),
                ],
              ),
            ),
          ),
        );
        node.requestFocus();
        await tester.pumpAndSettle();
        expect(node.hasFocus, isTrue);

        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(400, 40));
        await tester.pumpAndSettle();
        expect(
          node.hasFocus,
          isTrue,
          reason: 'no keyboard is at stake, so the normal contract applies',
        );
      });
    });
  });

  group('modals that restored nothing now restore', () {
    testWidgets('MonoDialog returns focus to the opener', (tester) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final FocusNode node = FocusNode(debugLabel: 'opener');
        addTearDown(node.dispose);
        await tester.pumpWidget(
          monokitHost(
            MonoScreen(
              body: Column(
                children: <Widget>[
                  MonoButton(
                    focusNode: node,
                    onPressed: () {},
                    child: const Text('Somewhere'),
                  ),
                  const MonoDialog(
                    trigger: Text('Open dialog'),
                    child: Text('Dialog body'),
                  ),
                ],
              ),
            ),
          ),
        );
        node.requestFocus();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open dialog'));
        await tester.pumpAndSettle();
        expect(node.hasFocus, isFalse, reason: 'the dialog traps focus');

        await tester.tapAt(const Offset(400, 20)); // scrim
        await tester.pumpAndSettle();
        expect(
          node.hasFocus,
          isTrue,
          reason: 'dialog used to trap focus and then abandon it on close',
        );
      });
    });

    testWidgets('MonoCommandPalette returns focus to the opener', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final FocusNode node = FocusNode(debugLabel: 'opener');
        addTearDown(node.dispose);
        await tester.pumpWidget(
          monokitHost(
            MonoScreen(
              body: Column(
                children: <Widget>[
                  MonoButton(
                    focusNode: node,
                    onPressed: () {},
                    child: const Text('Somewhere'),
                  ),
                  MonoCommandPalette(
                    trigger: const Text('Open palette'),
                    commands: <MonoCommand>[
                      MonoCommand(
                        id: 'a',
                        label: const Text('Do a thing'),
                        onSelected: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        node.requestFocus();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open palette'));
        await tester.pumpAndSettle();
        expect(node.hasFocus, isFalse);

        await tester.tapAt(const Offset(400, 20));
        await tester.pumpAndSettle();
        expect(node.hasFocus, isTrue);
      });
    });
  });

  group('MonoOverlayFocusController', () {
    testWidgets('restoreTextInputFocus opts back into the old behaviour', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        final FocusNode field = FocusNode(debugLabel: 'field');
        addTearDown(field.dispose);
        await tester.pumpWidget(
          monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: field))),
        );
        field.requestFocus();
        await tester.pumpAndSettle();

        final controller = MonoOverlayFocusController(
          restoreTextInputFocus: true,
        );
        controller.captureForOpen();
        field.unfocus();
        await tester.pumpAndSettle();
        expect(field.hasFocus, isFalse);

        controller.requestRestoreOnClose();
        controller.restoreIfRequested(mounted: true);
        await tester.pumpAndSettle();
        expect(field.hasFocus, isTrue);
      });
    });

    testWidgets('a cancelled restore moves nothing', (tester) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final FocusNode field = FocusNode(debugLabel: 'field');
        addTearDown(field.dispose);
        await tester.pumpWidget(
          monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: field))),
        );
        field.requestFocus();
        await tester.pumpAndSettle();

        final controller = MonoOverlayFocusController();
        controller.captureForOpen();
        field.unfocus();
        await tester.pumpAndSettle();

        controller.requestRestoreOnClose();
        controller.cancelRestore();
        controller.restoreIfRequested(mounted: true);
        await tester.pumpAndSettle();
        expect(field.hasFocus, isFalse);
      });
    });
  });
}
