import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

import '../kit/device_frame.dart';

class BlockMeta {
  const BlockMeta(this.path, this.title, this.description);
  final String path;
  final String title;
  final String description;
}

const List<BlockMeta> blockList = <BlockMeta>[
  BlockMeta('/blocks/signin', 'Sign in', 'Phone number + OTP'),
  BlockMeta('/blocks/for-you', 'For You', 'The immersive discovery feed'),
  BlockMeta('/blocks/search', 'Search', 'Query → constraint chips → results'),
  BlockMeta('/blocks/post', 'Post composer', 'One universal composer'),
  BlockMeta('/blocks/post-detail', 'Post detail', 'Availability states'),
  BlockMeta('/blocks/interest', 'Interest thread', 'Lifecycle + consent'),
];

/// Index of the production-style blocks.
class BlocksIndexPage extends StatelessWidget {
  const BlocksIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        Text('Blocks', style: theme.typography.displayMedium),
        SizedBox(height: theme.spacing.sm),
        Text(
          'Production-style example screens — the widgets composed into real '
          'Monorithm surfaces. Not the shipping app: no live data, routing, or '
          'auth backends.',
          style: theme.typography.bodyLarge.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        SizedBox(height: theme.spacing.xxl),
        Wrap(
          spacing: theme.spacing.lg,
          runSpacing: theme.spacing.lg,
          children: <Widget>[
            for (final b in blockList)
              SizedBox(
                width: 300,
                child: MonoCard(
                  child: Padding(
                    padding: EdgeInsets.all(theme.spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(b.title, style: theme.typography.titleMedium),
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          b.description,
                          style: theme.typography.bodyMedium.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        SizedBox(height: theme.spacing.md),
                        MonoButton(
                          variant: MonoButtonVariant.outline,
                          size: MonoButtonSize.sm,
                          trailing: const MonoIcon(MonoIcons.arrowRight, size: 14),
                          onPressed: () => context.go(b.path),
                          child: const Text('Open'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Wraps a block in a phone frame with a back affordance to the index.
class BlockViewer extends StatelessWidget {
  const BlockViewer({super.key, required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Row(
            children: <Widget>[
              MonoButton(
                variant: MonoButtonVariant.ghost,
                size: MonoButtonSize.sm,
                leading: const MonoIcon(MonoIcons.chevronLeft, size: 16),
                onPressed: () => context.go('/blocks'),
                child: const Text('Blocks'),
              ),
              SizedBox(width: theme.spacing.sm),
              Text(title, style: theme.typography.titleMedium),
            ],
          ),
        ),
        Expanded(child: DeviceFrame(child: child)),
      ],
    );
  }
}
