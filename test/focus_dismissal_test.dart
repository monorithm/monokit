import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

import '_support/host.dart';

/// Focus *dismissal* — the half of focus handling that is behavior rather than
/// paint. Monokit had the ring tokens, the traversal policy and the focus trap,
/// but nothing that ever dropped text-input focus in response to a gesture, so
/// on a phone the software keyboard could only be closed with its own Done key.
///
/// The matrix below is the contract. Flutter's own default deliberately ignores
/// a *touch* tap outside a field on native Android/iOS, so every mobile row
/// here is Monokit policy, not framework behavior — which is exactly why it
/// needs pinning down.
void main() {
  /// Runs [body] with [platform] reported to the framework, resetting the
  /// override inside the test so the post-test invariant check stays clean.
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

  const List<TargetPlatform> touchPlatforms = <TargetPlatform>[
    TargetPlatform.iOS,
    TargetPlatform.android,
  ];

  group('tap away dismisses the keyboard', () {
    /// A page with a field, a button and a large blank region below both.
    Widget page(
      FocusNode node, {
      bool? dismiss,
      bool scroll = false,
      VoidCallback? onButton,
    }) {
      return monokitHost(
        MonoScreen(
          scrollBody: scroll,
          body: Column(
            children: <Widget>[
              MonoInput(
                focusNode: node,
                placeholder: 'Type here',
                padding: const EdgeInsets.all(24),
                dismissKeyboardOnTapOutside: dismiss,
              ),
              MonoButton(
                onPressed: onButton ?? () {},
                child: const Text('Elsewhere'),
              ),
              if (scroll)
                const SizedBox(height: 2000, child: Text('blank'))
              else
                const Expanded(child: SizedBox.expand(child: Text('blank'))),
            ],
          ),
        ),
      );
    }

    Future<FocusNode> pumpFocused(
      WidgetTester tester,
      Widget Function(FocusNode node) build,
    ) async {
      final FocusNode node = FocusNode(debugLabel: 'field');
      addTearDown(node.dispose);
      await tester.pumpWidget(build(node));
      node.requestFocus();
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue, reason: 'precondition: field is focused');
      return node;
    }

    for (final TargetPlatform platform in touchPlatforms) {
      testWidgets('$platform: tapping blank page area unfocuses', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          final node = await pumpFocused(tester, page);
          await tester.tapAt(tester.getRect(find.text('blank')).center);
          await tester.pumpAndSettle();
          expect(node.hasFocus, isFalse);
        });
      });

      testWidgets('$platform: tapping a button unfocuses', (tester) async {
        await onPlatform(platform, () async {
          var pressed = 0;
          final node = await pumpFocused(
            tester,
            (n) => page(n, onButton: () => pressed++),
          );
          await tester.tap(find.text('Elsewhere'));
          await tester.pumpAndSettle();
          expect(node.hasFocus, isFalse);
          // Dismissal must not swallow the tap it rode in on.
          expect(pressed, 1);
        });
      });

      testWidgets('$platform: dragging a scrollable unfocuses', (tester) async {
        await onPlatform(platform, () async {
          final node = await pumpFocused(tester, (n) => page(n, scroll: true));
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -200),
          );
          await tester.pumpAndSettle();
          expect(node.hasFocus, isFalse);
        });
      });

      testWidgets('$platform: opting out restores the framework default', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          final node = await pumpFocused(
            tester,
            (n) => page(n, dismiss: false),
          );
          await tester.tapAt(tester.getRect(find.text('blank')).center);
          await tester.pumpAndSettle();
          expect(
            node.hasFocus,
            isTrue,
            reason: 'framework ignores touch taps outside on native mobile',
          );
          // A mouse still unfocuses — that part is the framework's, not ours.
          await tester.tapAt(
            tester.getRect(find.text('blank')).center,
            kind: PointerDeviceKind.mouse,
          );
          await tester.pumpAndSettle();
          expect(node.hasFocus, isFalse);
        });
      });

      testWidgets('$platform: the theme token drives the default', (
        tester,
      ) async {
        await onPlatform(platform, () async {
          final FocusNode node = FocusNode();
          addTearDown(node.dispose);
          await tester.pumpWidget(
            monokitHost(
              SizedBox(
                width: 300,
                child: Column(
                  children: <Widget>[
                    MonoInput(focusNode: node, placeholder: 'Type'),
                    const SizedBox(height: 200, child: Text('blank')),
                  ],
                ),
              ),
              theme: MonokitThemeData.light().copyWith(
                focus: const MonokitFocus(dismissKeyboardOnTapOutside: false),
              ),
            ),
          );
          node.requestFocus();
          await tester.pumpAndSettle();
          await tester.tapAt(tester.getRect(find.text('blank')).center);
          await tester.pumpAndSettle();
          expect(node.hasFocus, isTrue);
        });
      });
    }

    testWidgets('moving between two fields does not fire tap-outside', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        final FocusNode a = FocusNode(debugLabel: 'a');
        final FocusNode b = FocusNode(debugLabel: 'b');
        addTearDown(a.dispose);
        addTearDown(b.dispose);
        await tester.pumpWidget(
          monokitHost(
            SizedBox(
              width: 300,
              child: Column(
                children: <Widget>[
                  MonoInput(focusNode: a, placeholder: 'First'),
                  MonoInput(focusNode: b, placeholder: 'Second'),
                ],
              ),
            ),
          ),
        );
        a.requestFocus();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Second'));
        await tester.pumpAndSettle();
        // The tap region groups every text field, so this is a handover, not a
        // dismissal — the keyboard must stay up across it.
        expect(b.hasFocus, isTrue);
        expect(a.hasFocus, isFalse);
      });
    });

    testWidgets('desktop still unfocuses on a tap away', (tester) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final node = await pumpFocused(tester, page);
        await tester.tapAt(tester.getRect(find.text('blank')).center);
        await tester.pumpAndSettle();
        expect(node.hasFocus, isFalse);
      });
    });
  });

  group('the field owns its whole decorated box', () {
    testWidgets('tapping the padding does not drop and regain focus', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.macOS, () async {
        final FocusNode node = FocusNode();
        addTearDown(node.dispose);
        await tester.pumpWidget(
          monokitHost(
            SizedBox(
              width: 300,
              child: MonoInput(
                focusNode: node,
                placeholder: 'Type here',
                padding: const EdgeInsets.all(24),
              ),
            ),
          ),
        );
        node.requestFocus();
        await tester.pumpAndSettle();

        var lostFocus = false;
        void watch() {
          if (!node.hasFocus) lostFocus = true;
        }

        node.addListener(watch);
        final Rect box = tester.getRect(find.byType(MonoInput));
        // Inside the field's border, outside the EditableText's own box.
        await tester.tapAt(Offset(box.left + 6, box.center.dy));
        await tester.pumpAndSettle();
        node.removeListener(watch);

        expect(node.hasFocus, isTrue);
        expect(
          lostFocus,
          isFalse,
          reason: 'padding is part of the field, not outside it',
        );
      });
    });

    testWidgets('MonoInput is wrapped in a TextFieldTapRegion', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(width: 300, child: MonoInput(placeholder: 'Email')),
        ),
      );
      expect(
        find.ancestor(
          of: find.byType(MonoInput),
          matching: find.byType(TextFieldTapRegion),
        ),
        findsNothing,
        reason: 'the region belongs inside MonoInput, not around it',
      );
      expect(
        find.descendant(
          of: find.byType(MonoInput),
          matching: find.byType(TextFieldTapRegion),
        ),
        findsWidgets,
      );
    });
  });

  group('screen-reader activation', () {
    testWidgets('MonoInput exposes a tap action', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            child: MonoInput(focusNode: node, placeholder: 'Email'),
          ),
        ),
      );

      // Located by label, not by widget type: MonoInput's outermost render
      // object is now its TextFieldTapRegion, so walking up from the widget
      // lands on a bare ancestor rather than the field's own node.
      final SemanticsNode semantics = find.semantics
          .byLabel(RegExp('Email'))
          .evaluate()
          .single;
      expect(
        semantics.getSemanticsData().flagsCollection.isTextField,
        isTrue,
        reason: 'sanity: this is the field node',
      );
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
        reason:
            'the selection gesture detector excludes itself from semantics, '
            'so without an explicit onTap the field has no action at all',
      );

      // And the action actually puts the caret in the field.
      semantics.owner!.performAction(semantics.id, SemanticsAction.tap);
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
      handle.dispose();
    });

    testWidgets('a read-only field advertises no tap action', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 300,
            child: MonoInput(placeholder: 'Email', readOnly: true),
          ),
        ),
      );
      expect(
        find.semantics
            .byLabel(RegExp('Email'))
            .evaluate()
            .single
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );
      handle.dispose();
    });
  });

  group('MonoFieldLabel association', () {
    testWidgets('tapping an associated label focuses the field', (
      tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            child: MonoField(
              label: const Text('Email address'),
              focusNode: node,
              child: MonoInput(focusNode: node, placeholder: 'you@example.com'),
            ),
          ),
        ),
      );

      expect(node.hasFocus, isFalse);
      await tester.tap(find.text('Email address'));
      await tester.pumpAndSettle();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('an unassociated label stays presentation-only', (
      tester,
    ) async {
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            child: MonoField(
              label: const Text('Email address'),
              child: MonoInput(focusNode: node, placeholder: 'you@example.com'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Email address'));
      await tester.pumpAndSettle();
      expect(node.hasFocus, isFalse);
    });

    testWidgets('an associated label carries a semantics tap action', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final FocusNode node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            child: MonoFieldLabel(
              focusNode: node,
              child: const Text('Email address'),
            ),
          ),
        ),
      );
      expect(
        tester
            .getSemantics(find.text('Email address'))
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      handle.dispose();
    });
  });

  group('search panels keep their own query field', () {
    testWidgets('MonoCombobox: tapping inside the panel is not tapping away', (
      tester,
    ) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(
          monokitHost(
            SizedBox(
              width: 320,
              child: MonoCombobox<String>(
                defaultOpen: true,
                options: <MonoComboboxOption<String>>[
                  MonoComboboxOption<String>.text(value: 'a', label: 'Alpha'),
                  MonoComboboxOption<String>.text(value: 'b', label: 'Bravo'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final Finder query = find.byType(EditableText);
        expect(query, findsOneWidget, reason: 'the panel search field');
        final EditableTextState state = tester.state(query);
        state.widget.focusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(state.widget.focusNode.hasFocus, isTrue, reason: 'precondition');

        // Panel chrome: inside the surface, outside the EditableText's own box.
        // Tapping an option would close the overlay, so the padding around the
        // search row is the observable "inside the panel, not on the field"
        // spot. The panel-wide region is asserted structurally below.
        final Rect field = tester.getRect(query);
        await tester.tapAt(Offset(field.left - 6, field.center.dy));
        await tester.pumpAndSettle();

        expect(
          state.widget.focusNode.hasFocus,
          isTrue,
          reason: 'panel chrome belongs to the query field tap region',
        );
        expect(find.text('Alpha'), findsOneWidget, reason: 'panel stayed open');

        // The region wraps the whole surface, so the list and divider are in it
        // too — not just the search row this tap could reach.
        expect(
          find.descendant(
            of: find.byType(TextFieldTapRegion).first,
            matching: find.text('Alpha'),
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets(
      'MonoCommandPalette: tapping inside the panel keeps the query',
      (tester) async {
        await onPlatform(TargetPlatform.iOS, () async {
          await tester.pumpWidget(
            monokitHost(
              MonoCommandPalette(
                defaultOpen: true,
                commands: <MonoCommand>[
                  MonoCommand(
                    id: 'a',
                    label: const Text('Do a thing'),
                    onSelected: () {},
                  ),
                ],
              ),
            ),
          );
          await tester.pumpAndSettle();

          final EditableTextState state = tester.state(
            find.byType(EditableText),
          );
          state.widget.focusNode.requestFocus();
          await tester.pumpAndSettle();
          expect(
            state.widget.focusNode.hasFocus,
            isTrue,
            reason: 'precondition',
          );

          final Rect field = tester.getRect(find.byType(EditableText));
          await tester.tapAt(Offset(field.left - 6, field.center.dy));
          await tester.pumpAndSettle();

          expect(
            state.widget.focusNode.hasFocus,
            isTrue,
            reason: 'panel chrome belongs to the query field tap region',
          );
          expect(
            find.descendant(
              of: find.byType(TextFieldTapRegion).first,
              matching: find.text('Do a thing'),
            ),
            findsOneWidget,
            reason: 'the region wraps the command list too',
          );
        });
      },
    );
  });

  group('one-time code', () {
    testWidgets('hopping between cells keeps the keyboard up', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(
          monokitHost(const MonoInputOtp(length: 4, autofocus: true)),
        );
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus,
          isNot(isA<FocusScopeNode>()),
        );

        final Rect third = tester.getRect(find.byType(EditableText).at(2));
        await tester.tapAt(third.center);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus,
          isNot(isA<FocusScopeNode>()),
          reason: 'every cell shares one tap region group',
        );
      });
    });

    testWidgets('tapping outside the code unfocuses', (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await tester.pumpWidget(
          monokitHost(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                MonoInputOtp(length: 4, autofocus: true),
                SizedBox(height: 200, child: Text('blank')),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus,
          isNot(isA<FocusScopeNode>()),
        );

        await tester.tapAt(tester.getRect(find.text('blank')).center);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus,
          isA<FocusScopeNode>(),
          reason: 'no cell should hold focus once the code is tapped away from',
        );
      });
    });
  });
}
