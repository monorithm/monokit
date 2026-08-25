import 'package:monokit_ui/monokit_ui.dart';

import '../kit/component_section.dart';
import '../kit/page_hero.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Feedback',
          title: 'Honest system states',
          tagline:
              'Alerts, banners, progress, skeletons, and empty states — offline '
              'is a condition, not an error, and loading is shown, not hidden.',
          child: const _FeedbackHero(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Alerts',
          widgetName: 'MonoAlert',
          child: Column(
            children: <Widget>[
              const MonoAlert(
                variant: MonoAlertVariant.info,
                title: Text('Heads up'),
                description: Text('Your post reaches people near Nima first.'),
              ),
              SizedBox(height: theme.spacing.sm),
              const MonoAlert(
                variant: MonoAlertVariant.destructive,
                title: Text('Payment failed'),
                description: Text('We could not verify the transfer.'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Banners',
          widgetName: 'MonoBanner',
          description:
              'Inline, dismissible status. Offline is a condition, '
              'not an error.',
          child: Column(
            children: <Widget>[
              MonoBanner(
                variant: MonoAlertVariant.success,
                onDismiss: () {},
                child: const Text('3 people near you were reached.'),
              ),
              SizedBox(height: theme.spacing.sm),
              const MonoBanner(
                variant: MonoAlertVariant.warning,
                child: Text('You are offline. Your post is queued.'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Progress & spinner',
          widgetName: 'MonoProgress',
          child: Row(
            children: <Widget>[
              const Expanded(child: MonoProgress(value: 0.62)),
              SizedBox(width: theme.spacing.lg),
              const MonoProgress(type: MonoProgressType.circular, value: 0.62),
              SizedBox(width: theme.spacing.lg),
              const MonoSpinner(),
            ],
          ),
        ),
        ComponentSection(
          title: 'Step progress',
          widgetName: 'MonoStepProgress',
          description:
              '"Which step of how many", where MonoProgress answers "how '
              'much". One progress semantic; the segments are presentation.',
          code: 'MonoStepProgress(length: 5, value: 2)',
          child: Row(
            children: <Widget>[
              const MonoStepProgress(length: 5, value: 2),
              SizedBox(width: theme.spacing.xl),
              const MonoStepProgress(length: 3, value: 3),
            ],
          ),
        ),
        ComponentSection(
          title: 'Skeleton',
          widgetName: 'MonoSkeleton',
          description: 'Loading placeholders that shimmer.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoSkeleton(width: 220, height: 16),
              SizedBox(height: theme.spacing.sm),
              const MonoSkeleton(width: 160, height: 16),
              SizedBox(height: theme.spacing.sm),
              const MonoSkeleton(width: 120, height: 12),
            ],
          ),
        ),
        ComponentSection(
          title: 'Empty state',
          widgetName: 'MonoEmptyState',
          child: MonoEmptyState(
            icon: const MonoIcon(MonoIcons.search, size: 28),
            title: const Text('Nothing matches yet'),
            description: const Text(
              'Post what you need so sellers can find you.',
            ),
            action: MonoButton(
              onPressed: () {},
              child: const Text('Post what you need'),
            ),
          ),
        ),
      ],
    );
  }
}

/// A composed sync panel for the hero.
class _FeedbackHero extends StatelessWidget {
  const _FeedbackHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Publishing listing',
                style: theme.typography.titleMedium,
              ),
            ),
            const MonoBadge(
              variant: MonoBadgeVariant.info,
              child: Text('Syncing'),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.md),
        const MonoProgress(value: 0.72),
        SizedBox(height: theme.spacing.lg),
        const MonoBanner(
          variant: MonoAlertVariant.warning,
          child: Text('You are offline — your post is queued and will send.'),
        ),
      ],
    );
  }
}
