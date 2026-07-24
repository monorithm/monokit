import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/phase_ticker.dart';

/// Production-style block: the universal Post composer. One obvious action; no
/// intent picker; progressively-extracted facts; a natural clarification only
/// when a material claim blocks distribution. Publication is honest, never
/// optimistic.
class PostBlock extends StatefulWidget {
  const PostBlock({super.key});

  @override
  State<PostBlock> createState() => _PostBlockState();
}

class _PostBlockState extends State<PostBlock> {
  final TextEditingController _text = TextEditingController(
    text: 'iPhone 13, 128GB, great condition. GH₵ 4,800. Around Nima.',
  );
  final PhaseTicker _phase = PhaseTicker();
  bool _needsClarification = true;

  @override
  void dispose() {
    _text.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScreen(
      header: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: <Widget>[
            Text('New post', style: theme.typography.titleMedium),
            const Spacer(),
            const MonoBadge(
              variant: MonoBadgeVariant.secondary,
              child: Text('Draft'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MonoCaptureBar(
              shutter: MonoCameraShutter(onPressed: () {}),
              leading: MonoButton.icon(
                variant: MonoButtonVariant.ghost,
                icon: const MonoIcon(MonoIcons.image),
                onPressed: () {},
              ),
              trailing: MonoButton.icon(
                variant: MonoButtonVariant.ghost,
                icon: const MonoIcon(MonoIcons.mic),
                onPressed: () {},
              ),
            ),
            SizedBox(height: theme.spacing.lg),
            MonoField(
              label: const Text('Say what you have or need'),
              child: MonoInput(controller: _text, minLines: 3, maxLines: 6),
            ),
            SizedBox(height: theme.spacing.md),
            Wrap(
              spacing: theme.spacing.sm,
              runSpacing: theme.spacing.sm,
              children: const <Widget>[
                _FactChip('Category', 'Phones'),
                _FactChip('Price', 'GH₵ 4,800'),
                _FactChip('Condition', 'Used'),
                _FactChip('Area', 'Nima'),
              ],
            ),
            if (_needsClarification) ...<Widget>[
              SizedBox(height: theme.spacing.lg),
              MonoCard(
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'One quick check',
                        style: theme.typography.titleMedium,
                      ),
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        'Are you selling this, or looking for one?',
                        style: theme.typography.bodyMedium,
                      ),
                      SizedBox(height: theme.spacing.md),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: MonoButton(
                              onPressed: () =>
                                  setState(() => _needsClarification = false),
                              child: const Text('Selling'),
                            ),
                          ),
                          SizedBox(width: theme.spacing.sm),
                          Expanded(
                            child: MonoButton(
                              variant: MonoButtonVariant.outline,
                              onPressed: () =>
                                  setState(() => _needsClarification = false),
                              child: const Text('Looking for one'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      footer: MonoSurface(
        tier: MonoElevationTier.e4,
        padding: EdgeInsets.all(theme.spacing.md),
        child: ListenableBuilder(
          listenable: _phase,
          builder: (context, _) => _phase.phase == DemoPhase.created
              ? MonoButton(
                  size: MonoButtonSize.lg,
                  onPressed: _needsClarification ? null : _phase.start,
                  child: const Text('Post'),
                )
              : Row(
                  children: <Widget>[
                    MonoBadge(
                      variant: _phase.phase.isTerminalFailure
                          ? MonoBadgeVariant.destructive
                          : _phase.phase.isTerminalSuccess
                          ? MonoBadgeVariant.success
                          : MonoBadgeVariant.info,
                      child: Text(
                        _phase.phase.isTerminalSuccess
                            ? 'Posted'
                            : _phase.phase.isTerminalFailure
                            ? 'Failed'
                            : 'Publishing…',
                      ),
                    ),
                    SizedBox(width: theme.spacing.sm),
                    Expanded(
                      child: Text(
                        _phase.phase.isTerminalSuccess
                            ? 'Posted — reaching people near Nima'
                            : 'Publishing…',
                      ),
                    ),
                    if (_phase.phase.isTerminalFailure)
                      MonoButton(
                        onPressed: _phase.retry,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return MonoBadge(
      variant: MonoBadgeVariant.outline,
      child: Text('$label · $value'),
    );
  }
}
