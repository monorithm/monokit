@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/services.dart';
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

  for (final scene in _overlayScenes) {
    testWidgets('overlay ${scene.name} · light', (tester) async {
      await _pumpOverlayScene(tester, scene, MonokitThemeData.light());
      await expectLater(
        find.byType(MonokitApp),
        matchesGoldenFile('images/overlay.${scene.name}.light.png'),
      );
    });

    testWidgets('overlay ${scene.name} · dark', (tester) async {
      await _pumpOverlayScene(tester, scene, MonokitThemeData.dark());
      await expectLater(
        find.byType(MonokitApp),
        matchesGoldenFile('images/overlay.${scene.name}.dark.png'),
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
        color: theme.colors.page,
        child: Center(
          child: RepaintBoundary(
            key: _sceneKey,
            child: ColoredBox(
              color: theme.colors.page,
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

/// A scene whose subject renders in the app's [Overlay] layer (dialog, sheet,
/// popover, open menu, …). The whole surface — scrim, anchored content, and the
/// trigger beneath it — is snapshotted, so overlays are opened declaratively via
/// each widget's `open: true` API rather than by driving a gesture.
class _OverlayScene {
  const _OverlayScene(this.name, this.build);
  final String name;
  final WidgetBuilder build;
}

Future<void> _pumpOverlayScene(
  WidgetTester tester,
  _OverlayScene scene,
  MonokitThemeData theme, {
  Size size = const Size(440, 780),
}) async {
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    MonokitApp(
      theme: theme,
      home: ColoredBox(
        color: theme.colors.page,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Builder(builder: scene.build),
          ),
        ),
      ),
    ),
  );
  // First pump inserts the overlay entry (posted after the initial frame); the
  // timed pump settles its entrance animation.
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
            child: Text('Separated by a step in light, not by a border.'),
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
  _Scene('select', 300, (context) {
    return MonoSelect<String>(
      value: 'seller',
      placeholder: 'Choose a plan',
      options: <MonoSelectOption<String>>[
        MonoSelectOption<String>(value: 'starter', label: Text('Starter')),
        MonoSelectOption<String>(value: 'seller', label: Text('Seller')),
        MonoSelectOption<String>(value: 'business', label: Text('Business')),
      ],
    );
  }),
  _Scene('field', 320, (context) {
    return MonoField(
      label: const Text('Display name'),
      description: const Text('Shown on your posts.'),
      child: const MonoInput(placeholder: 'e.g. Ama'),
    );
  }),
  _Scene('textarea', 320, (context) {
    return const MonoTextarea(
      placeholder: 'Condition, pickup area, anything useful…',
      minLines: 3,
      maxLines: 4,
    );
  }),
  _Scene('otp', 300, (context) {
    return MonoInputOtp(length: 6, onCompleted: (_) {});
  }),
  _Scene('avatar', 260, (context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MonoAvatar(initials: 'AB'),
        SizedBox(width: 12),
        MonoAvatar(initials: 'MG'),
        SizedBox(width: 12),
        MonoAvatar(initials: 'K'),
      ],
    );
  }),
  _Scene('progress', 300, (context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MonoProgress(value: 0.62),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: MonoProgress(type: MonoProgressType.circular, value: 0.62),
        ),
      ],
    );
  }),
  _Scene('spinner', 200, (context) {
    return const Align(alignment: Alignment.centerLeft, child: MonoSpinner());
  }),
  _Scene('skeleton', 280, (context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MonoSkeleton(width: 220, height: 16),
        SizedBox(height: 10),
        MonoSkeleton(width: 160, height: 16),
        SizedBox(height: 10),
        MonoSkeleton(width: 200, height: 16),
      ],
    );
  }),
  _Scene('separator', 300, (context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Above'),
        SizedBox(height: 12),
        MonoSeparator(),
        SizedBox(height: 12),
        Text('Below'),
      ],
    );
  }),
  _Scene('kbd', 240, (context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MonoKbd(child: Text('⌘')),
        SizedBox(width: 6),
        MonoKbd(child: Text('K')),
      ],
    );
  }),
  _Scene('breadcrumb', 340, (context) {
    return MonoBreadcrumb(
      children: <Widget>[
        MonoBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
        const MonoBreadcrumbSeparator(),
        MonoBreadcrumbLink(onPressed: () {}, child: const Text('Phones')),
        const MonoBreadcrumbSeparator(),
        const MonoBreadcrumbPage(child: Text('iPhone 13')),
      ],
    );
  }),
  _Scene('pagination', 360, (context) {
    return MonoPagination(totalPages: 8, defaultPage: 3, onChanged: (_) {});
  }),
  _Scene('bottom_nav', 380, (context) {
    return MonoBottomNav(
      selectedIndex: 0,
      onSelected: (_) {},
      items: const <MonoBottomNavItem>[
        MonoBottomNavItem(icon: MonoIcons.add, label: 'Create'),
        MonoBottomNavItem(icon: MonoIcons.play, label: 'Play'),
        MonoBottomNavItem(icon: MonoIcons.search, label: 'Search'),
        MonoBottomNavItem(icon: MonoIcons.message, label: 'Message'),
        MonoBottomNavItem(icon: MonoIcons.user, label: 'Account'),
      ],
    );
  }),
];

