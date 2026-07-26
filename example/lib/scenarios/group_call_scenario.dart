import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

class _Participant {
  const _Participant(this.initials, this.name, this.muted);
  final String initials;
  final String name;
  final bool muted;
}

const List<_Participant> _people = <_Participant>[
  _Participant('EA', 'Esi', false),
  _Participant('AB', 'Abbas', true),
  _Participant('YB', 'Yaa', false),
  _Participant('KA', 'Kofi', false),
  _Participant('NA', 'Nana', true),
  _Participant('MG', 'You', false),
];

class GroupCallScenario extends StatelessWidget {
  const GroupCallScenario({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: theme.colors.mediaCanvas,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.md,
              media.padding.top + theme.spacing.sm,
              theme.spacing.md,
              theme.spacing.sm,
            ),
            child: Row(
              children: <Widget>[
                MonoButton(
                  variant: MonoButtonVariant.ghost,
                  size: MonoButtonSize.iconSm,
                  semanticLabel: 'Back',
                  onPressed: () => context.go('/scenarios'),
                  child: MonoIcon(
                    MonoIcons.chevronLeft,
                    color: theme.colors.onMedia,
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                Expanded(
                  child: Text(
                    'Team standup',
                    style: theme.typography.titleMedium.copyWith(
                      color: theme.colors.onMedia,
                    ),
                  ),
                ),
                const MonoLiveBadge(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 520 ? 2 : 3;
                  final gap = theme.spacing.md;
                  final tileW =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: <Widget>[
                        for (final p in _people)
                          SizedBox(
                            width: tileW,
                            height: tileW * 0.9,
                            child: _Tile(participant: p),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.md,
              theme.spacing.md,
              theme.spacing.md,
              media.padding.bottom + theme.spacing.lg,
            ),
            child: MonoCallControls(
              children: <Widget>[
                MonoButton(
                  variant: MonoButtonVariant.secondary,
                  size: MonoButtonSize.icon,
                  semanticLabel: 'Mute',
                  onPressed: () {},
                  child: const MonoIcon(MonoIcons.mic),
                ),
                MonoButton(
                  variant: MonoButtonVariant.secondary,
                  size: MonoButtonSize.icon,
                  semanticLabel: 'Camera',
                  onPressed: () {},
                  child: const MonoIcon(MonoIcons.video),
                ),
                MonoButton(
                  variant: MonoButtonVariant.secondary,
                  size: MonoButtonSize.icon,
                  semanticLabel: 'Share',
                  onPressed: () {},
                  child: const MonoIcon(MonoIcons.send),
                ),
                MonoButton(
                  variant: MonoButtonVariant.destructive,
                  size: MonoButtonSize.icon,
                  semanticLabel: 'Leave call',
                  onPressed: () => context.go('/scenarios'),
                  child: const MonoIcon(MonoIcons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.participant});
  final _Participant participant;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.circular(theme.radii.lg),
        border: Border.all(color: theme.colors.glassBorder),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: MonoAvatar.initials(
              participant.initials,
              size: MonoAvatarSize.lg,
            ),
          ),
          Positioned(
            left: theme.spacing.sm,
            bottom: theme.spacing.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  participant.name,
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.onMedia,
                  ),
                ),
              ],
            ),
          ),
          if (participant.muted)
            Positioned(
              right: theme.spacing.sm,
              top: theme.spacing.sm,
              child: MonoIcon(
                MonoIcons.mute,
                size: 16,
                color: theme.colors.onMediaMuted,
              ),
            ),
        ],
      ),
    );
  }
}
