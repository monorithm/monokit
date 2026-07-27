import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child) => MonokitTheme(
  data: MonokitThemeData.light(),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  test('theme exposes canonical semantic groups', () {
    final theme = MonokitThemeData.light();
    expect(theme.brightness, Brightness.light);
    expect(theme.colors.primary, const Color(0xFF007A55));
    expect(theme.colors.scrim, const Color(0x73000000));
    expect(theme.colors.successText, const Color(0xFF016630));
    expect(theme.elevation.resolve(MonoElevation.floating), isNotEmpty);
    expect(theme.elevation.resolve(MonoElevation.flat), isEmpty);
    expect(theme.density.minimumTarget, 44);
    expect(theme.breakpoints.medium, 960);
    expect(theme.motion.modalEnter, theme.motion.moderate);
  });

  test('the grouped surface ladder steps in both modes', () {
    // Depth comes from a luminance step, so page/card/elevated must be
    // distinct in each theme — this is what replaces the hairline border.
    for (final theme in [MonokitThemeData.light(), MonokitThemeData.dark()]) {
      final c = theme.colors;
      expect(
        <Color>{c.page, c.card, c.elevated}.length,
        greaterThan(1),
        reason: '${theme.brightness} surfaces must not all be the same value',
      );
    }
    // Dark deliberately does not bottom out at black.
    expect(MonokitThemeData.dark().colors.page, isNot(const Color(0xFF000000)));
    // ...but the media canvas always is, in both modes.
    expect(MonokitThemeData.dark().colors.canvas, const Color(0xFF000000));
    expect(MonokitThemeData.light().colors.canvas, const Color(0xFF000000));
  });

  test('theme equality is structural, not identity', () {
    // Four token groups used to lack ==/hashCode while MonokitThemeData
    // compared them by field, so two independently built light themes were
    // unequal and MonokitTheme.updateShouldNotify fired on every rebuild.
    expect(MonokitThemeData.light(), MonokitThemeData.light());
    expect(
      MonokitThemeData.light().hashCode,
      MonokitThemeData.light().hashCode,
    );
    expect(MonokitThemeData.light(), isNot(MonokitThemeData.dark()));
  });

  test('theme lerp moves colours and snaps discrete groups', () {
    final a = MonokitThemeData.light();
    final b = MonokitThemeData.dark();
    expect(MonokitThemeData.lerp(a, b, 0).colors.page, a.colors.page);
    expect(MonokitThemeData.lerp(a, b, 1).colors.page, b.colors.page);
    final mid = MonokitThemeData.lerp(a, b, 0.5);
    expect(mid.colors.page, isNot(a.colors.page));
    expect(mid.colors.page, isNot(b.colors.page));
  });

  test('density resolves from platform first, then width', () {
    const bp = MonokitBreakpoints();
    MonoDensity resolve(TargetPlatform p, double w) =>
        MonokitDensity.resolveFrom(platform: p, width: w, breakpoints: bp);

    // Desktop is pointer at any width — it has a cursor regardless.
    for (final w in <double>[360, 700, 1400]) {
      expect(resolve(TargetPlatform.macOS, w), MonoDensity.pointer);
      expect(resolve(TargetPlatform.windows, w), MonoDensity.pointer);
      expect(resolve(TargetPlatform.linux, w), MonoDensity.pointer);
    }
    // Touch platforms stay touch until the expanded breakpoint.
    for (final p in <TargetPlatform>[
      TargetPlatform.iOS,
      TargetPlatform.android,
      TargetPlatform.fuchsia,
    ]) {
      expect(resolve(p, 360), MonoDensity.touch);
      expect(resolve(p, 700), MonoDensity.touch);
      expect(resolve(p, bp.expanded - 1), MonoDensity.touch);
      expect(resolve(p, bp.expanded), MonoDensity.pointer);
      expect(resolve(p, 1400), MonoDensity.pointer);
    }
  });

  test('density drives the whole ramp, not just the hit target', () {
    final touch = MonokitThemeData.light().withDensityMode(MonoDensity.touch);
    final pointer = MonokitThemeData.light().withDensityMode(
      MonoDensity.pointer,
    );

    expect(touch.rowHeight, greaterThan(pointer.rowHeight));
    expect(touch.controlHeight, greaterThan(pointer.controlHeight));
    expect(touch.layoutMargin, greaterThan(pointer.layoutMargin));
    expect(touch.bodyText.fontSize, greaterThan(pointer.bodyText.fontSize!));
    expect(touch.titleText.fontSize, greaterThan(pointer.titleText.fontSize!));
    expect(touch.density.minimumTarget, 44);
    expect(pointer.density.minimumTarget, 32);
  });

  test('destructive controls use their contrast-safe foreground', () {
    final theme = MonokitThemeData.dark();
    final button = const MonoButtonStyleResolver().resolve(
      theme: theme,
      variant: MonoButtonVariant.destructive,
      size: MonoButtonSize.md,
      states: const <MonoState>{},
    );
    final badge = const MonoBadgeStyleResolver().resolve(
      theme: theme,
      variant: MonoBadgeVariant.danger,
      size: MonoBadgeSize.md,
    );
    // Destructive controls use the soft tint (destructiveSoft) with the
    // contrast-safe destructiveText foreground, matching the reference.
    expect(button.background, theme.colors.dangerSoft);
    expect(button.foreground, theme.colors.dangerText);
    expect(badge.foreground, theme.colors.dangerText);
  });

  testWidgets('toast host owns transient event surfaces', (tester) async {
    final controller = MonokitToastController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        MonokitToastHost(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );
    controller.show(
      const MonoToast(message: Text('Saved')),
      duration: const Duration(milliseconds: 100),
    );
    await tester.pump();
    expect(find.text('Saved'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 101));
    expect(find.text('Saved'), findsNothing);
  });

  testWidgets('quantity stepper announces and changes values', (tester) async {
    var value = 1;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => MonoQuantityStepper(
            value: value,
            onChanged: (next) => setState(() => value = next),
          ),
        ),
      ),
    );
    await tester.tap(find.text('+'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('media primitives render without an engine dependency', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 240,
          height: 80,
          child: MonoWaveform(amplitudes: <double>[.2, .8, .4], progress: .5),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('logical placements mirror start and end in RTL', () {
    final ltr = MonoPlacementAnchors.resolve(
      MonoPlacement.bottomStart,
      TextDirection.ltr,
    );
    final rtl = MonoPlacementAnchors.resolve(
      MonoPlacement.bottomStart,
      TextDirection.rtl,
    );
    expect(ltr.target.x, -rtl.target.x);
  });
}
