import 'package:monokit/monokit.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import 'scenario_kit.dart';

class _Item {
  const _Item(this.asset, this.seed, this.title, this.place, this.price);
  final String asset;
  final String seed;
  final String title;
  final String place;
  final String price;
}

const List<_Item> _items = <_Item>[
  _Item(AppAssets.phone, 'phone', 'iPhone 13 · 128GB', 'Nima', '4,800'),
  _Item(AppAssets.chair, 'chair', 'Linen lounge chair', 'East Legon', '2,100'),
  _Item(AppAssets.sneakers, 'sneakers', 'Retro sneakers', 'Osu', '320'),
  _Item(AppAssets.lamp, 'lamp', 'Arc floor lamp', 'Cantonments', '540'),
  _Item(AppAssets.plant, 'plant', 'Monstera, large', 'Labone', '180'),
  _Item(AppAssets.food, 'food', 'Home-cooked waakye', 'Accra Central', '25'),
];

class StorefrontScenario extends StatelessWidget {
  const StorefrontScenario({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ScenarioShell(
      title: 'Marketplace',
      subtitle: 'Near Accra',
      showBack: false,
      actions: <Widget>[
        MonoButton(
          variant: MonoButtonVariant.ghost,
          size: MonoButtonSize.iconSm,
          semanticLabel: 'Cart',
          onPressed: () {},
          child: const MonoIcon(MonoIcons.bag),
        ),
      ],
      bottom: const _StoreNav(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final columns = w < 520 ? 2 : (w < 900 ? 3 : 4);
          final gap = theme.spacing.md;
          final pad = theme.spacing.lg;
          final tileWidth = (w - pad * 2 - gap * (columns - 1)) / columns;
          return ListView(
            padding: EdgeInsets.all(pad),
            children: <Widget>[
              const MonoInput(
                placeholder: 'Search the marketplace…',
                prefix: MonoIcon(MonoIcons.search, size: 16),
              ),
              SizedBox(height: theme.spacing.md),
              const _Chips(),
              SizedBox(height: theme.spacing.lg),
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: <Widget>[
                  for (final item in _items)
                    SizedBox(
                      width: tileWidth,
                      child: MonoProductCard(
                        onPressed: () {},
                        media: AspectRatio(
                          aspectRatio: 1,
                          child: AppImage(asset: item.asset, seed: item.seed),
                        ),
                        title: Text(item.title),
                        description: Text(item.place),
                        price: MonoPriceTag(currency: 'GH₵', price: item.price),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips();

  static const List<String> _labels = <String>[
    'All',
    'Phones',
    'Furniture',
    'Fashion',
    'Food',
    'Plants',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        separatorBuilder: (_, _) => SizedBox(width: theme.spacing.sm),
        itemBuilder: (context, i) => IntrinsicWidth(
          child: MonoButton(
            variant: i == 0
                ? MonoButtonVariant.secondary
                : MonoButtonVariant.outline,
            size: MonoButtonSize.sm,
            onPressed: () {},
            child: Text(_labels[i]),
          ),
        ),
      ),
    );
  }
}

class _StoreNav extends StatelessWidget {
  const _StoreNav();

  @override
  Widget build(BuildContext context) {
    return MonoBottomNav(
      selectedIndex: 0,
      onSelected: (_) {},
      items: const <MonoBottomNavItem>[
        MonoBottomNavItem(icon: MonoIcons.grid, label: 'Browse'),
        MonoBottomNavItem(icon: MonoIcons.search, label: 'Search'),
        MonoBottomNavItem(icon: MonoIcons.bag, label: 'Cart'),
        MonoBottomNavItem(icon: MonoIcons.message, label: 'Inbox'),
        MonoBottomNavItem(icon: MonoIcons.user, label: 'You'),
      ],
    );
  }
}