/// Overlay scenes — rendered open via each widget's `open: true` API and
/// snapshotted across the whole surface (scrim + anchored content).
final List<_OverlayScene> _overlayScenes = <_OverlayScene>[
  _OverlayScene('dialog', (context) {
    return MonoDialog(
      open: true,
      trigger: MonoButton(
        variant: MonoButtonVariant.tinted,
        child: const Text('Delete post'),
      ),
      child: MonoDialogContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const MonoDialogHeader(
              title: Text('Delete this post?'),
              description: Text('This cannot be undone.'),
            ),
            const SizedBox(height: 20),
            MonoDialogFooter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  MonoButton(
                    variant: MonoButtonVariant.tinted,
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  MonoButton(
                    variant: MonoButtonVariant.destructive,
                    onPressed: () {},
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }),
  _OverlayScene('sheet', (context) {
    return MonoSheet(
      open: true,
      trigger: MonoButton(
        variant: MonoButtonVariant.tinted,
        child: const Text('Open sheet'),
      ),
      child: const MonoSheetContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MonoSheetHeader(
              title: Text('Filters'),
              description: Text('Narrow your search.'),
            ),
            SizedBox(height: 12),
            Text('Sheet body content.'),
          ],
        ),
      ),
    );
  }),
  _OverlayScene('drawer', (context) {
    return MonoDrawer(
      open: true,
      trigger: MonoButton(
        variant: MonoButtonVariant.tinted,
        child: const Text('Open drawer'),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MonoDrawerHeader(title: Text('Navigation')),
            SizedBox(height: 8),
            Text('Drawer body content.'),
          ],
        ),
      ),
    );
  }),
  _OverlayScene('popover', (context) {
    return MonoPopover(
      open: true,
      trigger: MonoButton(
        variant: MonoButtonVariant.tinted,
        child: const Text('Show details'),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 220,
          child: Text('Anchored content that animates in and out.'),
        ),
      ),
    );
  }),
  _OverlayScene('tooltip', (context) {
    return MonoTooltip(
      open: true,
      message: 'Reaches people near Nima',
      child: MonoButton(
        variant: MonoButtonVariant.ghost,
        size: MonoButtonSize.md,
        iconOnly: true,
        onPressed: () {},
        child: const MonoIcon(MonoIcons.location),
      ),
    );
  }),
  _OverlayScene('hover_card', (context) {
    return MonoHoverCard(
      open: true,
      card: const MonoHoverCardContent(
        child: SizedBox(
          width: 240,
          child: Row(
            children: <Widget>[
              MonoAvatar(initials: 'AB'),
              SizedBox(width: 12),
              Expanded(child: Text('Ama B. — active seller near Nima.')),
            ],
          ),
        ),
      ),
      child: const Text('Ama B.'),
    );
  }),
  _OverlayScene('context_menu', (context) {
    return MonoContextMenu(
      open: true,
      menu: const MonoContextMenuContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Share'),
            SizedBox(height: 8),
            Text('Save'),
            SizedBox(height: 8),
            Text('Report'),
          ],
        ),
      ),
      child: MonoButton(
        variant: MonoButtonVariant.tinted,
        onPressed: () {},
        child: const Text('Right-click me'),
      ),
    );
  }),
  _OverlayScene('dropdown_menu', (context) {
    return MonoDropdownMenu<String>(
      open: true,
      trigger: MonoButton(
        variant: MonoButtonVariant.tinted,
        child: const Text('Actions'),
      ),
      items: <MonoDropdownMenuItem<String>>[
        MonoDropdownMenuItem<String>.text(value: 'share', label: 'Share'),
        MonoDropdownMenuItem<String>.text(value: 'save', label: 'Save'),
        MonoDropdownMenuItem<String>.text(value: 'report', label: 'Report'),
      ],
    );
  }),
  _OverlayScene('select_open', (context) {
    return MonoSelect<String>(
      defaultOpen: true,
      placeholder: 'Choose a plan',
      options: <MonoSelectOption<String>>[
        MonoSelectOption<String>(value: 'starter', label: Text('Starter')),
        MonoSelectOption<String>(value: 'seller', label: Text('Seller')),
        MonoSelectOption<String>(value: 'business', label: Text('Business')),
      ],
    );
  }),
];
