import 'package:flutter_test/flutter_test.dart';
import 'package:monokit_ui/monokit_ui.dart';

Widget _host(Widget child, {MonokitThemeData? theme}) {
  final data = theme ?? MonokitThemeData.light();
  return Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 600)),
      child: MonokitTheme(
        data: data,
        child: DefaultTextStyle(
          style: data.typography.body.copyWith(color: data.colors.foreground),
          child: child,
        ),
      ),
    ),
  );
}

/// Minimal delegate so [MonokitApp.router] can be exercised without pulling a
/// routing package into the library's dev dependencies.
class _StubRouterDelegate extends RouterDelegate<Object> with ChangeNotifier {
  _StubRouterDelegate(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => child;

  @override
  Future<bool> popRoute() async => false;

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}

void main() {
  group('design tokens', () {
    test('light and dark presets expose the documented semantic colors', () {
      final light = MonokitThemeData.light();
      final dark = MonokitThemeData.dark();

      // Light: emerald on mist. The page is the mist step, cards sit above it.
      expect(light.colors.background, const Color(0xFFF1F3F3));
      expect(light.colors.card, const Color(0xFFFFFFFF));
      expect(light.colors.foreground, const Color(0xFF090B0C));
      expect(light.colors.primary, const Color(0xFF007A55));
      expect(light.colors.primaryText, const Color(0xFF007A55));
      expect(light.colors.destructive, const Color(0xFFE7000B));
      expect(light.colors.successSoft, const Color(0xFFD7F9DC));

      // Dark: lifted charcoal, not the old near-black #090B0C.
      expect(dark.colors.background, const Color(0xFF161B1D));
      expect(dark.colors.card, const Color(0xFF22292B));
      expect(dark.colors.ring, const Color(0xFF67787C));
      // tint and primary diverge in dark: text lightens, fill darkens.
      expect(dark.colors.primaryText, const Color(0xFF00BC7D));
      expect(dark.colors.primary, const Color(0xFF006045));
      expect(light.radii.lg, 10);
      expect(light.spacing.s4, 4);
      expect(light.spacing.s48, 48);
      expect(light.motion.base, const Duration(milliseconds: 150));
    });

    test('state controller notifies only on real changes', () {
      final controller = MonoStatesController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      expect(controller.add(MonoState.hovered), isTrue);
      expect(controller.add(MonoState.hovered), isFalse);
      expect(controller.contains(MonoState.hovered), isTrue);
      controller.setAll(<MonoState>{MonoState.focused, MonoState.pressed});

      expect(controller.states, <MonoState>{
        MonoState.focused,
        MonoState.pressed,
      });
      expect(notifications, 2);
      controller.dispose();
    });
  });

  testWidgets('MonokitApp installs its theme below WidgetsApp', (tester) async {
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: Builder(
          builder: (context) => Text(
            MonokitTheme.of(
              context,
            ).colors.primary.toARGB32().toRadixString(16),
          ),
        ),
      ),
    );

    expect(find.text('ff007a55'), findsOneWidget);
  });

  testWidgets('MonokitApp supports named routes with token-timed transitions', (
    tester,
  ) async {
    final theme = MonokitThemeData.light();
    await tester.pumpWidget(
      MonokitApp(
        theme: theme,
        initialRoute: '/docs',
        routes: <String, WidgetBuilder>{
          '/': (_) => const Text('Home'),
          '/docs': (_) => const Text('Documentation'),
          '/forms': (_) => const Text('Forms route'),
        },
      ),
    );
    await tester.pump();

    expect(find.text('Documentation'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/forms');
    await tester.pump();
    await tester.pump(theme.motion.duration);

    expect(find.text('Forms route'), findsOneWidget);
    final route = ModalRoute.of(tester.element(find.text('Forms route')))!;
    expect(route.transitionDuration, theme.motion.duration);
  });

  testWidgets('MonokitApp.router installs its theme over a RouterConfig', (
    tester,
  ) async {
    final delegate = _StubRouterDelegate(
      Builder(
        builder: (context) => Text(
          MonokitTheme.of(context).colors.primary.toARGB32().toRadixString(16),
        ),
      ),
    );
    addTearDown(delegate.dispose);

    await tester.pumpWidget(
      MonokitApp.router(
        theme: MonokitThemeData.light(),
        routerConfig: RouterConfig<Object>(routerDelegate: delegate),
      ),
    );

    expect(find.text('ff007a55'), findsOneWidget);
  });

  testWidgets('button and editable input are interactive without Material', (
    tester,
  ) async {
    var presses = 0;
    final textController = TextEditingController();
    // MonoInput's text selection needs an Overlay ancestor (as every
    // EditableText does); MonokitApp provides one without pulling in Material.
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MonoButton(onPressed: () => presses++, child: const Text('Save')),
              MonoInput(controller: textController, placeholder: 'Name'),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.tap(find.byType(EditableText));
    await tester.enterText(find.byType(EditableText), 'Ada');

    expect(presses, 1);
    expect(textController.text, 'Ada');
    textController.dispose();
  });

  testWidgets('checkbox, tabs and accordion expose functional state changes', (
    tester,
  ) async {
    bool? checked = false;
    String? expandedItem;
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 400,
          height: 360,
          child: Column(
            children: <Widget>[
              MonoCheckbox(
                value: checked,
                label: const Text('Accept'),
                onChanged: (value) => checked = value,
              ),
              Expanded(
                child: MonoTabs(
                  tabs: <MonoTab>[
                    MonoTab.text(
                      value: 'first',
                      label: 'First',
                      content: const Text('First panel'),
                    ),
                    MonoTab.text(
                      value: 'second',
                      label: 'Second',
                      content: const Text('Second panel'),
                    ),
                  ],
                ),
              ),
              MonoAccordion(
                onChanged: (value) => expandedItem = value,
                items: <MonoAccordionItem>[
                  MonoAccordionItem.text(
                    value: 'details',
                    title: 'Details',
                    content: const Text('Accordion content'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Accept'));
    expect(checked, isTrue);

    expect(find.text('First panel'), findsOneWidget);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(find.text('Second panel'), findsOneWidget);

    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(expandedItem, 'details');
  });

  testWidgets('vertical tabs resolve a finite trigger-list width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 320,
          height: 160,
          child: MonoTabs(
            orientation: MonoTabsOrientation.vertical,
            variant: MonoTabsVariant.line,
            tabs: <MonoTab>[
              MonoTab.text(
                value: 'first',
                label: 'First',
                content: Text('First vertical panel'),
              ),
              MonoTab.text(
                value: 'second',
                label: 'Second',
                content: Text('Second vertical panel'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('First vertical panel'), findsOneWidget);
    await tester.tap(find.text('Second'));
    await tester.pumpAndSettle();
    expect(find.text('Second vertical panel'), findsOneWidget);
  });

  testWidgets('field separator stacks a long label on narrow layouts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 160,
          child: MonoFieldSeparator(label: Text('Optional project details')),
        ),
      ),
    );

    expect(find.text('Optional project details'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'compact sidebar hides closed controls and reports its expanded state',
    (tester) async {
      final controller = MonoSidebarController();
      addTearDown(controller.dispose);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 390,
              height: 600,
              child: MonoScreen(
                sidebarController: controller,
                header: MonoScreenHeader(
                  leading: MonoSidebarTrigger(
                    controller: controller,
                    child: const Text('Menu'),
                  ),
                ),
                sidebar: MonoSidebar(
                  child: MonoButton(
                    semanticLabel: 'Sidebar destination',
                    onPressed: () {},
                    child: const Text('Destination'),
                  ),
                ),
                body: const Text('Page body'),
              ),
            ),
          ),
        ),
      );

      expect(
        find.semantics.byLabel(RegExp('Sidebar destination')),
        findsNothing,
      );
      final closedTrigger = find.semantics
          .byLabel(RegExp('Toggle navigation'))
          .evaluate()
          .single;
      expect(
        closedTrigger.getSemanticsData().flagsCollection.toStrings().contains(
          'hasExpandedState',
        ),
        isTrue,
      );
      expect(
        closedTrigger.getSemanticsData().flagsCollection.toStrings().contains(
          'isExpanded',
        ),
        isFalse,
      );

      controller.open();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.semantics.byLabel(RegExp('Sidebar destination')),
        findsOneWidget,
      );
      // The page — trigger included — is inert while the sidebar is open, so
      // the trigger is no longer in the tree to report an expanded state. The
      // barrier over the page carries the labelled way back out instead.
      expect(find.semantics.byLabel(RegExp('Toggle navigation')), findsNothing);
      expect(find.semantics.byLabel(RegExp('Close sidebar')), findsOneWidget);
      semantics.dispose();
    },
  );

  testWidgets('open compact sidebar makes the page inert', (tester) async {
    final controller = MonoSidebarController();
    addTearDown(controller.dispose);
    var pageTaps = 0;

    await tester.pumpWidget(
      _host(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 390,
            height: 600,
            child: MonoScreen(
              sidebarController: controller,
              sidebar: const MonoSidebar(child: Text('Sidebar')),
              body: MonoButton(
                onPressed: () => pageTaps++,
                child: const Text('Page action'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Page action'));
    await tester.pump();
    expect(pageTaps, 1, reason: 'page is live while the sidebar is closed');

    controller.open();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The page is translated aside, so tap the sliver of it still on screen
    // rather than the button's original slot. The barrier takes the tap and
    // closes; the button underneath must never see it.
    await tester.tapAt(const Offset(370, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(pageTaps, 1, reason: 'page must not take taps behind the sidebar');
    expect(controller.isOpen, isFalse, reason: 'tapping the page dismisses');
  });

  testWidgets('compact screen paints an opaque page over the concealed sidebar', (
    tester,
  ) async {
    final controller = MonoSidebarController();
    addTearDown(controller.dispose);
    final theme = MonokitThemeData.light();

    await tester.pumpWidget(
      _host(
        theme: theme,
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 390,
            height: 600,
            child: MonoScreen(
              sidebarController: controller,
              sidebar: MonoSidebar(child: const Text('Destination')),
              body: const Text('Page body'),
            ),
          ),
        ),
      ),
    );

    // The closed push-inset sidebar is painted behind the page, so the page
    // must sit on an opaque background that conceals it (rather than letting it
    // show through). The background box wraps the body only in this compact
    // path — the pinned/rail layouts lay the sidebar out beside the page.
    expect(
      find.ancestor(
        of: find.text('Page body'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox && widget.color == theme.colors.background,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('screen owns page slots and dialog opens in WidgetsApp overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: MonoScreen(
          header: const MonoScreenHeader(title: Text('Header')),
          footer: const MonoScreenFooter(child: Text('Footer')),
          body: Center(
            child: MonoDialog(
              trigger: const Text('Open dialog'),
              child: const MonoDialogContent(child: Text('Dialog body')),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog body'), findsOneWidget);
  });

  testWidgets('controlled dialogs synchronize overlays after parent rebuilds', (
    tester,
  ) async {
    late StateSetter rebuild;
    var open = true;
    var title = 'Initial dialog';

    await tester.pumpWidget(
      MonokitApp(
        theme: MonokitThemeData.light(),
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return MonoDialog(
              open: open,
              child: MonoDialogContent(child: Text(title)),
            );
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Initial dialog'), findsOneWidget);

    rebuild(() => title = 'Updated dialog');
    await tester.pump();
    await tester.pump();

    expect(find.text('Updated dialog'), findsOneWidget);
    expect(tester.takeException(), isNull);

    rebuild(() => open = false);
    await tester.pump();
    await tester.pumpAndSettle(); // waits for the dialog's exit animation
    expect(find.text('Updated dialog'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
