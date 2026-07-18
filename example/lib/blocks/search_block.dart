import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/sample.dart';

/// Production-style block: search. Natural-language query → parsed-constraint
/// chips → a uniform result grid. The empty state offers the two escape
/// hatches: post what you need, or save the search.
class SearchBlock extends StatefulWidget {
  const SearchBlock({super.key});

  @override
  State<SearchBlock> createState() => _SearchBlockState();
}

class _SearchBlockState extends State<SearchBlock> {
  String _query = 'fairly used iPhone 13 under 5,000 in Accra';
  late List<Constraint> _constraints = parseConstraints(_query);
  late List<FeedPost> _results = searchSample(_constraints);

  void _run(String q) {
    setState(() {
      _query = q;
      _constraints = parseConstraints(q);
      _results = searchSample(_constraints);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoScreen(
      header: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: MonoInput(
          initialValue: _query,
          placeholder: 'Describe what you need…',
          prefix: const MonoIcon(MonoIcons.search, size: 16),
          textInputAction: TextInputAction.search,
          onChanged: _run,
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: theme.spacing.md),
              child: Wrap(
                spacing: theme.spacing.sm,
                runSpacing: theme.spacing.sm,
                children: <Widget>[
                  for (final c in _constraints)
                    MonoBadge(
                      variant: MonoBadgeVariant.outline,
                      child: Text('${c.label}: ${c.value}'),
                    ),
                ],
              ),
            ),
          ),
          if (_results.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(theme.spacing.lg),
                child: MonoEmptyState(
                  icon: const MonoIcon(MonoIcons.search, size: 28),
                  title: const Text('Nothing matches yet'),
                  description: const Text(
                    'Post what you need so sellers can find you — or save this '
                    'search and we will alert you.',
                  ),
                  action: MonoButton(
                    onPressed: () {},
                    child: const Text('Post what you need'),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(theme.spacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: EdgeInsets.only(bottom: theme.spacing.sm),
                    child: _ResultRow(post: _results[i]),
                  ),
                  childCount: _results.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.post});
  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoCard(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(theme.radii.md),
              child: SizedBox(width: 64, height: 64, child: post.thumb),
            ),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.titleMedium,
                  ),
                  Text(
                    post.location,
                    style: theme.typography.bodyMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  SizedBox(height: theme.spacing.xs),
                  MonoPriceTag(price: post.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
