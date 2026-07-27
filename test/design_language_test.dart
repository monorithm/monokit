import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

Widget _host(Widget child) => MonokitTheme(
  data: MonokitThemeData.light(),
  child: Directionality(textDirection: TextDirection.ltr, child: child),
);

void main() {
  test('theme v2 exposes canonical semantic groups', () {
    final theme = MonokitThemeData.light();
    expect(theme.colors.primary, const Color(0xFF007A55));
    expect(theme.colors.overlayScrim, const Color(0x1A000000));
    expect(theme.colors.successText, const Color(0xFF016630));
    expect(theme.elevation.resolve(MonoElevationTier.e3), isNotEmpty);
    expect(theme.density.minimumTarget, 48);
    expect(theme.breakpoints.medium, 960);
    expect(theme.motion.modalEnter, theme.motion.moderate);
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
      variant: MonoBadgeVariant.destructive,
      size: MonoBadgeSize.md,
    );
    // Destructive controls use the soft tint (destructiveSoft) with the
    // contrast-safe destructiveText foreground, matching the reference.
    expect(button.background, theme.colors.destructiveSoft);
    expect(button.foreground, theme.colors.destructiveText);
    expect(badge.foreground, theme.colors.destructiveText);
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
