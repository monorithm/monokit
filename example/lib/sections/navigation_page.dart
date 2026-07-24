import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        const ComponentSection(
          title: 'Bottom nav',
          widgetName: 'MonoBottomNav',
          child: _BottomNavDemo(),
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
                      variant: MonoButtonVariant.outline,
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
