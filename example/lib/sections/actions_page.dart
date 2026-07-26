import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Actions',
          title: 'Buttons & badges',
          tagline:
              'Six button variants across the size ramp, honest status badges, '
              'and keyboard hints — every state live, never faked.',
          child: const _ActionHero(),
        ),
        const SectionDivider(),
        StageBlock(
          title: 'An action bar, across breakpoints',
          description:
              'Labels ride alongside icons when there is room and collapse to '
              'icon-only controls on compact — drag the stage to watch it.',
          stageHeight: 160,
          child: const _ActionBarDemo(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Every button variant × size',
          widgetName: 'MonoButton',
          description:
              'Six variants across the size ramp. On touch, every size meets the '
              '48dp minimum tap target, so sm/md/lg share a height — they differ '
              'in horizontal padding and glyph size. On pointer devices the '
              'heights separate.',
          code:
              "MonoButton(\n  variant: MonoButtonVariant.primary,\n  size: MonoButtonSize.md,\n  onPressed: () {},\n  child: const Text('Register interest'),\n)",
          child: VariantMatrix<MonoButtonVariant, MonoButtonSize>(
            rows: MonoButtonVariant.values,
            cols: const <MonoButtonSize>[
              MonoButtonSize.sm,
              MonoButtonSize.md,
              MonoButtonSize.lg,
            ],
            rowLabel: (v) => v.name,
            builder: (v, s) => MonoButton(
              variant: v,
              size: s,
              onPressed: () {},
              child: const Text('Post'),
            ),
          ),
        ),
        ComponentSection(
          title: 'States',
          widgetName: 'MonoButton',
          description:
              'Disabled and loading are declarative; hover / focus / press are '
              'live — interact to see them.',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.md,
            children: <Widget>[
              DemoTile(
                label: 'default',
                child: MonoButton(onPressed: () {}, child: const Text('Save')),
              ),
              const DemoTile(
                label: 'disabled',
                child: MonoButton(child: Text('Save')),
              ),
              const DemoTile(
                label: 'loading',
                child: MonoButton(isLoading: true, child: Text('Save')),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Icons & icon buttons',
          widgetName: 'MonoButton.icon',
          code:
              "MonoButton.icon(\n  icon: const MonoIcon(MonoIcons.add),\n  label: const Text('New post'),\n  onPressed: () {},\n)",
          child: Wrap(
            spacing: theme.spacing.md,
            runSpacing: theme.spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              MonoButton.icon(
                icon: const MonoIcon(MonoIcons.add),
                label: const Text('New post'),
                onPressed: () {},
              ),
              MonoButton(
                variant: MonoButtonVariant.outline,
                leading: const MonoIcon(MonoIcons.search, size: 16),
                onPressed: () {},
                child: const Text('Search'),
              ),
              MonoButton(
                variant: MonoButtonVariant.secondary,
                size: MonoButtonSize.icon,
                onPressed: () {},
                child: const MonoIcon(MonoIcons.more),
              ),
              MonoButton(
                variant: MonoButtonVariant.ghost,
                size: MonoButtonSize.icon,
                onPressed: () {},
                child: const MonoIcon(MonoIcons.like),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Badges',
          widgetName: 'MonoBadge',
          description: 'Status vocabulary + the sacred live badge.',
          code:
              "MonoBadge(variant: MonoBadgeVariant.success, child: Text('Available'))",
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: <Widget>[
              for (final v in MonoBadgeVariant.values)
                MonoBadge(variant: v, child: Text(v.name)),
              const MonoBadge(dot: true, child: Text('3 nearby')),
            ],
          ),
        ),
        ComponentSection(
          title: 'Keyboard shortcut',
          widgetName: 'MonoKbd',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const MonoKbd(child: Text('⌘')),
              SizedBox(width: theme.spacing.xs),
              const MonoKbd(child: Text('K')),
              SizedBox(width: theme.spacing.sm),
              Text('to search', style: theme.typography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

/// A composed toolbar shown in the hero — the family working together rather
/// than isolated on a matrix.
class _ActionHero extends StatelessWidget {
  const _ActionHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Listing draft', style: theme.typography.titleMedium),
            ),
            const MonoBadge(
              variant: MonoBadgeVariant.warning,
              child: Text('Unsaved'),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.lg),
        Wrap(
          spacing: theme.spacing.md,
          runSpacing: theme.spacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            MonoButton(
              onPressed: () {},
              leading: const MonoIcon(MonoIcons.check, size: 16),
              child: const Text('Publish'),
            ),
            MonoButton(
              variant: MonoButtonVariant.outline,
              onPressed: () {},
              child: const Text('Save draft'),
            ),
            MonoButton(
              variant: MonoButtonVariant.ghost,
              onPressed: () {},
              leading: const MonoIcon(MonoIcons.image, size: 16),
              child: const Text('Add photos'),
            ),
            MonoButton(
              variant: MonoButtonVariant.destructive,
              onPressed: () {},
              child: const Text('Discard'),
            ),
            const MonoBadge(dot: true, child: Text('3 drafts')),
          ],
        ),
      ],
    );
  }
}

/// A toolbar that shows labelled buttons when wide and collapses to icon-only
/// buttons on compact — a concrete reflow to demonstrate on the stage.
class _ActionBarDemo extends StatelessWidget {
  const _ActionBarDemo();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < theme.breakpoints.compact;
        return Padding(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.card,
                  borderRadius: BorderRadius.circular(theme.radii.lg),
                  border: Border.all(color: theme.colors.border),
                ),
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.sm),
                  child: Row(
                    children: <Widget>[
                      _BarAction(
                        icon: MonoIcons.image,
                        label: 'Photos',
                        compact: compact,
                        variant: MonoButtonVariant.ghost,
                      ),
                      _BarAction(
                        icon: MonoIcons.location,
                        label: 'Location',
                        compact: compact,
                        variant: MonoButtonVariant.ghost,
                      ),
                      _BarAction(
                        icon: MonoIcons.filter,
                        label: 'Details',
                        compact: compact,
                        variant: MonoButtonVariant.ghost,
                      ),
                      const Spacer(),
                      _BarAction(
                        icon: MonoIcons.send,
                        label: 'Publish',
                        compact: compact,
                        variant: MonoButtonVariant.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BarAction extends StatelessWidget {
  const _BarAction({
    required this.icon,
    required this.label,
    required this.compact,
    required this.variant,
  });

  final MonoIconData icon;
  final String label;
  final bool compact;
  final MonoButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(right: theme.spacing.xs),
      child: compact
          ? MonoButton(
              variant: variant,
              size: MonoButtonSize.iconSm,
              semanticLabel: label,
              onPressed: () {},
              child: MonoIcon(icon, size: 16),
            )
          : IntrinsicWidth(
              child: MonoButton(
                variant: variant,
                size: MonoButtonSize.sm,
                onPressed: () {},
                leading: MonoIcon(icon, size: 16),
                child: Text(label),
              ),
            ),
    );
  }
}
