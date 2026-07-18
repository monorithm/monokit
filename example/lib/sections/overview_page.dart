import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        Text('Monokit', style: theme.typography.displayMedium),
        SizedBox(height: theme.spacing.sm),
        Text(
          'A widgets-first, Material-free Flutter design system — emerald on '
          'mist, borders and light not shadows, honest by architecture.',
          style: theme.typography.bodyLarge.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        SizedBox(height: theme.spacing.xxl),
        Wrap(
          spacing: theme.spacing.lg,
          runSpacing: theme.spacing.lg,
          children: const <Widget>[
            _PitchCard(
              title: 'Two registers',
              body:
                  'Component sections document every widget; blocks show them '
                  'composed into real product screens.',
            ),
            _PitchCard(
              title: 'Honest states',
              body:
                  'The command lifecycle is design vocabulary — pending '
                  'badges, reconciling shimmer, accepted ≠ success.',
            ),
            _PitchCard(
              title: 'Built for Monorithm',
              body:
                  'A country-bounded intent marketplace: chat, media, '
                  'commerce and honest-state families lead.',
            ),
          ],
        ),
        SizedBox(height: theme.spacing.xxl),
        MonoCard(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const MonoIcon(MonoIcons.sparkles),
                    SizedBox(width: theme.spacing.sm),
                    Text(
                      'Start with the Foundations',
                      style: theme.typography.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing.sm),
                Text(
                  'Every section satisfies one contract: named widget, full '
                  'variant matrix, all states, live (never faked), a code peek, '
                  'responsive, themed, accessible.',
                  style: theme.typography.bodyMedium.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      width: 300,
      child: MonoCard(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: theme.typography.titleMedium),
              SizedBox(height: theme.spacing.xs),
              Text(
                body,
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
