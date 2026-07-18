import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../kit/component_section.dart';
import '../kit/sample.dart';

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
        ComponentSection(
          title: 'Price tag',
          widgetName: 'MonoPriceTag',
          description: 'Tabular figures; a struck-through compareAt announces '
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
                child: SamplePhoto(seed: 1),
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
          title: 'Order status',
          widgetName: 'MonoOrderStatus',
          description: 'Honest order state, driven by the command phase.',
          child: MonoOrderStatus(
            phase: MonoCommandPhase.accepted,
            label: const Text('Processing your order'),
            progress: 0.6,
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
                Text('$_qty item${_qty == 1 ? '' : 's'}',
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    )),
                MonoPriceTag(
                  currency: 'GH₵',
                  price: '${4800 * _qty}',
                ),
              ],
            ),
            action: MonoButton(
              onPressed: () {},
              child: const Text('Checkout'),
            ),
          ),
        ),
      ],
    );
  }
}
