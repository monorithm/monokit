import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/sample.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        ComponentSection(
          title: 'Bubble variants',
          widgetName: 'MonoBubble',
          code:
              "MonoBubble(\n  variant: MonoBubbleVariant.primary,\n  align: MonoMessageAlign.end,\n  child: MonoBubbleContent(child: Text('On my way to Nima.')),\n)",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final v in MonoBubbleVariant.values)
                Padding(
                  padding: EdgeInsets.only(bottom: theme.spacing.sm),
                  child: MonoBubble(
                    variant: v,
                    child: MonoBubbleContent(
                      child: Text('${v.name}: is this still available?'),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Message · avatar · reactions · receipt',
          widgetName: 'MonoMessage',
          child: Column(
            children: <Widget>[
              MonoMessage(
                align: MonoMessageAlign.start,
                avatar: const MonoAvatar(initials: 'AB'),
                child: MonoBubble(
                  variant: MonoBubbleVariant.muted,
                  reactions: const MonoBubbleReactions(
                    children: <Widget>[
                      MonoBubbleReaction(emoji: '👍', count: 2),
                    ],
                  ),
                  child: const MonoBubbleContent(
                    child: Text('GH₵ 4,800, slight negotiation. Around Nima.'),
                  ),
                ),
              ),
              const MonoMessage(
                align: MonoMessageAlign.end,
                child: MonoReceipt(state: MonoReceiptState.read),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Attachments — image, document, link',
          widgetName: 'MonoAttachment',
          description: 'Previews as much as possible, like a conversation app.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoAttachment.image(
                thumbnail: SamplePhoto(seed: 1),
                caption: Text('iPhone 13 — back, showing the frame'),
              ),
              SizedBox(height: theme.spacing.md),
              MonoAttachment.document(
                name: 'receipt.pdf',
                meta: 'PDF · 2.8 MB',
                onPressed: () {},
              ),
              SizedBox(height: theme.spacing.md),
              MonoAttachment.link(
                domain: 'monorithm.dev',
                title: 'iPhone 13 · 128GB · Nima',
                description: const Text(
                  'Clean, battery 89%. Meet at Nima or delivery in Accra.',
                ),
                thumbnail: const SamplePhoto(seed: 3),
                onPressed: () {},
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Typing indicator',
          widgetName: 'MonoTypingIndicator',
          description: 'Shown only while the other party is actually typing.',
          child: const MonoMessage(
            align: MonoMessageAlign.start,
            child: MonoTypingIndicator(),
          ),
        ),
        ComponentSection(
          title: 'Composer',
          widgetName: 'MonoComposerBar',
          child: MonoComposerBar(
            leading: MonoButton.icon(
              variant: MonoButtonVariant.ghost,
              icon: const MonoIcon(MonoIcons.add),
              onPressed: () {},
            ),
            input: const MonoInput(placeholder: 'Message…'),
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
