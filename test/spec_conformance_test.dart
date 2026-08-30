import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:monokit_ui/monokit_ui.dart';

import '_support/host.dart';

/// Covers the 3.2.0 conformance work: the specified token vocabulary, the
/// command lifecycle, the three components the specification names, and the
/// icon rules that were previously unimplemented.
void main() {
  group('specified token vocabulary', () {
    test('every specified colour name resolves', () {
      for (final colors in <MonokitColors>[
        MonokitColors.light(),
        MonokitColors.dark(),
      ]) {
        // Aliases resolve onto the roles that carry the values.
        expect(colors.background, colors.page);
        expect(colors.mutedForeground, colors.foregroundMuted);
        expect(colors.mutedText, colors.foregroundSubtle);
        expect(colors.muted, colors.fill);
        expect(colors.border, colors.separator);
        expect(colors.destructive, colors.danger);
        expect(colors.destructiveSoft, colors.dangerSoft);
        expect(colors.destructiveText, colors.dangerText);
        expect(colors.primaryForeground, colors.onPrimary);
        expect(colors.primaryText, colors.tint);
        expect(colors.liveForeground, colors.onLive);
        expect(colors.mediaCanvas, colors.canvas);
        expect(colors.glassFill, colors.mistFill);
        expect(colors.glassBorder, colors.mistLine);
        expect(colors.popover, colors.elevated);

        // The contract carries a foreground per status family; this package
        // carries one, so all four must land on it.
        expect(colors.destructiveForeground, colors.onStatus);
        expect(colors.successForeground, colors.onStatus);
        expect(colors.warningForeground, colors.onStatus);
        expect(colors.infoForeground, colors.onStatus);
      }
    });

    test('values did not move while the names were added', () {
      // The rename was a vocabulary change, not a visual one. If this fails,
      // the golden baselines are stale and something changed that should not
      // have.
      final light = MonokitColors.light();
      expect(light.page, const Color(0xFFF1F3F3));
      expect(light.primary, const Color(0xFF007A55));
      expect(light.canvas, const Color(0xFF000000));
      expect(light.scrim, const Color(0x73000000));
    });

    test('lerp and equality cover the tokens added in 3.2.0', () {
      final a = MonokitColors.light();
      final b = MonokitColors.dark();
      expect(a, isNot(equals(b)));
      expect(MonokitColors.lerp(a, b, 0), equals(a));
      expect(MonokitColors.lerp(a, b, 1), equals(b));
      // A token added to the class but forgotten in _fields would make these
      // two compare equal despite differing.
      expect(a.sidebar, isNot(equals(b.sidebar)));
      expect(MonokitColors.lerp(a, b, 1).sidebar, b.sidebar);
      expect(a.copyWith(chart1: b.chart5).chart1, b.chart5);
    });

    test('density resolves the semantic row and control metrics', () {
      const touch = MonokitDensity(mode: MonoDensity.touch);
      const pointer = MonokitDensity(mode: MonoDensity.pointer);

      expect(touch.minTarget, 44);
      expect(touch.controlHeight, 44);
      expect(touch.row1, 48);
      expect(touch.row2, 64);
      expect(touch.row3, 88);
      expect(touch.iconChrome, 20);

      expect(pointer.minTarget, 32);
      expect(pointer.controlHeight, 36);
      expect(pointer.row2, 56);
      expect(pointer.iconChrome, 16);
    });

    test('layout carries the named containers and icon ladder', () {
      expect(MonokitContainers.feed, 480);
      expect(MonokitChrome.headerHeight, 56);
      expect(MonokitList.swipeActionCell, 72);
      expect(MonokitPageInset.of(MonoWidthClass.compact), 16);
      expect(MonokitIconSize.all, <double>[16, 20, 24, 28, 32]);
      expect(MonokitIconSize.strokeXs, 1.75);
    });

    test('motion exposes the specified role names at the specified values', () {
      const m = MonokitMotion();
      expect(m.press, const Duration(milliseconds: 50));
      expect(m.state, const Duration(milliseconds: 100));
      expect(m.enter, const Duration(milliseconds: 150));
      expect(m.emphasis, const Duration(milliseconds: 220));
      expect(m.screen, const Duration(milliseconds: 300));
    });

    test('radii carry xs', () {
      expect(const MonokitRadii().xs, 4);
    });
  });

  group('command lifecycle', () {
    test('the five phases classify themselves', () {
      expect(MonoPhase.pending.isInFlight, isTrue);
      expect(MonoPhase.reconciling.isInFlight, isTrue);
      expect(MonoPhase.succeeded.isInFlight, isFalse);

      // The distinction the whole phase set exists to protect.
      expect(MonoPhase.rejected.isUnresolved, isTrue);
      expect(MonoPhase.stalled.isUnresolved, isTrue);
      expect(MonoPhase.stalled.awaitsUser, isTrue);
      expect(MonoPhase.rejected.awaitsUser, isFalse);
    });

    testWidgets('rejected and stalled do not look alike', (tester) async {
      final theme = MonokitThemeData.light();
      await tester.pumpWidget(
        monokitHost(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MonoPhaseBadge(phase: MonoPhase.rejected, label: 'Declined'),
              MonoPhaseBadge(phase: MonoPhase.stalled, label: 'Not sent'),
            ],
          ),
        ),
      );

      Color groundOf(String label) {
        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Container))
              .first,
        );
        return ((container.decoration! as BoxDecoration).color)!;
      }

      final rejected = groundOf('Declined');
      final stalled = groundOf('Not sent');
      expect(rejected, isNot(equals(stalled)));
      expect(rejected, theme.colors.destructiveSoft);
      expect(stalled, theme.colors.warningSoft);
    });

    testWidgets('the badge carries its label to semantics', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoPhaseBadge(phase: MonoPhase.pending, label: 'Sending'),
        ),
      );
      expect(find.bySemanticsLabel('Sending'), findsOneWidget);
    });

    testWidgets('a skeleton can sweep once instead of looping', (tester) async {
      await tester.pumpWidget(
        monokitHost(const MonoSkeleton(width: 80, height: 8, sweepOnce: true)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      // A single sweep settles; a loop never does. If this ever hangs, the
      // sweep has become a repeat and "settled" is unrenderable again.
      await tester.pumpAndSettle();
      expect(find.byType(MonoSkeleton), findsOneWidget);
    });
  });

  group('MonoPager', () {
    testWidgets('commits past the travel threshold', (tester) async {
      int index = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            height: 200,
            child: MonoPager(
              index: index,
              onIndexChanged: (int i) => index = i,
              children: const <Widget>[Text('one'), Text('two')],
            ),
          ),
        ),
      );

      // 40% of 300 is past the 30% commit fraction.
      await tester.drag(find.byType(MonoPager), const Offset(-120, 0));
      await tester.pumpAndSettle();
      expect(index, 1);
    });

    testWidgets('ignores travel below the threshold', (tester) async {
      int index = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            height: 200,
            child: MonoPager(
              index: index,
              onIndexChanged: (int i) => index = i,
              children: const <Widget>[Text('one'), Text('two')],
            ),
          ),
        ),
      );

      // 10% of the width, released slowly: neither signal fires.
      await tester.timedDrag(
        find.byType(MonoPager),
        const Offset(-30, 0),
        const Duration(milliseconds: 600),
      );
      await tester.pumpAndSettle();
      expect(index, 0);
    });

    testWidgets('will not page past either end', (tester) async {
      int index = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            height: 200,
            child: MonoPager(
              index: index,
              onIndexChanged: (int i) => index = i,
              children: const <Widget>[Text('one'), Text('two')],
            ),
          ),
        ),
      );
      await tester.drag(find.byType(MonoPager), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(index, 0);
    });

    testWidgets('arrow keys page without a pointer', (tester) async {
      int index = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 300,
            height: 200,
            child: MonoPager(
              index: index,
              onIndexChanged: (int i) => index = i,
              children: const <Widget>[Text('one'), Text('two')],
            ),
          ),
        ),
      );

      Focus.of(tester.element(find.text('one'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(
        index,
        1,
        reason: 'the gesture ships with its keyboard equivalent',
      );
    });
  });

  group('MonoPageDots', () {
    testWidgets('is one semantics node reporting position and length', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(const MonoPageDots(count: 3, index: 1, label: 'Photo')),
      );
      // Not three anonymous stops — one node carrying the whole message.
      expect(find.bySemanticsLabel('Photo 2 of 3'), findsOneWidget);
    });

    testWidgets('widens the active dot rather than only recolouring it', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(const MonoPageDots(count: 3, index: 0)),
      );
      await tester.pumpAndSettle();

      final dots = find.byType(AnimatedContainer);
      // getSize includes each dot's equal margins, so the difference is the
      // signal: 20 wide against 8.
      expect(
        tester.getSize(dots.at(0)).width - tester.getSize(dots.at(1)).width,
        12,
        reason:
            'the active dot widens, so position survives a colour-blind '
            'reading rather than depending on hue',
      );
    });
  });

  group('MonoModal', () {
    testWidgets('the dismiss barrier is a labelled control', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 400,
            height: 600,
            child: MonoModal(
              onClose: () {},
              semanticLabel: 'Confirm',
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      // A bare gesture target would be invisible here, which is what turns a
      // modal into a trap with no announced exit.
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
    });

    testWidgets('the barrier and Escape both dismiss', (tester) async {
      int closed = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 400,
            height: 600,
            child: MonoModal(
              onClose: () => closed++,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      // The focus trap autofocuses on mount, so Escape is routed by the
      // modal's own Shortcuts without anything else asking for focus.
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 1, reason: 'Escape dismisses');

      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pump();
      expect(closed, 2, reason: 'and so does the labelled barrier');
    });

    testWidgets('a non-dismissible modal ignores both', (tester) async {
      int closed = 0;
      await tester.pumpWidget(
        monokitHost(
          SizedBox(
            width: 400,
            height: 600,
            child: MonoModal(
              onClose: () => closed++,
              dismissible: false,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Close'), warnIfMissed: false);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closed, 0);
    });

    testWidgets('the exclusion triad moves together', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoModalBarrierScope(excluded: true, child: Text('behind')),
        ),
      );
      // Excluding one modality and not the others leaves the background
      // reachable by whichever was missed.
      for (final Type t in <Type>[
        ExcludeFocus,
        IgnorePointer,
        ExcludeSemantics,
      ]) {
        expect(
          find.descendant(
            of: find.byType(MonoModalBarrierScope),
            matching: find.byType(t),
          ),
          findsOneWidget,
          reason: '\$t must move with the other two',
        );
      }
    });
  });

  group('MonoIcon', () {
    testWidgets('takes its default size from density', (tester) async {
      await tester.pumpWidget(
        monokitHost(
          const MonoIcon(MonoIcons.search),
          theme: MonokitThemeData.light().copyWith(
            density: const MonokitDensity(mode: MonoDensity.touch),
          ),
        ),
      );
      expect(tester.widget<HugeIcon>(find.byType(HugeIcon)).size, 20);

      await tester.pumpWidget(
        monokitHost(
          const MonoIcon(MonoIcons.search),
          theme: MonokitThemeData.light().copyWith(
            density: const MonokitDensity(mode: MonoDensity.pointer),
          ),
        ),
      );
      expect(tester.widget<HugeIcon>(find.byType(HugeIcon)).size, 16);
    });

    testWidgets('applies the optical stroke floor at 16 and only at 16', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MonoIcon(MonoIcons.search, size: 16),
              MonoIcon(MonoIcons.search, size: 24),
              MonoIcon(MonoIcons.search, size: 24, active: true),
            ],
          ),
        ),
      );
      final strokes = tester
          .widgetList<HugeIcon>(find.byType(HugeIcon))
          .map((HugeIcon i) => i.strokeWidth)
          .toList();
      expect(strokes[0], 1.75);
      expect(strokes[1], 1.5);
      expect(strokes[2], 2.0);
    });

    testWidgets('mirrors direction roles in RTL, and only those', (
      tester,
    ) async {
      await tester.pumpWidget(
        monokitHost(
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MonoIcon(MonoIcons.chevronRight),
                MonoIcon(MonoIcons.camera),
              ],
            ),
          ),
        ),
      );
      // A chevron means "onward" and follows the reading direction. A camera
      // depicts an object and points the same way in every language.
      expect(find.byType(Transform), findsOneWidget);
    });

    test('refuses sizes outside the ladder', () {
      expect(() => MonoIcon(MonoIcons.search, size: 12), throwsAssertionError);
      expect(() => MonoIcon(MonoIcons.search, size: 40), throwsAssertionError);
      expect(() => MonoIcon(MonoIcons.search, size: 32), returnsNormally);
    });

    test('carries the roles the design boards need', () {
      // Each of these had no role and became a raw vendor constant at the
      // call site.
      expect(MonoIcons.list.semanticLabel, isNotNull);
      expect(MonoIcons.shield.semanticLabel, isNotNull);
      expect(MonoIcons.trash.semanticLabel, isNotNull);
      expect(MonoIcons.flag.semanticLabel, isNotNull);
      expect(MonoIcons.wifiOff.semanticLabel, isNotNull);
      expect(MonoIcons.eyeOff.semanticLabel, isNotNull);
      expect(MonoIcons.zap.semanticLabel, isNotNull);
      expect(MonoIcons.phoneIncoming.semanticLabel, isNotNull);
      expect(MonoIcons.phoneOutgoing.semanticLabel, isNotNull);
      expect(MonoIcons.plus.semanticLabel, isNotNull);
      expect(MonoIcons.refresh.semanticLabel, isNotNull);
      expect(MonoIcons.crop.semanticLabel, isNotNull);
    });
  });

  group('copy', () {
    testWidgets('the live badge is localisable and sentence case', (
      tester,
    ) async {
      await tester.pumpWidget(monokitHost(const MonoLiveBadge()));
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('LIVE'), findsNothing);

      await tester.pumpWidget(
        monokitHost(
          const MonoLiveBadge(),
          theme: MonokitThemeData.light().copyWith(
            labels: const MonokitLabels(active: 'Mubashir'),
          ),
        ),
      );
      expect(find.text('Mubashir'), findsOneWidget);
    });
  });

  group('fonts', () {
    test('an Arabic fallback is declared for every register', () {
      final t = MonokitTypography.plex();
      expect(
        MonokitTypography.plexFallback,
        contains('packages/monokit_ui/IBM Plex Sans Arabic'),
      );
      // Arabic can appear in body copy, in a title, and in a caption over
      // media, so the fallback cannot be attached to one register only.
      expect(t.bodyMedium.fontFamilyFallback, MonokitTypography.plexFallback);
      expect(t.titleLarge.fontFamilyFallback, MonokitTypography.plexFallback);
      expect(t.mediaCaption.fontFamilyFallback, MonokitTypography.plexFallback);
    });

    test('tracking matches the contract', () {
      final t = MonokitTypography.plex();
      expect(t.proseHeading.letterSpacing, -0.22);
      expect(t.headlineLarge.letterSpacing, -0.36);
    });
  });
}
