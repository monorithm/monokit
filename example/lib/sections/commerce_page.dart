import 'package:monokit/monokit.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import '../kit/component_section.dart';
import '../kit/page_hero.dart';

/// A product for the commerce demos.
class _Product {
  const _Product(this.asset, this.seed, this.title, this.place, this.price);
  final String asset;
  final String seed;
  final String title;
  final String place;
  final String price;
}

const List<_Product> _products = <_Product>[
  _Product(AppAssets.phone, 'phone', 'iPhone 13 · 128GB', 'Nima', '4,800'),
  _Product(AppAssets.sneakers, 'sneakers', 'Retro sneakers', 'Osu', '320'),
  _Product(
    AppAssets.chair,
    'chair',
    'Linen lounge chair',
    'East Legon',
    '2,100',
  ),
  _Product(AppAssets.lamp, 'lamp', 'Arc floor lamp', 'Cantonments', '540'),
  _Product(AppAssets.plant, 'plant', 'Monstera, large', 'Labone', '180'),
];

class CommercePage extends StatefulWidget {
  const CommercePage({super.key});

  @override
  State<CommercePage> createState() => _CommercePageState();
}

class _CommercePageState extends State<CommercePage> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ListView(
      padding: EdgeInsets.all(theme.spacing.giant),
      children: <Widget>[
        PageHero(
          eyebrow: 'Commerce',
          title: 'Buying & selling',
          tagline:
              'Price tags with tabular figures, product cards, quantity steppers, '
              'and a cart bar — the marketplace surfaces, with real imagery.',
          child: const _CommerceHero(),
        ),
        const SectionDivider(),
        const StageBlock(
          title: 'A product grid that reflows',
          description:
              'Cards pack from one column to four as the viewport widens — the '
              'core storefront layout.',
          stageHeight: 460,
          child: _ProductGrid(),
        ),
        const SectionDivider(),
        ComponentSection(
          title: 'Price tag',
          widgetName: 'MonoPriceTag',
          description:
              'Tabular figures; a struck-through compareAt announces '
              '"was X, now Y".',
          child: const MonoPriceTag(
            currency: 'GH₵',
            price: '4,800',
            compareAt: '5,400',
          ),
        ),
        ComponentSection(
          title: 'Product card',
          widgetName: 'MonoProductCard',
          child: SizedBox(
            width: 240,
            child: MonoProductCard(
              onPressed: () {},
              media: const AspectRatio(
                aspectRatio: 1,
                child: AppImage(asset: AppAssets.phone, seed: 'phone'),
              ),
              title: const Text('iPhone 13 · 128GB'),
              description: const Text('Nima'),
              price: const MonoPriceTag(currency: 'GH₵', price: '4,800'),
              badge: const MonoBadge(
                variant: MonoBadgeVariant.secondary,
                child: Text('Used'),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: 'Quantity stepper',
          widgetName: 'MonoQuantityStepper',
          child: MonoQuantityStepper(
            value: _qty,
            minimum: 1,
            onChanged: (v) => setState(() => _qty = v),
          ),
        ),
        ComponentSection(
          title: 'Cart bar',
          widgetName: 'MonoCartBar',
          child: MonoCartBar(
            summary: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$_qty item${_qty == 1 ? '' : 's'}',
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                MonoPriceTag(currency: 'GH₵', price: '${4800 * _qty}'),
              ],
            ),
            action: MonoButton(onPressed: () {}, child: const Text('Checkout')),
          ),
        ),
      ],
    );
  }
}

/// A featured product for the hero.
class _CommerceHero extends StatelessWidget {
  const _CommerceHero();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= theme.breakpoints.compact;
        final image = ClipRRect(
          borderRadius: BorderRadius.circular(theme.radii.lg),
          child: const AspectRatio(
            aspectRatio: 4 / 3,
            child: AppImage(asset: AppAssets.chair, seed: 'chair'),
          ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const MonoBadge(
              variant: MonoBadgeVariant.secondary,
              child: Text('Furniture · Used'),
            ),
            SizedBox(height: theme.spacing.sm),
            Text('Linen lounge chair', style: theme.typography.titleLarge),
            SizedBox(height: theme.spacing.xs),
            Text(
              'East Legon · free delivery in Accra',
              style: theme.typography.bodyMedium.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            SizedBox(height: theme.spacing.md),
            const MonoPriceTag(
              currency: 'GH₵',
              price: '2,100',
              compareAt: '2,600',
            ),
            SizedBox(height: theme.spacing.lg),
            Wrap(
              spacing: theme.spacing.sm,
              runSpacing: theme.spacing.sm,
              children: <Widget>[
                IntrinsicWidth(
                  child: MonoButton(
                    onPressed: () {},
                    leading: const MonoIcon(MonoIcons.bag, size: 16),
                    child: const Text('Add to cart'),
                  ),
                ),
                MonoButton(
                  variant: MonoButtonVariant.outline,
                  size: MonoButtonSize.icon,
                  onPressed: () {},
                  child: const MonoIcon(MonoIcons.bookmark),
                ),
              ],
            ),
          ],
        );
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              image,
              SizedBox(height: theme.spacing.lg),
              details,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: image),
            SizedBox(width: theme.spacing.xl),
            Expanded(child: details),
          ],
        );
      },
    );
  }
}

/// A storefront grid of [MonoProductCard]s that reflows by width.
class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final bp = theme.breakpoints;
        final columns = w < bp.compact
            ? 1
            : w < bp.medium
            ? 2
            : w < bp.expanded
            ? 3
            : 4;
        final gap = theme.spacing.md;
        final pad = theme.spacing.sm;
        final available = w - pad * 2;
        final tileWidth = (available - gap * (columns - 1)) / columns;
        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: <Widget>[
              for (final p in _products)
                SizedBox(
                  width: tileWidth > 0 ? tileWidth : w,
                  child: MonoProductCard(
                    onPressed: () {},
                    media: AspectRatio(
                      aspectRatio: 1,
                      child: AppImage(asset: p.asset, seed: p.seed),
                    ),
                    title: Text(p.title),
                    description: Text(p.place),
                    price: MonoPriceTag(currency: 'GH₵', price: p.price),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
