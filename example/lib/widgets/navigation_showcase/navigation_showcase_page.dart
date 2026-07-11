import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';

/// Live reference for navigation, selection, and disclosure components.
class NavigationShowcasePage extends StatelessWidget {
  const NavigationShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Navigation and disclosure',
          description:
              'Route navigation is named and animated by MonokitApp. The widgets below handle local selection, document hierarchy, and expandable content.',
        ),
        DocSection(
          name: 'MonoNavigationMenu · MonoNavigationMenuItem',
          description:
              'A roving-focus menu for application-level or local destinations. The DocsShell sidebar is the vertical pill variant; this is a horizontal line menu.',
          code: '''MonoNavigationMenu(
  defaultValue: 'overview',
  variant: MonoNavigationMenuVariant.line,
  items: [...],
)''',
          child: MonoNavigationMenu(
            defaultValue: 'overview',
            variant: MonoNavigationMenuVariant.line,
            items: <MonoNavigationMenuItem>[
              MonoNavigationMenuItem.text(value: 'overview', label: 'Overview'),
              MonoNavigationMenuItem.text(value: 'api', label: 'API'),
              MonoNavigationMenuItem.text(value: 'examples', label: 'Examples'),
            ],
          ),
        ),
        DocSection(
          name: 'MonoBreadcrumb · Item · Link · Page · Separator · Ellipsis',
          description:
              'Use semantic breadcrumb slots to describe deep documentation paths without relying on a Material breadcrumb widget.',
          child: MonoBreadcrumb(
            separator: const MonoBreadcrumbSeparator(child: Text('›')),
            children: <Widget>[
              MonoBreadcrumbLink(onPressed: () {}, child: const Text('Docs')),
              const MonoBreadcrumbItem(child: Text('Components')),
              const MonoBreadcrumbEllipsis(),
              const MonoBreadcrumbItem(child: Text('Navigation')),
              const MonoBreadcrumbPage(child: Text('Tabs')),
            ],
          ),
        ),
        DocSection(
          name: 'MonoTabs · MonoTab · MonoTabsItem',
          description:
              'Tabs support controlled or uncontrolled values, horizontal or vertical orientation, and segmented or line treatments.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoTabs(
                defaultValue: 'preview',
                tabs: <MonoTab>[
                  MonoTab.text(
                    value: 'preview',
                    label: 'Preview',
                    icon: const MonoIcon(MonoIcons.sparkles),
                    content: const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Default segmented tabs keep content close to their triggers.',
                      ),
                    ),
                  ),
                  MonoTab.text(
                    value: 'code',
                    label: 'Code',
                    content: const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Each tab owns a unique value and accessible panel.',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.xl),
              SizedBox(
                width: 320,
                height: 150,
                child: MonoTabs(
                  defaultValue: 'first',
                  orientation: MonoTabsOrientation.vertical,
                  variant: MonoTabsVariant.line,
                  tabs: <MonoTab>[
                    MonoTab.text(
                      value: 'first',
                      label: 'Vertical',
                      content: const Text('Vertical line variant.'),
                    ),
                    MonoTab.text(
                      value: 'second',
                      label: 'Line',
                      content: const Text(
                        'Keyboard arrow navigation included.',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoAccordion · Item · Trigger · Content',
          description:
              'Use single or multiple expansion modes with slot-based triggers and content. These examples use the same compact disclosure grammar.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MonoAccordion(
                defaultValue: 'what',
                items: <MonoAccordionItem>[
                  MonoAccordionItem(
                    value: 'what',
                    trigger: const MonoAccordionTrigger(
                      child: Text('What makes Monokit widgets-first?'),
                    ),
                    content: const MonoAccordionContent(
                      child: Text(
                        'The core library is built on flutter/widgets.dart and carries its own tokens and interaction primitives.',
                      ),
                    ),
                  ),
                  MonoAccordionItem(
                    value: 'theme',
                    trigger: const MonoAccordionTrigger(
                      child: Text('How does theme switching work?'),
                    ),
                    content: const MonoAccordionContent(
                      child: Text(
                        'Rebuild MonokitApp with a new MonokitThemeData or use system brightness.',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: theme.spacing.lg),
              MonoAccordion(
                type: MonoAccordionType.multiple,
                defaultValues: const <String>{'tokens'},
                items: <MonoAccordionItem>[
                  MonoAccordionItem(
                    value: 'tokens',
                    trigger: const MonoAccordionTrigger(
                      child: Text('Semantic tokens'),
                    ),
                    content: const MonoAccordionContent(
                      child: Text(
                        'Colors, typography, radii, spacing, and motion.',
                      ),
                    ),
                  ),
                  MonoAccordionItem(
                    value: 'states',
                    trigger: const MonoAccordionTrigger(
                      child: Text('Interaction states'),
                    ),
                    content: const MonoAccordionContent(
                      child: Text(
                        'Hover, focus, press, disabled, selected, and more.',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoPagination · MonoPaginationLink · MonoPaginationEllipsis',
          description:
              'Pagination generates accessible page controls and omission markers from total pages, sibling count, and boundary count.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoPagination(
                totalPages: 24,
                defaultPage: 12,
                siblingCount: 1,
                boundaryCount: 1,
                showFirstLast: true,
              ),
              SizedBox(height: theme.spacing.lg),
              Wrap(
                spacing: theme.spacing.xs,
                children: <Widget>[
                  MonoPaginationLink(onPressed: () {}, child: const Text('1')),
                  const MonoPaginationEllipsis(),
                  MonoPaginationLink(
                    selected: true,
                    onPressed: () {},
                    child: const Text('8'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DocSection(
          name: 'MonoSidebarController · MonoSidebarReveal',
          description:
              'The documentation shell uses a controller-driven sidebar. On compact screens its push-inset reveal preserves page layout while the sidebar appears below the composite.',
          child: Text(
            'Open the menu icon in the header to exercise MonoSidebarTrigger and the responsive reveal.',
          ),
        ),
      ],
    );
  }
}
