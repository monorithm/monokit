import 'package:monokit_ui/monokit_ui.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Navigation',
          title: 'Getting around',
          tagline:
              'Bottom nav, tabs, accordions, menus, breadcrumbs, and pagination '
              '— the wayfinding surfaces, each adapting to the space it is given.',
          child: const _NavHero(),
        ),
        const SectionDivider(),
        const StageBlock(
          title: 'A navigation shell that adapts',
          description:
              'A side rail with content on wide viewports; a top bar plus bottom '
              'nav on compact — the same destinations, re-placed for the device.',
          stageHeight: 460,
          child: _NavShellDemo(),
        ),
        const SectionDivider(),
        const ComponentSection(
          title: 'Bottom nav',
          widgetName: 'MonoBottomNav',
          child: _BottomNavDemo(),
        ),
        const ComponentSection(
          title: 'Bottom nav — labelled, over media',
          widgetName: 'MonoBottomNav',
          description:
              'showLabels puts each destination\'s name under its icon at the '
              'label floor; onMedia composes the bar over the canvas in mist '
              'with the on-media inks.',
          code:
              'MonoBottomNav(showLabels: true, onMedia: true, items: …, '
              'selectedIndex: 0, onSelected: …)',
          child: _LabelledBottomNavDemo(),
        ),
        ComponentSection(
          title: 'Tabs',
          widgetName: 'MonoTabs',
          child: MonoTabs(
            defaultValue: 'active',
            tabs: <MonoTab>[
              MonoTab(
                value: 'active',
                label: const Text('Active'),
                content: _tabBody(context, 'Two posts reaching people nearby.'),
              ),
              MonoTab(
                value: 'reserved',
                label: const Text('Reserved'),
                content: _tabBody(context, 'One buyer is deciding.'),
              ),
              MonoTab(
                value: 'sold',
                label: const Text('Sold'),
                content: _tabBody(context, 'Five items fulfilled this month.'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Accordion',
          widgetName: 'MonoAccordion',
          child: MonoAccordion(
            items: <MonoAccordionItem>[
              MonoAccordionItem(
                value: 'reach',
                title: const Text('How does reach work?'),
                content: _accordionBody(
                  context,
                  'Your post is routed to the most relevant nearby people — no '
                  'followers required.',
                ),
              ),
              MonoAccordionItem(
                value: 'contact',
                title: const Text('When is my number shared?'),
                content: _accordionBody(
                  context,
                  'Never automatically. You confirm exactly what is shared.',
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Navigation menu',
          widgetName: 'MonoNavigationMenu',
          child: MonoNavigationMenu(
            defaultValue: 'feed',
            onChanged: (_) {},
            items: <MonoNavigationMenuItem>[
              MonoNavigationMenuItem.text(value: 'feed', label: 'For you'),
              MonoNavigationMenuItem.text(value: 'nearby', label: 'Nearby'),
              MonoNavigationMenuItem.text(value: 'saved', label: 'Saved'),
            ],
          ),
        ),
        ComponentSection(
          title: 'Breadcrumb',
          widgetName: 'MonoBreadcrumb',
          child: MonoBreadcrumb(
            children: <Widget>[
              MonoBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
              const MonoBreadcrumbSeparator(),
              MonoBreadcrumbLink(onPressed: () {}, child: const Text('Phones')),
              const MonoBreadcrumbSeparator(),
              const MonoBreadcrumbPage(child: Text('iPhone 13')),
            ],
          ),
        ),
        ComponentSection(
          title: 'Pagination',
          widgetName: 'MonoPagination',
          child: MonoPagination(
            totalPages: 8,
            defaultPage: 3,
            onChanged: (_) {},
          ),
        ),
        ComponentSection(
          title: 'Card — slot composition',
          widgetName: 'MonoCard',
          child: SizedBox(
            width: 340,
            child: MonoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  MonoCardHeader(
                    title: const Text('Order #A1B2C3'),
                    description: const Text('2 items · Nima'),
                    action: MonoBadge(
                      variant: MonoBadgeVariant.info,
                      child: const Text('Processing'),
                    ),
                  ),
                  const MonoCardContent(
                    child: Text('Estimated handoff today, 6:30pm.'),
                  ),
                  MonoCardFooter(
                    child: MonoButton(
                      variant: MonoButtonVariant.tinted,
                      size: MonoButtonSize.sm,
                      onPressed: () {},
                      child: const Text('Track'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabBody(BuildContext context, String text) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: theme.spacing.md),
      child: Text(text, style: theme.typography.bodyMedium),
    );
  }

  Widget _accordionBody(BuildContext context, String text) {
    final theme = MonokitTheme.of(context);
    return Text(
      text,
      style: theme.typography.bodyMedium.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
}

/// A composed wayfinding header for the hero.
class _NavHero extends StatelessWidget {
  const _NavHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MonoBreadcrumb(
          children: <Widget>[
            MonoBreadcrumbLink(onPressed: () {}, child: const Text('Home')),
            const MonoBreadcrumbSeparator(),
            MonoBreadcrumbLink(
              onPressed: () {},
              child: const Text('Furniture'),
            ),
            const MonoBreadcrumbSeparator(),
            const MonoBreadcrumbPage(child: Text('Chairs')),
          ],
        ),
        SizedBox(height: theme.spacing.lg),
        MonoNavigationMenu(
          defaultValue: 'feed',
          onChanged: (_) {},
          items: <MonoNavigationMenuItem>[
            MonoNavigationMenuItem.text(value: 'feed', label: 'For you'),
            MonoNavigationMenuItem.text(value: 'nearby', label: 'Nearby'),
            MonoNavigationMenuItem.text(value: 'saved', label: 'Saved'),
          ],
        ),
      ],
    );
  }
}

/// A list/detail shell that becomes a side rail on wide viewports and a top-bar
/// + bottom-nav layout on compact — the headline navigation reflow.
class _NavShellDemo extends StatefulWidget {
  const _NavShellDemo();

  @override
  State<_NavShellDemo> createState() => _NavShellDemoState();
}

class _NavShellDemoState extends State<_NavShellDemo> {
  int _selected = 0;

  static const List<(MonoIconData, String)> _dests = <(MonoIconData, String)>[
    (MonoIcons.grid, 'For you'),
    (MonoIcons.location, 'Nearby'),
    (MonoIcons.bookmark, 'Saved'),
    (MonoIcons.message, 'Inbox'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final content = _Content(label: _dests[_selected].$2);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= theme.breakpoints.medium;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 200,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: theme.colors.border),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (var i = 0; i < _dests.length; i++)
                          Padding(
                            padding: EdgeInsets.only(bottom: theme.spacing.xs),
                            child: MonoButton(
                              variant: i == _selected
                                  ? MonoButtonVariant.secondary
                                  : MonoButtonVariant.ghost,
                              size: MonoButtonSize.sm,
                              onPressed: () => setState(() => _selected = i),
                              leading: MonoIcon(_dests[i].$1, size: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(_dests[i].$2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.colors.border)),
              ),
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.md),
                child: Row(
                  children: <Widget>[
                    const MonoIcon(MonoIcons.menu, size: 18),
                    SizedBox(width: theme.spacing.sm),
                    Text(
                      _dests[_selected].$2,
                      style: theme.typography.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: content),
            MonoBottomNav(
              selectedIndex: _selected,
              onSelected: (i) => setState(() => _selected = i),
              items: <MonoBottomNavItem>[
                for (final (icon, label) in _dests)
                  MonoBottomNavItem(icon: icon, label: label),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: theme.typography.titleLarge),
          SizedBox(height: theme.spacing.sm),
          Text(
            'The $label destination. On wide viewports this sits beside a side '
            'rail; on compact it fills the screen with a bottom nav below.',
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavDemo extends StatefulWidget {
  const _BottomNavDemo();

  @override
  State<_BottomNavDemo> createState() => _BottomNavDemoState();
}

class _BottomNavDemoState extends State<_BottomNavDemo> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      width: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MonoBottomNav(
            items: const <MonoBottomNavItem>[
              MonoBottomNavItem(icon: MonoIcons.add, label: 'Create'),
              MonoBottomNavItem(icon: MonoIcons.play, label: 'Play'),
              MonoBottomNavItem(icon: MonoIcons.search, label: 'Search'),
              MonoBottomNavItem(icon: MonoIcons.message, label: 'Message'),
              MonoBottomNavItem(icon: MonoIcons.user, label: 'Account'),
            ],
            selectedIndex: _selected,
            onSelected: (index) => setState(() => _selected = index),
          ),
          Padding(
            padding: EdgeInsets.only(top: theme.spacing.sm),
            child: Text(
              'Icon-only, controlled by the host; every tap reports its '
              'index — including re-taps of the selected destination.',
              style: theme.typography.bodyMedium.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelledBottomNavDemo extends StatefulWidget {
  const _LabelledBottomNavDemo();

  @override
  State<_LabelledBottomNavDemo> createState() => _LabelledBottomNavDemoState();
}

class _LabelledBottomNavDemoState extends State<_LabelledBottomNavDemo> {
  int _selected = 0;
  static const _items = <MonoBottomNavItem>[
    MonoBottomNavItem(icon: MonoIcons.store, label: 'Market'),
    MonoBottomNavItem(icon: MonoIcons.search, label: 'Search'),
    MonoBottomNavItem(icon: MonoIcons.camera, label: 'Sell'),
    MonoBottomNavItem(icon: MonoIcons.call, label: 'Callbacks'),
    MonoBottomNavItem(icon: MonoIcons.user, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MonoBottomNav(
            items: _items,
            selectedIndex: _selected,
            onSelected: (i) => setState(() => _selected = i),
            showLabels: true,
          ),
          SizedBox(height: theme.spacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.lg),
            child: ColoredBox(
              color: theme.colors.mediaCanvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 72,
                    child: AppImage(
                      asset: AppAssets.live,
                      seed: 'nav-media',
                      onMediaCanvas: true,
                    ),
                  ),
                  MonoBottomNav(
                    items: _items,
                    selectedIndex: _selected,
                    onSelected: (i) => setState(() => _selected = i),
                    showLabels: true,
                    onMedia: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
