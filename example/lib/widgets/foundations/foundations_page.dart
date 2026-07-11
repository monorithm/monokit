import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';

/// Documents the responsive application shell and core visual primitives.
class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'App shell and foundations',
          description:
              'The documentation app itself is a MonoScreen. This page makes its layout contracts, chrome, sidebar, backdrop, and icon primitives visible.',
        ),
        DocSection(
          name: 'MonoScreen · MonoScreenScope · MonoSafeArea · MonoInsetPolicy',
          description:
              'MonoScreen provides canvas, chrome, body, floating, and screen-owned overlay layers. Safe areas and body insets are resolved once for descendants.',
          code: '''MonoScreen(
  header: MonoScreenHeader(...),
  sidebar: MonoSidebar(...),
  safeArea: const MonoSafeArea.all(),
  insetPolicy: const MonoInsetPolicy(),
  body: ...,
)''',
          child: Builder(
            builder: (screenContext) {
              final screen = MonoScreen.of(screenContext);
              return Wrap(
                spacing: theme.spacing.sm,
                runSpacing: theme.spacing.sm,
                children: <Widget>[
                  MonoBadge(child: Text('Compact: ${screen.isCompact}')),
                  MonoBadge(
                    variant: MonoBadgeVariant.secondary,
                    child: Text('Sidebar: ${screen.sidebarReveal.name}'),
                  ),
                  MonoBadge(
                    variant: MonoBadgeVariant.outline,
                    child: Text(
                      'Insets: ${screen.resolvedBodyInsets.left.round()}, '
                      '${screen.resolvedBodyInsets.top.round()}, '
                      '${screen.resolvedBodyInsets.right.round()}, '
                      '${screen.resolvedBodyInsets.bottom.round()}',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        DocSection(
          name:
              'MonoScreenHeader · MonoScreenFooter · MonoSidebar · MonoSidebarTrigger',
          description:
              'Every route shares these widgets through DocsShell. The leading menu icon is a MonoSidebarTrigger; use it on compact widths to reveal the push-inset sidebar.',
          child: MonoCard(
            background: theme.colors.background,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const MonoScreenHeader(
                  leading: MonoIcon(MonoIcons.menu),
                  title: Text('Header slot'),
                  trailing: MonoBadge(child: Text('Trailing slot')),
                ),
                const MonoSeparator(),
                Padding(
                  padding: EdgeInsets.all(theme.spacing.lg),
                  child: Text(
                    'This is a miniature chrome composition. The real header, footer, and responsive sidebar frame the current route.',
                  ),
                ),
                const MonoScreenFooter(child: Text('Footer slot')),
              ],
            ),
          ),
        ),
        const DocSection(
          name: 'Automatic application scopes',
          description:
              'MonokitTheme, MonoScreenScope, and MonoSidebarScope are '
              'installed by MonokitApp, MonoScreen, and MonoSidebar. Read '
              'them through their of or maybeOf helpers; they are context '
              'providers rather than standalone visual widgets.',
          child: Text(
            'DocsShell uses all three scopes to resolve tokens, responsive '
            'screen state, and the sidebar controller for every route.',
          ),
        ),
        DocSection(
          name: 'MonoBackdrop · MonoScreenMotion',
          description:
              'Use a backdrop on the canvas layer and derive coordinated chrome, sidebar, overlay, and inset timing from MonokitMotion.',
          child: SizedBox(
            height: 132,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radii.lg),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const MonoBackdrop.gradient(
                    colors: <Color>[Color(0xFF18181B), Color(0xFF52525B)],
                  ),
                  Center(
                    child: DefaultTextStyle.merge(
                      style: theme.typography.titleLarge.copyWith(
                        color: theme.colors.primaryForeground,
                      ),
                      child: Text(
                        'Sidebar / chrome / overlay motion: '
                        '${MonoScreenMotion.fromTokens(theme.motion).sidebarDuration.inMilliseconds}ms',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DocSection(
          name: 'MonoIcon · MonoIconData · MonoIcons',
          description:
              'Monokit ships a dependency-free glyph catalog and accepts custom MonoIconData for product-specific symbols.',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const <Widget>[
              _IconDoc(icon: MonoIcons.add, label: 'add'),
              _IconDoc(icon: MonoIcons.sparkles, label: 'sparkles'),
              _IconDoc(icon: MonoIcons.search, label: 'search'),
              _IconDoc(icon: MonoIcons.menu, label: 'menu'),
              _IconDoc(
                icon: MonoIconData('★', semanticLabel: 'Star'),
                label: 'custom',
              ),
            ],
          ),
        ),
        DocSection(
          name: 'Responsive behavior contract',
          description:
              'MonoInsetMode, MonoHeaderBehavior, MonoFooterBehavior, MonoSidebarReveal, and MonoSidebarController express the shell’s adaptive choices. The built-in documentation sidebar demonstrates the current reveal mode.',
          child: const MonoAlert(
            title: Text('Desktop, web, mobile, and accessibility'),
            description: Text(
              'Use semantic tokens, safe-area policy, and a single screen layout authority instead of Material Scaffold assumptions.',
            ),
          ),
        ),
      ],
    );
  }
}

class _IconDoc extends StatelessWidget {
  const _IconDoc({required this.icon, required this.label});

  final MonoIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MonoIcon(icon, size: 24),
        SizedBox(height: theme.spacing.xs),
        Text(label, style: theme.typography.labelMedium),
      ],
    );
  }
}
