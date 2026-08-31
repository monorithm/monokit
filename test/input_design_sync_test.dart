import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Pins the shape of a text control against the Atlas.
///
/// These assert structure — is there a fill, is there a border, which step of
/// the ladder, is the ring outside the box — rather than the cosmetic values
/// the token tests already guard. The structural facts are the ones that
/// regressed silently last time: the field had drifted into a bordered box
/// with no fill and nothing failed, because nothing was watching the shape.
void main() {
  BoxDecoration decorationOf(WidgetTester tester, Type of) {
    final container = tester.widget<AnimatedContainer>(
      find
          .descendant(
            of: find.byType(of),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    return container.decoration! as BoxDecoration;
  }

  group('the field is a well, not a bordered box', () {
    testWidgets('it is filled and has no border in any state', (tester) async {
      final theme = MonokitThemeData.light();
      final focus = FocusNode();
      await tester.pumpWidget(
        monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: focus))),
      );

      for (final state in <String>['unfocused', 'focused']) {
        if (state == 'focused') {
          focus.requestFocus();
          await tester.pumpAndSettle();
        }
        final d = decorationOf(tester, MonoInput);
        expect(
          d.color,
          theme.colors.muted,
          reason: 'the well is the fill ($state)',
        );
        expect(d.border, isNull, reason: 'a well has no border ($state)');
        expect(
          d.boxShadow,
          anyOf(isNull, isEmpty),
          reason:
              'the ring is a real outline outside the box, not a shadow on it',
        );
      }
      expect(
        (decorationOf(tester, MonoInput).borderRadius! as BorderRadius)
            .topLeft
            .x,
        14,
      );
    });

    testWidgets('disabled keeps the shape and loses weight', (tester) async {
      final theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(width: 300, child: MonoInput(enabled: false)),
        ),
      );
      final d = decorationOf(tester, MonoInput);
      expect(d.border, isNull);
      expect(
        d.color!.a,
        lessThan(theme.colors.muted.a),
        reason: 'a disabled field recedes rather than becoming a new component',
      );
    });
  });

  group('the height ladder', () {
    testWidgets('resolves the three steps from density, not from spacing', (
      tester,
    ) async {
      for (final (MonoInputSize size, double expected)
          in <(MonoInputSize, double)>[
            (MonoInputSize.small, 44),
            (MonoInputSize.medium, 48),
            (MonoInputSize.large, 56),
          ]) {
        await tester.pumpWidget(
          monokitHost(SizedBox(width: 300, child: MonoInput(size: size))),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(MonoInput)).height,
          expected,
          reason: '$size should be the density step, not spacing.huge (40)',
        );
      }
    });

    testWidgets('every step clears the minimum touch target', (tester) async {
      const density = MonokitDensity(mode: MonoDensity.touch);
      for (final size in MonoInputSize.values) {
        await tester.pumpWidget(
          monokitHost(SizedBox(width: 300, child: MonoInput(size: size))),
        );
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(MonoInput)).height,
          greaterThanOrEqualTo(density.minTarget),
        );
      }
    });
  });

  group('the value is the loudest thing in the field', () {
    Future<TextStyle> styleOf(WidgetTester tester, MonoInputSize size) async {
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            child: MonoInput(size: size, initialValue: '24 555 0192'),
          ),
        ),
      );
      return tester.widget<EditableText>(find.byType(EditableText)).style;
    }

    testWidgets('large is set at 20/600, the size the Atlas draws', (
      tester,
    ) async {
      final s = await styleOf(tester, MonoInputSize.large);
      expect(s.fontSize, 20);
      expect(s.fontWeight, FontWeight.w600);
    });

    testWidgets('medium and small are set at 14/500', (tester) async {
      for (final size in <MonoInputSize>[
        MonoInputSize.medium,
        MonoInputSize.small,
      ]) {
        final s = await styleOf(tester, size);
        expect(s.fontSize, 14);
        expect(
          s.fontWeight,
          FontWeight.w500,
          reason: 'a typed value outranks body copy even at the small step',
        );
      }
    });

    testWidgets('the placeholder is one weight lighter and muted', (
      tester,
    ) async {
      final theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 300,
            child: MonoInput(
              size: MonoInputSize.large,
              placeholder: '24 555 0192',
            ),
          ),
        ),
      );
      final hint = tester.widget<Text>(find.text('24 555 0192'));
      expect(
        hint.style!.fontWeight,
        FontWeight.w500,
        reason: 'one step below the value 600',
      );
      expect(hint.style!.color, theme.colors.mutedForeground);
    });

    testWidgets('tabular figures are opt-in and off by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 300,
            child: MonoInput(tabularFigures: true, initialValue: '240'),
          ),
        ),
      );
      final s = tester.widget<EditableText>(find.byType(EditableText)).style;
      expect(s.fontFeatures, isNotNull);
      expect(s.fontFeatures!.map((f) => f.feature), contains('tnum'));

      await tester.pumpWidget(
        monokitHost(
          const SizedBox(width: 300, child: MonoInput(initialValue: 'prose')),
        ),
      );
      final plain = tester
          .widget<EditableText>(find.byType(EditableText))
          .style;
      expect(plain.fontFeatures ?? const <FontFeature>[], isEmpty);
    });
  });

  group('the focus ring', () {
    /// The ring is bound to focus-visible, so a test that only calls
    /// requestFocus exercises the pointer path and will never see it.
    void highlight(FocusHighlightStrategy strategy) {
      FocusManager.instance.highlightStrategy = strategy;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
    }

    double ringOpacity(WidgetTester tester) => tester
        .widget<AnimatedOpacity>(
          find
              .descendant(
                of: find.byType(MonoFocusRingOverlay),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;

    testWidgets('touch focus shows the caret and no ring', (tester) async {
      highlight(FocusHighlightStrategy.alwaysTouch);
      final focus = FocusNode();
      await tester.pumpWidget(
        monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: focus))),
      );
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(
        ringOpacity(tester),
        0,
        reason: 'a tapped field already announces itself with the caret',
      );
    });

    testWidgets('is painted outside the field and does not move it', (
      tester,
    ) async {
      highlight(FocusHighlightStrategy.alwaysTraditional);
      final focus = FocusNode();
      await tester.pumpWidget(
        monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: focus))),
      );
      await tester.pumpAndSettle();
      final before = tester.getRect(find.byType(MonoInput));

      focus.requestFocus();
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byType(MonoInput)),
        before,
        reason: 'a ring that resizes the field shifts every sibling on tab',
      );

      final ring = find.descendant(
        of: find.byType(MonoFocusRingOverlay),
        matching: find.byType(DecoratedBox),
      );
      final ringRect = tester.getRect(ring.last);
      // ringOffset 2 + ringWidth 2 on every side.
      expect(ringRect.left, closeTo(before.left - 4, 0.01));
      expect(ringRect.top, closeTo(before.top - 4, 0.01));
      expect(ringRect.right, closeTo(before.right + 4, 0.01));
    });

    testWidgets('is absent unfocused and solid when focused', (tester) async {
      highlight(FocusHighlightStrategy.alwaysTraditional);
      final theme = MonokitThemeData.light();
      final focus = FocusNode();
      await tester.pumpWidget(
        monokitHost(SizedBox(width: 300, child: MonoInput(focusNode: focus))),
      );
      await tester.pumpAndSettle();

      expect(ringOpacity(tester), 0);
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(ringOpacity(tester), 1);

      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(MonoFocusRingOverlay),
              matching: find.byType(DecoratedBox),
            )
            .last,
      );
      final side = ((box.decoration as BoxDecoration).border! as Border).top;
      expect(side.width, 2, reason: 'the Atlas draws a 2px outline');
      expect(side.color, theme.colors.ring);
      expect(side.color.a, 1.0, reason: 'solid, not a translucent band');
    });

    testWidgets('invalid recolours the well and grows no ring', (tester) async {
      final theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(width: 300, child: MonoInput(invalid: true)),
        ),
      );
      await tester.pumpAndSettle();

      // "Invalid recolours the well itself - no second border language."
      final d = decorationOf(tester, MonoInput);
      expect(d.color, theme.colors.destructiveSoft);
      expect(d.border, isNull);

      // And it grows no ring: a ring means focus, and the Atlas allows one
      // ring on screen at a time.
      expect(
        ringOpacity(tester),
        0,
        reason: 'invalidity is carried by colour, not by the focus ring',
      );

      // The value inside agrees with the message beneath it.
      final style = tester
          .widget<EditableText>(find.byType(EditableText))
          .style;
      expect(style.color, theme.colors.destructiveText);
    });
  });

  group('controlled and pending', () {
    testWidgets('value + onChanged behaves like every other control', (
      tester,
    ) async {
      String value = 'Ama';
      await tester.pumpWidget(
        monokitHost(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) => SizedBox(
              width: 300,
              child: MonoInput(
                value: value,
                onChanged: (String v) => setState(() => value = v),
              ),
            ),
          ),
        ),
      );
      expect(find.text('Ama'), findsOneWidget);

      await tester.enterText(find.byType(EditableText), 'Ama Serwaa');
      await tester.pump();
      expect(value, 'Ama Serwaa');
      expect(find.text('Ama Serwaa'), findsOneWidget);
    });

    testWidgets('pending shows a spinner and leaves the field usable', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 300,
            child: MonoInput(pending: true, semanticLabel: 'Handle'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(MonoSpinner), findsOneWidget);
      // Distinct from disabled: the user keeps typing while validation runs.
      await tester.enterText(find.byType(EditableText), 'amaserwaa');
      expect(find.text('amaserwaa'), findsOneWidget);
    });
  });

  testWidgets('all four text controls share one skin', (tester) async {
    final heights = <String, double>{};
    final radii = <String, double>{};

    Future<void> measure(String name, Widget w, Type type) async {
      await tester.pumpWidget(monokitHost(SizedBox(width: 320, child: w)));
      await tester.pumpAndSettle();
      heights[name] = tester.getSize(find.byType(type)).height;
      final d = decorationOf(tester, type);
      radii[name] = (d.borderRadius! as BorderRadius).topLeft.x;
      expect(d.border, isNull, reason: '$name still draws a border');
      expect(
        d.color,
        MonokitThemeData.light().colors.muted,
        reason: '$name is not filled with the well',
      );
    }

    await measure('input', const MonoInput(), MonoInput);
    await measure(
      'select',
      MonoSelect<String>(
        options: const <MonoSelectOption<String>>[
          MonoSelectOption<String>(value: 'a', label: Text('A')),
        ],
      ),
      MonoSelect<String>,
    );
    await measure(
      'combobox',
      MonoCombobox<String>(
        options: const <MonoComboboxOption<String>>[
          MonoComboboxOption<String>(
            value: 'a',
            label: Text('A'),
            searchText: 'a',
          ),
        ],
      ),
      MonoCombobox<String>,
    );

    expect(
      heights.values.toSet().length,
      1,
      reason: 'heights diverged: $heights',
    );
    expect(radii.values.toSet().length, 1, reason: 'radii diverged: $radii');
  });

  group('MonoField pending', () {
    testWidgets('reports the wait without dimming the control', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 320,
            child: MonoField(
              label: Text('Handle'),
              pending: true,
              child: MonoInput(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(MonoFieldPending), findsOneWidget);
      // Distinct from disabled, which is what the Field contract asks for: the
      // control keeps full strength while validation runs.
      final opacity = tester.widget<Opacity>(
        find
            .ancestor(
              of: find.byType(MonoInput),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(opacity.opacity, 1);
    });

    testWidgets('a settled error replaces the wait', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const SizedBox(
            width: 320,
            child: MonoField(
              pending: true,
              error: Text('That handle is taken'),
              child: MonoInput(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(MonoFieldPending), findsNothing);
      expect(find.text('That handle is taken'), findsOneWidget);
    });
  });

  group('a textarea is not a tall single-line field', () {
    testWidgets('takes prose leading and vertical padding', (tester) async {
      await tester.pumpWidget(
        monokitHost(const SizedBox(width: 320, child: MonoTextarea())),
      );
      await tester.pumpAndSettle();
      final height = tester.getSize(find.byType(MonoTextarea)).height;

      // minLines 3 at 14/1.45 is ~61, plus 8 top and bottom. If this collapses
      // toward the single-line step (48) the textarea has picked up the label
      // register's 1.2 leading, or lost its padding, or both - which is exactly
      // what happened the first time the skin landed.
      expect(height, greaterThan(70));

      await tester.pumpWidget(
        monokitHost(const SizedBox(width: 320, child: MonoInput())),
      );
      await tester.pumpAndSettle();
      expect(
        height,
        greaterThan(tester.getSize(find.byType(MonoInput)).height),
        reason: 'a three-line field must be taller than a one-line one',
      );

      await tester.pumpWidget(
        monokitHost(const SizedBox(width: 320, child: MonoTextarea())),
      );
      await tester.pumpAndSettle();

      final style = tester
          .widget<EditableText>(find.byType(EditableText))
          .style;
      expect(style.height, 1.45, reason: 'body leading, not label leading');
      expect(style.fontSize, 14);
    });
  });
}
