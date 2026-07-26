import 'package:monokit/monokit.dart';

import 'scenario_kit.dart';

class _Thread {
  const _Thread(this.initials, this.name, this.preview, this.time, this.unread);
  final String initials;
  final String name;
  final String preview;
  final String time;
  final bool unread;
}

const List<_Thread> _threads = <_Thread>[
  _Thread('EA', 'Esi Addo', 'Is the chair still available?', '2m', true),
  _Thread('AB', 'Abbas M.', 'Sent the receipt — thanks!', '18m', false),
  _Thread('YB', 'Yaa Boateng', 'Can you deliver to Labone?', '1h', true),
  _Thread('KA', 'Kofi A.', 'On my way, 10 mins out.', '3h', false),
];

class TeamWorkspaceScenario extends StatefulWidget {
  const TeamWorkspaceScenario({super.key});

  @override
  State<TeamWorkspaceScenario> createState() => _TeamWorkspaceScenarioState();
}

class _TeamWorkspaceScenarioState extends State<TeamWorkspaceScenario> {
  int _selected = 0;
  bool _detailOpen = false; // used only on compact

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ScenarioShell(
      title: 'Inbox',
      subtitle: '2 unread',
      showBack: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= theme.breakpoints.medium;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  width: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: theme.colors.border),
                      ),
                    ),
                    child: _ThreadList(
                      selected: _selected,
                      onSelect: (i) => setState(() => _selected = i),
                    ),
                  ),
                ),
                Expanded(child: _Detail(thread: _threads[_selected])),
              ],
            );
          }
          if (_detailOpen) {
            return _Detail(
              thread: _threads[_selected],
              onBack: () => setState(() => _detailOpen = false),
            );
          }
          return _ThreadList(
            selected: -1,
            onSelect: (i) => setState(() {
              _selected = i;
              _detailOpen = true;
            }),
          );
        },
      ),
    );
  }
}

class _ThreadList extends StatelessWidget {
  const _ThreadList({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView.builder(
      padding: EdgeInsets.all(theme.spacing.sm),
      itemCount: _threads.length,
      itemBuilder: (context, i) {
        final t = _threads[i];
        final active = i == selected;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelect(i),
          child: Container(
            margin: EdgeInsets.only(bottom: theme.spacing.xs),
            padding: EdgeInsets.all(theme.spacing.md),
            decoration: BoxDecoration(
              color: active ? theme.colors.secondary : null,
              borderRadius: BorderRadius.circular(theme.radii.md),
            ),
            child: Row(
              children: <Widget>[
                MonoAvatar.initials(t.initials),
                SizedBox(width: theme.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              t.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.labelLarge,
                            ),
                          ),
                          Text(
                            t.time,
                            style: theme.typography.labelMedium.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: theme.spacing.xs / 2),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              t.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.bodyMedium.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ),
                          if (t.unread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.thread, this.onBack});
  final _Thread thread;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(theme.spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.colors.border)),
          ),
          child: Row(
            children: <Widget>[
              if (onBack != null)
                Padding(
                  padding: EdgeInsets.only(right: theme.spacing.xs),
                  child: MonoButton(
                    variant: MonoButtonVariant.ghost,
                    size: MonoButtonSize.iconSm,
                    semanticLabel: 'Back to inbox',
                    onPressed: onBack,
                    child: const MonoIcon(MonoIcons.chevronLeft),
                  ),
                ),
              MonoAvatar.initials(thread.initials, size: MonoAvatarSize.sm),
              SizedBox(width: theme.spacing.sm),
              Text(thread.name, style: theme.typography.titleMedium),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(theme.spacing.lg),
            children: <Widget>[
              MonoMessage(
                align: MonoMessageAlign.start,
                avatar: MonoAvatar.initials(
                  thread.initials,
                  size: MonoAvatarSize.sm,
                ),
                child: MonoBubble(
                  variant: MonoBubbleVariant.muted,
                  child: MonoBubbleContent(child: Text(thread.preview)),
                ),
              ),
              SizedBox(height: theme.spacing.sm),
              const MonoMessage(
                align: MonoMessageAlign.end,
                child: MonoBubble(
                  variant: MonoBubbleVariant.primary,
                  child: MonoBubbleContent(child: Text('Yes — around Nima today.')),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(theme.spacing.md),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: MonoComposerBar(
            input: const MonoInput(placeholder: 'Reply…'),
            send: MonoButton.icon(
              icon: const MonoIcon(MonoIcons.send),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
