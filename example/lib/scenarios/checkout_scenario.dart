import 'package:monokit_ui/monokit_ui.dart';

import '../kit/app_image.dart';
import '../kit/asset_catalog.dart';
import 'scenario_kit.dart';

class CheckoutScenario extends StatefulWidget {
  const CheckoutScenario({super.key});

  @override
  State<CheckoutScenario> createState() => _CheckoutScenarioState();
}

class _CheckoutScenarioState extends State<CheckoutScenario> {
  int _chairQty = 1;
  int _lampQty = 1;
  String? _delivery = 'delivery';

  int get _subtotal => 2100 * _chairQty + 540 * _lampQty;
  int get _fee => _delivery == 'delivery' ? 20 : 0;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ScenarioShell(
      title: 'Checkout',
      subtitle: '2 items',
      body: ListView(
        padding: EdgeInsets.all(theme.spacing.lg),
        children: <Widget>[
          const ScenarioLabel('Your cart'),
          _CartLine(
            asset: AppAssets.chair,
            seed: 'chair',
            title: 'Linen lounge chair',
            unit: 2100,
            qty: _chairQty,
            onQty: (v) => setState(() => _chairQty = v),
          ),
          SizedBox(height: theme.spacing.md),
          _CartLine(
            asset: AppAssets.lamp,
            seed: 'lamp',
            title: 'Arc floor lamp',
            unit: 540,
            qty: _lampQty,
            onQty: (v) => setState(() => _lampQty = v),
          ),
          SizedBox(height: theme.spacing.xl),
          const ScenarioLabel('Delivery'),
          MonoRadioGroup<String>(
            value: _delivery,
            onChanged: (v) => setState(() => _delivery = v),
            options: const <MonoRadioOption<String>>[
              MonoRadioOption(value: 'pickup', label: Text('Pickup — free')),
              MonoRadioOption(
                value: 'delivery',
                label: Text('Delivery within Accra — GH₵ 20'),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.xl),
          const ScenarioLabel('Summary'),
          _SummaryRow(label: 'Subtotal', value: 'GH₵ $_subtotal'),
          _SummaryRow(
            label: 'Delivery',
            value: _fee == 0 ? 'Free' : 'GH₵ $_fee',
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: theme.spacing.sm),
            child: const MonoSeparator(),
          ),
          _SummaryRow(
            label: 'Total',
            value: 'GH₵ ${_subtotal + _fee}',
            bold: true,
          ),
        ],
      ),
      bottom: MonoCartBar(
        summary: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Total',
              style: theme.typography.labelMedium.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            MonoPriceTag(currency: 'GH₵', price: '${_subtotal + _fee}'),
          ],
        ),
        action: MonoButton(
          onPressed: () {},
          leading: const MonoIcon(MonoIcons.check, size: 16),
          child: const Text('Place order'),
        ),
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.asset,
    required this.seed,
    required this.title,
    required this.unit,
    required this.qty,
    required this.onQty,
  });

  final String asset;
  final String seed;
  final String title;
  final int unit;
  final int qty;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoCard(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.md),
        child: Row(
          children: <Widget>[
            AppImage(
              asset: asset,
              seed: seed,
              width: 56,
              height: 56,
              borderRadius: BorderRadius.circular(theme.radii.md),
            ),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.labelLarge,
                  ),
                  SizedBox(height: theme.spacing.xs),
                  MonoPriceTag(currency: 'GH₵', price: '${unit * qty}'),
                ],
              ),
            ),
            SizedBox(width: theme.spacing.sm),
            MonoQuantityStepper(value: qty, minimum: 1, onChanged: onQty),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final style = bold
        ? theme.typography.titleMedium
        : theme.typography.bodyMedium.copyWith(
            color: theme.colors.mutedForeground,
          );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: style),
          Text(value, style: theme.typography.tabular(style)),
        ],
      ),
    );
  }
}
