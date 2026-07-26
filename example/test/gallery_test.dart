import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_example/container/gallery.dart';
import 'package:monokit_example/navigation/router.dart';
import 'package:monokit_example/navigation/sections.dart';
import 'package:monokit_example/sections/overview_page.dart';

/// Pumps past the first frames without settling — several sections have looping
/// animations (skeleton, spinner, reconciling shimmer) that never settle.
Future<void> _flush(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('every section renders without exceptions (desktop)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MonokitGallery());
    await _flush(tester);
    expect(find.byType(OverviewPage), findsOneWidget);

    for (final section in gallerySections) {
      router.go(section.path);
      await _flush(tester);
      expect(tester.takeException(), isNull, reason: section.path);
    }
  });

  testWidgets('every section renders without overflow (phone)', (tester) async {
    tester.view.physicalSize = const Size(390, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MonokitGallery());
    await _flush(tester);

    for (final section in gallerySections) {
      router.go(section.path);
      await _flush(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow at ${section.path}',
      );
    }
  });

  testWidgets('every scenario renders without exceptions', (tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MonokitGallery());
    await _flush(tester);

    for (final path in const <String>[
      '/scenarios/storefront',
      '/scenarios/checkout',
      '/scenarios/order-tracking',
      '/scenarios/conversation',
      '/scenarios/live-studio',
      '/scenarios/creator-studio',
      '/scenarios/team-workspace',
      '/scenarios/group-call',
    ]) {
      router.go(path);
      await _flush(tester);
      expect(tester.takeException(), isNull, reason: path);
    }
  });
}
