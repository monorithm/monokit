@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monokit/monokit.dart';

/// Golden (reference-image) suite for the Monokit design language.
///
/// Baselines are generated in the Linux CI environment (see
/// `.github/workflows/goldens.yml`) and committed under `test/goldens/images/`.
/// The pinned Flutter version plus the bundled IBM Plex fonts make the render
/// deterministic there, so the ordinary `flutter test` gate can verify them on
/// every push. Do NOT commit macOS-generated baselines — anti-aliasing differs
/// and they will fail on CI.
///
/// Regenerate after an intentional visual change with:
///   flutter test --update-goldens test/goldens   (on Linux / via the workflow)
void main() {
  setUpAll(_loadPlexFonts);

  for (final scene in _scenes) {
    testWidgets('${scene.name} · light', (tester) async {
      await _pumpScene(tester, scene, MonokitThemeData.light());
      await expectLater(
        find.byKey(_sceneKey),
        matchesGoldenFile('images/${scene.name}.light.png'),
      );
    });

    testWidgets('${scene.name} · dark', (tester) async {
      await _pumpScene(tester, scene, MonokitThemeData.dark());
      await expectLater(
        find.byKey(_sceneKey),
        matchesGoldenFile('images/${scene.name}.dark.png'),
      );
    });
  }
}

const Key _sceneKey = ValueKey<String>('golden-scene');

class _Scene {
  const _Scene(this.name, this.width, this.build);
  final String name;
  final double width;
  final WidgetBuilder build;
}

Future<void> _pumpScene(
  WidgetTester tester,
  _Scene scene,
  MonokitThemeData theme,
) async {
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(
    MonokitApp(
      theme: theme,
      home: ColoredBox(
        color: theme.colors.background,
        child: Center(
          child: RepaintBoundary(
            key: _sceneKey,
            child: ColoredBox(
              color: theme.colors.background,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: scene.width,
                  child: Builder(builder: scene.build),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Settle implicit entrance animations without risking an infinite pump.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _loadPlexFonts() async {
  const families = <String, List<String>>{
    'packages/monokit/IBM Plex Sans': <String>['fonts/IBMPlexSans.ttf'],
    'packages/monokit/IBM Plex Mono': <String>[
      'fonts/IBMPlexMono-Regular.ttf',
      'fonts/IBMPlexMono-Medium.ttf',
    ],
    'packages/monokit/IBM Plex Serif': <String>[
      'fonts/IBMPlexSerif-Regular.ttf',
      'fonts/IBMPlexSerif-SemiBold.ttf',
    ],
  };
  for (final MapEntry<String, List<String>> entry in families.entries) {
    final FontLoader loader = FontLoader(entry.key);
    for (final String path in entry.value) {
      final Uint8List bytes = File(path).readAsBytesSync();
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

Widget _label(String text) => Text(text);

final List<_Scene> _scenes = <_Scene>[
  _Scene('buttons', 260, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MonoButtonVariant variant
            in MonoButtonVariant.values) ...<Widget>[
          MonoButton(
            variant: variant,
            onPressed: () {},
            child: Text(variant.name),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }),
  _Scene('checkbox', 300, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MonoCheckbox(
          value: false,
          onChanged: (_) {},
          label: _label('Unchecked'),
        ),
        const SizedBox(height: 12),
        MonoCheckbox(value: true, onChanged: (_) {}, label: _label('Checked')),
        const SizedBox(height: 12),
        MonoCheckbox(
          value: null,
          tristate: true,
          onChanged: (_) {},
          label: _label('Mixed'),
        ),
        const SizedBox(height: 12),
        const MonoCheckbox(value: true, label: Text('Disabled')),
      ],
    );
  }),
  _Scene('switch', 300, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MonoSwitch(value: false, onChanged: (_) {}, label: _label('Off')),
        const SizedBox(height: 12),
        MonoSwitch(value: true, onChanged: (_) {}, label: _label('On')),
        const SizedBox(height: 12),
        const MonoSwitch(value: true, label: Text('Disabled')),
      ],
    );
  }),
  _Scene('radio', 300, (context) {
    return MonoRadioGroup<String>(
      defaultValue: 'free',
      options: const <MonoRadioOption<String>>[
        MonoRadioOption<String>(value: 'free', label: Text('Pickup — free')),
        MonoRadioOption<String>(
          value: 'accra',
          label: Text('Delivery in Accra'),
        ),
        MonoRadioOption<String>(
          value: 'landmark',
          label: Text('Meet at a landmark'),
        ),
      ],
    );
  }),
  _Scene('input', 320, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        MonoInput(placeholder: 'Display name'),
        SizedBox(height: 12),
        MonoInput(invalid: true, placeholder: 'Required'),
      ],
    );
  }),
  _Scene('badges', 320, (context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final MonoBadgeVariant variant in MonoBadgeVariant.values)
          MonoBadge(variant: variant, child: Text(variant.name)),
      ],
    );
  }),
  _Scene('alerts', 360, (context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const <Widget>[
        MonoAlert(
          title: Text('Heads up'),
          description: Text('Your post is reaching people nearby.'),
        ),
        SizedBox(height: 12),
        MonoAlert(
          variant: MonoAlertVariant.destructive,
          title: Text('Cannot publish'),
          description: Text('Add a title before posting.'),
        ),
      ],
    );
  }),
  _Scene('card', 340, (context) {
    return const MonoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MonoCardHeader(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MonoCardTitle(child: Text('Reach summary')),
                MonoCardDescription(
                  child: Text('Two posts reaching people nearby.'),
                ),
              ],
            ),
          ),
          MonoCardContent(
            child: Text('Honest states, borders, and light — not shadows.'),
          ),
        ],
      ),
    );
  }),
  _Scene('tabs', 360, (context) {
    return MonoTabs(
      tabs: <MonoTab>[
        MonoTab.text(
          value: 'active',
          label: 'Active',
          content: const Text('Two posts.'),
        ),
        MonoTab.text(
          value: 'reserved',
          label: 'Reserved',
          content: const Text('One buyer.'),
        ),
        MonoTab.text(
          value: 'sold',
          label: 'Sold',
          content: const Text('None yet.'),
        ),
      ],
    );
  }),
  _Scene('accordion', 360, (context) {
    return MonoAccordion(
      items: <MonoAccordionItem>[
        MonoAccordionItem.text(
          value: 'reach',
          title: 'How does reach work?',
          initiallyExpanded: true,
          content: const Text('Routed to relevant nearby people.'),
        ),
        MonoAccordionItem.text(
          value: 'number',
          title: 'When is my number shared?',
          content: const Text('Only after you accept.'),
        ),
      ],
    );
  }),
];
