import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

/// Metadata for a scenario destination.
class ScenarioMeta {
  const ScenarioMeta({
    required this.path,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String path;
  final String title;
  final String description;
  final MonoIconData icon;
}

const List<ScenarioMeta> scenarios = <ScenarioMeta>[
  ScenarioMeta(
    path: '/scenarios/storefront',
    title: 'Storefront',
    description: 'A browsable marketplace with a reflowing product grid.',
    icon: MonoIcons.bag,
  ),
  ScenarioMeta(
    path: '/scenarios/checkout',
    title: 'Checkout',
    description: 'Cart, delivery choice, and an honest order summary.',
    icon: MonoIcons.receipt,
  ),
  ScenarioMeta(
    path: '/scenarios/order-tracking',
    title: 'Order tracking',
    description: 'A live lifecycle timeline from paid to delivered.',
    icon: MonoIcons.location,
  ),
  ScenarioMeta(
    path: '/scenarios/conversation',
    title: 'Conversation',
    description: 'A full chat thread with composer and receipts.',
    icon: MonoIcons.message,
  ),
  ScenarioMeta(
    path: '/scenarios/live-studio',
    title: 'Live studio',
    description: 'An immersive live shopping surface with an action rail.',
    icon: MonoIcons.video,
  ),
  ScenarioMeta(
    path: '/scenarios/creator-studio',
    title: 'Creator studio',
    description: 'Post composer with extracted facts and publish states.',
    icon: MonoIcons.sparkles,
  ),
  ScenarioMeta(
    path: '/scenarios/team-workspace',
    title: 'Team workspace',
    description: 'A two-pane inbox that reflows to single-pane on compact.',
    icon: MonoIcons.grid,
  ),
  ScenarioMeta(
    path: '/scenarios/group-call',
    title: 'Group call',
    description: 'A participant grid with mist-on-media call controls.',
    icon: MonoIcons.call,
  ),
];

class ScenariosIndexPage extends StatelessWidget {
  const ScenariosIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        Text('Scenarios', style: theme.typography.displayMedium),
        SizedBox(height: theme.spacing.sm),
        SizedBox(
          width: 640,
          child: Text(
            'Full-fidelity product screens built entirely from Monokit. Open '
            'one, then pin Phone, Tablet, or Desktop in the header to see it '
            'framed like a real device.',
            style: theme.typography.bodyLarge.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ),
        SizedBox(height: theme.spacing.xxl),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < theme.breakpoints.compact
                ? 1
                : constraints.maxWidth < theme.breakpoints.expanded
                ? 2
                : 3;
            final gap = theme.spacing.lg;
            final tileWidth =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (final s in scenarios)
                  SizedBox(
                    width: tileWidth,
                    child: _ScenarioCard(meta: s),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({required this.meta});
  final ScenarioMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoCard(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(meta.path),
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colors.primarySoft,
                      borderRadius: BorderRadius.circular(theme.radii.md),
                    ),
                    child: MonoIcon(
                      meta.icon,
                      size: 18,
                      color: theme.colors.primary,
                    ),
                  ),
                  const Spacer(),
                  const MonoIcon(MonoIcons.arrowRight, size: 16),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              Text(meta.title, style: theme.typography.titleMedium),
              SizedBox(height: theme.spacing.xs),
              Text(
                meta.description,
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
