import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

/// Display surfaces: avatars, cards, separators, and the loading family
/// (skeletons, spinners, progress).
class DataDisplayPage extends StatelessWidget {
  const DataDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Data display',
          title: 'Presenting content',
          tagline:
              'Avatars, cards, separators, and the loading family — the surfaces '
              'that carry content, from a filled profile to its skeleton.',
          child: const _ProfileHero(),
        ),
        const SectionDivider(),
        StageBlock(
          title: 'A card grid that reflows',
          description:
              'Stat cards pack from one column to four as the viewport grows.',
          stageHeight: 360,
          child: const _StatGrid(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Avatars',
          widgetName: 'MonoAvatar',
          description: 'Sizes, shapes, and initials fallback.',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.lg,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: const <Widget>[
              DemoTile(
                label: 'xs',
                child: MonoAvatar.initials('AB', size: MonoAvatarSize.xs),
              ),
              DemoTile(
                label: 'sm',
                child: MonoAvatar.initials('EA', size: MonoAvatarSize.sm),
              ),
              DemoTile(
                label: 'md',
                child: MonoAvatar.initials('YB', size: MonoAvatarSize.md),
              ),
              DemoTile(
                label: 'lg',
                child: MonoAvatar.initials('KA', size: MonoAvatarSize.lg),
              ),
              DemoTile(
                label: 'rounded',
                child: MonoAvatar.initials(
                  'NA',
                  size: MonoAvatarSize.lg,
                  shape: MonoAvatarShape.rounded,
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Avatar group',
          widgetName: 'MonoAvatar',
          description: 'Overlapping stack — a common "who is here" pattern.',
          child: const _AvatarGroup(),
        ),
        ComponentSection(
          title: 'Separators',
          widgetName: 'MonoSeparator',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Above', style: theme.typography.bodyMedium),
              Padding(
                padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
                child: const MonoSeparator(),
              ),
              Text('Below', style: theme.typography.bodyMedium),
            ],
          ),
        ),
        ComponentSection(
          title: 'Loading — skeleton, spinner, progress',
          widgetName: 'MonoSkeleton',
          description: 'The same card, filled and loading.',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(child: _FilledMini()),
              SizedBox(width: theme.spacing.lg),
              const Expanded(child: _SkeletonMini()),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: Text(
                'Esi Addo',
                overflow: TextOverflow.ellipsis,
                style: theme.typography.titleLarge,
              ),
            ),
            SizedBox(width: theme.spacing.sm),
            const MonoBadge(
              variant: MonoBadgeVariant.success,
              child: Text('Verified'),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.xs),
        Text(
          'Accra · 4.9 ★ · 128 items sold',
          style: theme.typography.bodyMedium.copyWith(
            color: theme.colors.foregroundMuted,
          ),
        ),
      ],
    );
    final follow = MonoButton(
      variant: MonoButtonVariant.tinted,
      size: MonoButtonSize.sm,
      onPressed: () {},
      child: const Text('Follow'),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < theme.breakpoints.compact;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const MonoAvatar.initials('EA', size: MonoAvatarSize.lg),
                  SizedBox(width: theme.spacing.md),
                  Expanded(child: identity),
                ],
              ),
              SizedBox(height: theme.spacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(child: follow),
              ),
            ],
          );
        }
        return Row(
          children: <Widget>[
            const MonoAvatar.initials('EA', size: MonoAvatarSize.xl),
            SizedBox(width: theme.spacing.lg),
            Expanded(child: identity),
            SizedBox(width: theme.spacing.md),
            follow,
          ],
        );
      },
    );
  }
}

class _AvatarGroup extends StatelessWidget {
  const _AvatarGroup();

  static const List<String> _people = <String>['AB', 'EA', 'YB', 'KA'];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (var i = 0; i < _people.length; i++)
            Positioned(
              left: i * 26.0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colors.page, width: 2),
                ),
                child: MonoAvatar.initials(_people[i], size: MonoAvatarSize.sm),
              ),
            ),
          Positioned(
            left: _people.length * 26.0,
            top: 4,
            child: MonoBadge(
              variant: MonoBadgeVariant.secondary,
              child: Text('+12'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid();

  static const List<(MonoIconData, String, String)> _stats =
      <(MonoIconData, String, String)>[
        (MonoIcons.bag, 'Revenue', 'GH₵ 42,800'),
        (MonoIcons.receipt, 'Orders', '128'),
        (MonoIcons.user, 'Buyers', '96'),
        (MonoIcons.star, 'Rating', '4.9'),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bp = theme.breakpoints;
        final columns = w < bp.compact
            ? 1
            : w < bp.medium
            ? 2
            : 4;
        final gap = theme.spacing.md;
        final pad = theme.spacing.lg;
        final available = w - pad * 2;
        final tileWidth = (available - gap * (columns - 1)) / columns;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final (icon, label, value) in _stats)
                SizedBox(
                  width: tileWidth > 0 ? tileWidth : w,
                  child: MonoCard(
                    child: Padding(
                      padding: EdgeInsets.all(theme.spacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MonoIcon(icon, size: 18, color: theme.colors.primary),
                          SizedBox(height: theme.spacing.sm),
                          Text(
                            value,
                            style: theme.typography.tabular(
                              theme.typography.titleLarge,
                            ),
                          ),
                          Text(
                            label,
                            style: theme.typography.labelMedium.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ],
                      ),
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

class _FilledMini extends StatelessWidget {
  const _FilledMini();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoCard(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.lg),
        child: Row(
          children: <Widget>[
            const MonoAvatar.initials('YB', size: MonoAvatarSize.md),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Yaa Boateng', style: theme.typography.labelLarge),
                  Text(
                    'Replied 2m ago',
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonMini extends StatelessWidget {
  const _SkeletonMini();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoCard(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.lg),
        child: Row(
          children: <Widget>[
            const MonoSkeleton(
              width: 36,
              height: 36,
              shape: MonoSkeletonShape.circle,
            ),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  MonoSkeleton(width: 120, height: 14),
                  SizedBox(height: 8),
                  MonoSkeleton(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
