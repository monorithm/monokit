import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';
import 'messaging_state.dart';

/// Interactive documentation for Monokit's chat-oriented components.
class MessagingPage extends StatefulWidget {
  const MessagingPage({super.key});

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final MessagingState _state = MessagingState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MessagingScope(
      state: _state,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = MessagingScope.of(
      context,
    ); // rebuilds this subtree when state notifies

    Widget buildThreadMessage(ThreadMessage message) {
      final variant = message.isOwn
          ? MonoBubbleVariant.primary
          : MonoBubbleVariant.secondary;
      return MonoMessage(
        key: ValueKey<String>(message.id),
        align: message.isOwn ? MonoMessageAlign.end : MonoMessageAlign.start,
        avatar: MonoAvatar.initials(
          message.isOwn ? 'YO' : 'MK',
          size: MonoAvatarSize.sm,
        ),
        header: MonoMessageHeader(child: Text(message.author)),
        footer: MonoMessageFooter(child: Text(message.time)),
        child: MonoMessageContent(
          child: MonoBubble(
            variant: variant,
            child: MonoBubbleContent(child: Text(message.text)),
          ),
        ),
      );
    }

    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Chat-native composition',
          description:
              'Build conversation views from small message, bubble, reaction, attachment, and scrolling primitives—without a Material dependency.',
        ),
        const DocGroupTitle('Message anatomy'),
        DocSection(
          name: 'MonoMessage and slots',
          description:
              'MonoMessage provides the aligned group; MonoMessageHeader, MonoMessageContent, and MonoMessageFooter provide semantic metadata and content slots. Its MonoMessageScope automatically gives nested components the active alignment.',
          code: '''MonoMessage(
  align: MonoMessageAlign.end,
  avatar: const MonoAvatar.initials('YO'),
  header: const MonoMessageHeader(child: Text('You')),
  child: MonoMessageContent(
    child: MonoBubble(
      variant: MonoBubbleVariant.primary,
      child: const MonoBubbleContent(child: Text('Hello')),
    ),
  ),
  footer: const MonoMessageFooter(child: Text('Just now')),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MonoMessage(
                avatar: const MonoAvatar.initials(
                  'MK',
                  size: MonoAvatarSize.sm,
                ),
                header: const MonoMessageHeader(
                  child: Text('Monokit assistant'),
                ),
                footer: const MonoMessageFooter(
                  child: Text('Delivered · 10:24'),
                ),
                child: const MonoMessageContent(
                  child: MonoBubble(
                    variant: MonoBubbleVariant.secondary,
                    child: MonoBubbleContent(
                      child: Text(
                        'I am a start-aligned message with a header, content slot, and footer.',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MonoMessage(
                align: MonoMessageAlign.end,
                avatar: const MonoAvatar.initials(
                  'YO',
                  size: MonoAvatarSize.sm,
                ),
                header: const MonoMessageHeader(child: Text('You')),
                footer: const MonoMessageFooter(child: Text('Read · 10:25')),
                child: MonoMessageContent(
                  child: MonoBubble(
                    variant: MonoBubbleVariant.primary,
                    reactions: MonoBubbleReactions(
                      children: <Widget>[
                        MonoBubbleReaction(
                          emoji: '👍',
                          count: state.liked ? 2 : 1,
                          selected: state.liked,
                          semanticLabel: 'Like message',
                          onPressed: () => state.setLiked(!state.liked),
                        ),
                        MonoBubbleReaction(
                          emoji: '✨',
                          count: state.celebrated ? 2 : 1,
                          selected: state.celebrated,
                          semanticLabel: 'Celebrate message',
                          onPressed: () =>
                              state.setCelebrated(!state.celebrated),
                        ),
                      ],
                    ),
                    child: const MonoBubbleContent(
                      child: Text(
                        'This end-aligned message carries interactive MonoBubbleReactions.',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoBubble variants and alignment',
          description:
              'MonoBubble supports eight semantic treatments. Set align directly, or let it inherit from the closest MonoMessage. MonoBubbleAlign and MonoBubbleAlignment are aliases for MonoMessageAlign, useful when a bubble-specific name reads better in your API.',
          code: '''const MonoBubble(
  variant: MonoBubbleVariant.outline,
  align: MonoMessageAlign.start,
  child: MonoBubbleContent(child: Text('Outlined')),
)

// MonoBubbleAlign and MonoBubbleAlignment
// are aliases of MonoMessageAlign.''',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              for (
                var index = 0;
                index < MonoBubbleVariant.values.length;
                index++
              )
                SizedBox(
                  width: 260,
                  child: _BubbleVariantDemo(
                    variant: MonoBubbleVariant.values[index],
                    align: index.isEven
                        ? MonoMessageAlign.start
                        : MonoMessageAlign.end,
                  ),
                ),
            ],
          ),
        ),
        const DocGroupTitle('Attachments'),
        DocSection(
          name: 'MonoAttachment in messages',
          description:
              'Use file, image, and compact variants inside a bubble or directly in a feed. The data and preview are entirely widget-composed.',
          code: '''MonoAttachment.image(
  name: 'launch-preview.png',
  description: const Text('1200 × 800 · PNG'),
  thumbnail: preview,
)

MonoAttachment(
  variant: MonoAttachmentVariant.compact,
  name: 'notes.md',
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoMessage(
                avatar: const MonoAvatar.initials(
                  'MK',
                  size: MonoAvatarSize.sm,
                ),
                header: const MonoMessageHeader(
                  child: Text('Monokit assistant'),
                ),
                footer: const MonoMessageFooter(
                  child: Text('3 attachments · 10:27'),
                ),
                child: MonoBubble(
                  variant: MonoBubbleVariant.default_,
                  child: MonoBubbleContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Here are the artifacts for review.'),
                        const SizedBox(height: 12),
                        MonoAttachment(
                          name: 'component-audit.pdf',
                          description: const Text('2.4 MB · PDF'),
                          leading: const MonoIcon(MonoIcons.sparkles),
                          trailing: const MonoIcon(MonoIcons.arrowRight),
                          onPressed: state.appendMessage,
                        ),
                        const SizedBox(height: 8),
                        MonoAttachment.image(
                          name: 'launch-preview.png',
                          description: const Text('1200 × 800 · PNG'),
                          thumbnail: const _PreviewThumbnail(),
                          onPressed: state.appendMessage,
                        ),
                        const SizedBox(height: 8),
                        MonoAttachment(
                          variant: MonoAttachmentVariant.compact,
                          name: 'notes.md',
                          leading: const MonoIcon(MonoIcons.check),
                          onPressed: state.appendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const DocGroupTitle('Conversation scrolling'),
        DocSection(
          name: 'MonoMessageScroller',
          description:
              'This live thread has a fixed height so it remains bounded inside the documentation page. Append messages while reading the end to see autoScroll preserve the latest conversation; scroll upward first to keep your reading position.',
          code: '''SizedBox(
  height: 320,
  child: MonoMessageScroller(
    autoScroll: true,
    initialScrollToEnd: true,
    children: messages.map(buildMessage).toList(),
  ),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 320,
                child: MonoMessageScroller(
                  autoScroll: true,
                  initialScrollToEnd: true,
                  keepAtEndThreshold: 64,
                  empty: const Center(child: Text('No messages yet.')),
                  children: state.thread
                      .map(buildThreadMessage)
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: MonoButton.icon(
                  size: MonoButtonSize.sm,
                  icon: const MonoIcon(MonoIcons.send),
                  label: const Text('Append message'),
                  onPressed: state.appendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BubbleVariantDemo extends StatelessWidget {
  const _BubbleVariantDemo({required this.variant, required this.align});

  final MonoBubbleVariant variant;
  final MonoMessageAlign align;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _bubbleVariantLabel(variant),
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        MonoBubble(
          variant: variant,
          align: align,
          child: MonoBubbleContent(
            child: Text(
              align == MonoMessageAlign.end
                  ? 'End-aligned bubble'
                  : 'Start-aligned bubble',
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewThumbnail extends StatelessWidget {
  const _PreviewThumbnail();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF6D28D9), Color(0xFF0EA5E9)],
        ),
        borderRadius: BorderRadius.circular(theme.radii.sm),
      ),
      child: Center(
        child: Text(
          'PREVIEW',
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}

String _bubbleVariantLabel(MonoBubbleVariant variant) {
  return switch (variant) {
    MonoBubbleVariant.default_ => 'default_',
    MonoBubbleVariant.primary => 'primary',
    MonoBubbleVariant.secondary => 'secondary',
    MonoBubbleVariant.muted => 'muted',
    MonoBubbleVariant.tinted => 'tinted',
    MonoBubbleVariant.outline => 'outline',
    MonoBubbleVariant.ghost => 'ghost',
    MonoBubbleVariant.destructive => 'destructive',
  };
}
