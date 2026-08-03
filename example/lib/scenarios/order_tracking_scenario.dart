import 'package:monokit_ui/monokit_ui.dart';

import 'scenario_kit.dart';

class _Stage {
  const _Stage(this.icon, this.title, this.time);
  final MonoIconData icon;
  final String title;
  final String time;
}

class OrderTrackingScenario extends StatelessWidget {
  const OrderTrackingScenario({super.key});

  static const int _current = 2;
  static const List<_Stage> _stages = <_Stage>[
    _Stage(MonoIcons.check, 'Order placed', '9:04'),
    _Stage(MonoIcons.receipt, 'Payment confirmed', '9:05'),
    _Stage(MonoIcons.bag, 'Packing', '9:22'),
    _Stage(MonoIcons.location, 'Out for delivery', '—'),
    _Stage(MonoIcons.check, 'Delivered', '—'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ScenarioShell(
      title: 'Order #A1B2C3',
      subtitle: '2 items · Nima',
      body: ListView(
        padding: EdgeInsets.all(theme.spacing.lg),
        children: <Widget>[
          MonoCard(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Arriving today',
                          style: theme.typography.titleMedium,
                        ),
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          'Estimated 6:30 – 7:00 pm',
                          style: theme.typography.bodyMedium.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const MonoBadge(
                    variant: MonoBadgeVariant.info,
                    child: Text('On the way'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: theme.spacing.xl),
          const ScenarioLabel('Progress'),
          for (var i = 0; i < _stages.length; i++)
            _StageRow(
              stage: _stages[i],
              done: i < _current,
              active: i == _current,
              last: i == _stages.length - 1,
            ),
          SizedBox(height: theme.spacing.xl),
          MonoCard(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Row(
                children: <Widget>[
                  const MonoAvatar.initials('KA'),
                  SizedBox(width: theme.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Kofi A. · courier',
                          style: theme.typography.labelLarge,
                        ),
                        Text(
                          '4.9 ★ · Yamaha',
                          style: theme.typography.labelMedium.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MonoButton(
                    variant: MonoButtonVariant.tinted,
                    size: MonoButtonSize.sm,
                    iconOnly: true,
                    semanticLabel: 'Call courier',
                    onPressed: () {},
                    child: const MonoIcon(MonoIcons.call),
                  ),
                  SizedBox(width: theme.spacing.xs),
                  MonoButton(
                    variant: MonoButtonVariant.tinted,
                    size: MonoButtonSize.sm,
                    iconOnly: true,
                    semanticLabel: 'Message courier',
                    onPressed: () {},
                    child: const MonoIcon(MonoIcons.message),
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

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.stage,
    required this.done,
    required this.active,
    required this.last,
  });

  final _Stage stage;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final reached = done || active;
    final dotColor = reached ? theme.colors.primary : theme.colors.fill;
    final fg = reached ? theme.colors.onPrimary : theme.colors.foregroundMuted;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: MonoIcon(stage.icon, size: 16, color: fg),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? theme.colors.primary : theme.colors.separator,
                  ),
                ),
            ],
          ),
          SizedBox(width: theme.spacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: theme.spacing.lg),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      stage.title,
                      style: active
                          ? theme.typography.labelLarge.copyWith(
                              color: theme.colors.primary,
                            )
                          : theme.typography.bodyMedium.copyWith(
                              color: reached
                                  ? theme.colors.foreground
                                  : theme.colors.foregroundMuted,
                            ),
                    ),
                  ),
                  Text(
                    stage.time,
                    style: theme.typography.mono.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
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
