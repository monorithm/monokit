import 'package:monokit_ui/monokit_ui.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import 'scenario_kit.dart';

class ConversationScenario extends StatefulWidget {
  const ConversationScenario({super.key});

  @override
  State<ConversationScenario> createState() => _ConversationScenarioState();
}

class _Msg {
  const _Msg(this.text, this.mine, {this.read = false});
  final String text;
  final bool mine;
  final bool read;
}

class _ConversationScenarioState extends State<ConversationScenario> {
  final List<_Msg> _messages = <_Msg>[
    const _Msg('Hi! Is the lounge chair still available?', false),
    const _Msg('Yes it is — barely used.', true, read: true),
    const _Msg('Great. Would you deliver to East Legon?', false),
    const _Msg('Sure, free delivery in Accra today.', true, read: true),
  ];

  void _send() {
    setState(() {
      _messages.add(const _Msg('On my way — see you soon!', true));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ScenarioShell(
      title: 'Esi Addo',
      subtitle: 'online',
      actions: <Widget>[
        MonoButton(
          variant: MonoButtonVariant.ghost,
          size: MonoButtonSize.sm,
          iconOnly: true,
          semanticLabel: 'Call',
          onPressed: () {},
          child: const MonoIcon(MonoIcons.call),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.all(theme.spacing.lg),
        children: <Widget>[
          Center(
            child: MonoBadge(
              variant: MonoBadgeVariant.neutral,
              child: const Text('Today'),
            ),
          ),
          SizedBox(height: theme.spacing.md),
          MonoMessage(
            align: MonoMessageAlign.start,
            avatar: const MonoAvatar.initials('EA', size: MonoAvatarSize.sm),
            child: MonoBubble(
              variant: MonoBubbleVariant.muted,
              child: MonoBubbleContent(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radii.md),
                  child: const SizedBox(
                    width: 180,
                    height: 120,
                    child: AppImage(asset: AppAssets.chair, seed: 'chair'),
                  ),
                ),
              ),
            ),
          ),
          for (final m in _messages) ...<Widget>[
            SizedBox(height: theme.spacing.sm),
            MonoMessage(
              align: m.mine ? MonoMessageAlign.end : MonoMessageAlign.start,
              avatar: m.mine
                  ? null
                  : const MonoAvatar.initials('EA', size: MonoAvatarSize.sm),
              child: MonoBubble(
                variant: m.mine
                    ? MonoBubbleVariant.primary
                    : MonoBubbleVariant.muted,
                child: MonoBubbleContent(child: Text(m.text)),
              ),
            ),
            if (m.mine && m.read)
              const MonoMessage(
                align: MonoMessageAlign.end,
                child: MonoReceipt(phase: MonoPhase.succeeded, label: 'Seen'),
              ),
          ],
        ],
      ),
      bottom: MonoComposerBar(
        leading: MonoButton.icon(
          variant: MonoButtonVariant.ghost,
          icon: const MonoIcon(MonoIcons.add),
          onPressed: () {},
        ),
        input: const MonoInput(placeholder: 'Message…'),
        send: MonoButton.icon(
          icon: const MonoIcon(MonoIcons.send),
          onPressed: _send,
        ),
      ),
    );
  }
}
