import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        ComponentSection(
          title: 'Every button variant × size',
          widgetName: 'MonoButton',
          description:
              'Six variants across the size ramp. Destructive is soft.',
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
