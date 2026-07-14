import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/phase_ticker.dart';

class HonestPage extends StatelessWidget {
  const HonestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        ComponentSection(
          title: 'A command, start to finish',
          widgetName: 'MonoOrderStatus',
          description:
              'created → queued → sent → accepted → completed. The badge '
              'and copy transition live; failure carries a retry.',
          code:
              "MonoOrderStatus(\n  phase: ticker.phase,\n  label: Text(ticker.phase.isTerminalSuccess ? 'Posted' : 'Publishing…'),\n  onRetry: ticker.retry,\n)",
          child: const _LiveCommand(),
        ),
        ComponentSection(
          title: 'Optimistic, with rollback',
          widgetName: 'MonoOptimistic',
          description:
              'The follow flips immediately; if the commit throws it rolls '
              'back. (This demo fails on purpose to show the rollback.)',
          child: MonoOptimistic<bool>(
            value: false,
            commit: (next) async {
              await Future<void>.delayed(const Duration(milliseconds: 900));
              if (next) throw StateError('network');
              return next;
            },
            builder: (context, value, pending, set) => MonoButton(
              variant:
                  value ? MonoButtonVariant.primary : MonoButtonVariant.outline,
              leading: pending
                  ? const MonoSpinner(size: 14)
                  : const MonoIcon(MonoIcons.add, size: 16),
              onPressed: () => set(!value),
              child: Text(value ? 'Following' : 'Follow'),
            ),
          ),
        ),
        ComponentSection(
          title: 'accepted ≠ success',
          widgetName: 'MonoBanner',
          description: 'Celebration fires only on completed — never on receipt.',
          child: Column(
            children: <Widget>[
              const MonoBanner(
                variant: MonoAlertVariant.info,
                child: Text('Received — we are matching your post.'),
              ),
              SizedBox(height: theme.spacing.sm),
              const MonoBanner(
                variant: MonoAlertVariant.success,
                child: Text('Completed — 3 people near you were reached.'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Availability is visually distinct',
          widgetName: 'MonoAvailability',
          description: 'Terminal states (Sold / Closed / Expired) are not '
              'actionable — their surfaces disable the primary action.',
          child: Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: <Widget>[
              for (final a in MonoAvailability.values) AvailabilityBadge(a),
            ],
          ),
        ),
        ComponentSection(
          title: 'Message receipts',
          widgetName: 'MonoReceipt',
          child: Wrap(
            spacing: theme.spacing.lg,
            runSpacing: theme.spacing.md,
            children: <Widget>[
              for (final s in MonoReceiptState.values)
                DemoTile(label: s.name, child: MonoReceipt(state: s)),
            ],
          ),
        ),
        ComponentSection(
          title: 'The reconciling shimmer',
          widgetName: 'MonoReconcile',
          description: 'Looping = still loading; one final sweep = settled.',
          child: const _ReconcileDemo(),
        ),
      ],
    );
  }
}

class _LiveCommand extends StatefulWidget {
  const _LiveCommand();

  @override
  State<_LiveCommand> createState() => _LiveCommandState();
}

class _LiveCommandState extends State<_LiveCommand> {
  final PhaseTicker _ticker = PhaseTicker();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListenableBuilder(
      listenable: _ticker,
      builder: (context, _) {
        final phase = _ticker.phase;
        return Row(
          children: <Widget>[
            Expanded(
              child: phase == MonoCommandPhase.created
                  ? Text('Ready to post.', style: theme.typography.bodyMedium)
                  : MonoOrderStatus(
                      phase: phase,
                      label: Text(
                        phase.isTerminalSuccess
                            ? 'Posted — reaching people near Nima'
                            : 'Publishing…',
                      ),
                      onRetry: _ticker.retry,
                    ),
            ),
            SizedBox(width: theme.spacing.md),
            MonoButton(
              onPressed: phase.isPending ? null : _ticker.start,
              child: Text(phase == MonoCommandPhase.created ? 'Post' : 'Again'),
            ),
          ],
        );
      },
    );
  }
}

class _ReconcileDemo extends StatefulWidget {
  const _ReconcileDemo();

  @override
  State<_ReconcileDemo> createState() => _ReconcileDemoState();
}

class _ReconcileDemoState extends State<_ReconcileDemo> {
  bool _settled = false;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Row(
      children: <Widget>[
        MonoReconcile(
          settled: _settled,
          child: MonoBadge(
            variant: _settled
                ? MonoBadgeVariant.success
                : MonoBadgeVariant.warning,
            child: Text(_settled ? 'Synced' : 'Reconciling'),
          ),
        ),
        SizedBox(width: theme.spacing.md),
        MonoButton(
          variant: MonoButtonVariant.outline,
          size: MonoButtonSize.sm,
          onPressed: () => setState(() => _settled = !_settled),
          child: Text(_settled ? 'Reset' : 'Settle'),
        ),
      ],
    );
  }
}
