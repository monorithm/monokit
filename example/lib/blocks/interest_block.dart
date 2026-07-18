import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/sample.dart';

/// Production-style block: the post-scoped interest thread. A lifecycle stepper,
/// honest receipts, a typing indicator shown only while typing, and a
/// consent-gated contact-disclosure sheet (the number is never auto-revealed).
class InterestBlock extends StatefulWidget {
  const InterestBlock({super.key});

  @override
  State<InterestBlock> createState() => _InterestBlockState();
}

class _InterestBlockState extends State<InterestBlock> {
  final List<ThreadMessage> _messages = sampleThread();
  final TextEditingController _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ThreadMessage.mine(text, MonoReceiptState.sent));
      _composer.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScreen(
      header: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: <Widget>[
            const MonoAvatar(initials: 'AB'),
            SizedBox(width: theme.spacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Abbas', style: theme.typography.titleMedium),
                Text(
                  'iPhone 13 · Nima',
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          const _LifecycleStepper(current: 2),
          Expanded(
            child: MonoMessageScroller(
              padding: EdgeInsets.all(theme.spacing.md),
              children: <Widget>[
                for (final m in _messages) _bubble(context, m),
              ],
            ),
          ),
        ],
      ),
      footer: MonoComposerBar(
        leading: MonoButton.icon(
          variant: MonoButtonVariant.ghost,
          icon: const MonoIcon(MonoIcons.add),
          onPressed: () {},
        ),
        input: MonoInput(
          controller: _composer,
          placeholder: 'Message…',
          onSubmitted: (_) => _send(),
        ),
        send: MonoButton.icon(
          icon: const MonoIcon(MonoIcons.send),
          onPressed: _send,
        ),
      ),
      floating: const _ShareContactButton(),
    );
  }

  Widget _bubble(BuildContext context, ThreadMessage m) {
    return Padding(
      padding: EdgeInsets.only(bottom: MonokitTheme.of(context).spacing.sm),
      child: MonoMessage(
        align: m.mine ? MonoMessageAlign.end : MonoMessageAlign.start,
        avatar: m.mine ? null : const MonoAvatar(initials: 'AB'),
        child: Column(
          crossAxisAlignment: m.mine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (m.attachment != null)
              Padding(
                padding: EdgeInsets.only(
                  bottom: MonokitTheme.of(context).spacing.xs,
                ),
                child: MonoAttachment.image(
                  thumbnail: m.attachment,
                  aspectRatio: 1,
                  maxWidth: 180,
                ),
              ),
            MonoBubble(
              variant: m.mine
                  ? MonoBubbleVariant.primary
                  : MonoBubbleVariant.muted,
              child: MonoBubbleContent(child: Text(m.text)),
            ),
            if (m.mine) MonoReceipt(state: m.receipt),
          ],
        ),
      ),
    );
  }
}

class _LifecycleStepper extends StatelessWidget {
  const _LifecycleStepper({required this.current});
  final int current;

  static const List<String> _stages = <String>[
    'Open',
    'Acknowledged',
    'Conversing',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.md,
        vertical: theme.spacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < _stages.length; i++) ...<Widget>[
            _Dot(active: i <= current, current: i == current),
            // Only the active stage keeps its label, so the stepper never
            // overflows on a narrow screen.
            if (i == current) ...<Widget>[
              SizedBox(width: theme.spacing.xs),
              Flexible(
                child: Text(
                  _stages[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ],
            if (i != _stages.length - 1)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
                  child: MonoSeparator(),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.current});
  final bool active;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? theme.colors.primary : theme.colors.muted,
        border: Border.all(
          color: current ? theme.colors.primary : theme.colors.border,
          width: current ? 2 : 1,
        ),
      ),
    );
  }
}

class _ShareContactButton extends StatelessWidget {
  const _ShareContactButton();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoSheet(
      side: MonoSheetSide.bottom,
      trigger: MonoButton(
        variant: MonoButtonVariant.outline,
        leading: const MonoIcon(MonoIcons.call, size: 16),
        child: const Text('Share contact'),
      ),
      child: MonoSheetContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const MonoSheetHeader(
              title: Text('Share your contact?'),
              description: Text(
                'Abbas will be able to see the details below. You can stop '
                'sharing anytime.',
              ),
            ),
            SizedBox(height: theme.spacing.md),
            _DisclosureRow(
              icon: MonoIcons.call,
              label: 'Phone',
              value: '024 •••  ••23 — revealed after you confirm',
            ),
            SizedBox(height: theme.spacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: MonoSheetClose(
                    child: MonoButton(
                      variant: MonoButtonVariant.outline,
                      child: const Text('Not now'),
                    ),
                  ),
                ),
                SizedBox(width: theme.spacing.sm),
                Expanded(
                  child: MonoButton(
                    onPressed: () {},
                    child: const Text('Share contact'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclosureRow extends StatelessWidget {
  const _DisclosureRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final MonoIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Row(
      children: <Widget>[
        MonoIcon(icon, size: 18, color: theme.colors.mutedForeground),
        SizedBox(width: theme.spacing.sm),
        Text(label, style: theme.typography.labelLarge),
        SizedBox(width: theme.spacing.sm),
        Expanded(
          child: Text(
            value,
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}
