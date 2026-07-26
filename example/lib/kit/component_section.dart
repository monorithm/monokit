import 'package:monokit/monokit.dart';

/// The self-documentation engine. Every component demo is a [ComponentSection]:
/// a titled preview inside a card, the widget name as a badge, and an optional
/// code peek. This is what makes the gallery a reference rather than a vibe.
class ComponentSection extends StatelessWidget {
  const ComponentSection({
    super.key,
    required this.title,
    required this.widgetName,
    required this.child,
    this.description,
    this.code,
  });

  final String title;
  final String widgetName;
  final String? description;
  final String? code;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final title0 = Text(title, style: theme.typography.titleMedium);
              final badge = MonoBadge(
                variant: MonoBadgeVariant.outline,
                child: Text(widgetName),
              );
              // Stack title over badge when there isn't room for both on one
              // line — the widget names can be long, and this never overflows.
              if (constraints.maxWidth < 460) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    title0,
                    SizedBox(height: theme.spacing.xs),
                    badge,
                  ],
                );
              }
              return Row(
                children: <Widget>[
                  Expanded(child: title0),
                  SizedBox(width: theme.spacing.sm),
                  badge,
                ],
              );
            },
          ),
          if (description != null) ...<Widget>[
            SizedBox(height: theme.spacing.xs),
            Text(
              description!,
              style: theme.typography.bodyMedium.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
          SizedBox(height: theme.spacing.md),
          MonoCard(
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.lg),
              child: Align(alignment: Alignment.centerLeft, child: child),
            ),
          ),
          if (code != null) ...<Widget>[
            SizedBox(height: theme.spacing.sm),
            CodePeek(code: code!),
          ],
        ],
      ),
    );
  }
}

/// Renders a builder across every combination of two axes — the "complete
/// matrix" rule (e.g. Button variant × size).
class VariantMatrix<R, C> extends StatelessWidget {
  const VariantMatrix({
    super.key,
    required this.rows,
    required this.cols,
    required this.builder,
    this.rowLabel,
  });

  final List<R> rows;
  final List<C> cols;
  final Widget Function(R row, C col) builder;
  final String Function(R row)? rowLabel;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final r in rows) ...<Widget>[
          if (rowLabel != null)
            Padding(
              padding: EdgeInsets.only(bottom: theme.spacing.xs),
              child: Text(
                rowLabel!(r),
                style: theme.typography.labelMedium.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          Wrap(
            spacing: theme.spacing.md,
            runSpacing: theme.spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[for (final c in cols) builder(r, c)],
          ),
          SizedBox(height: theme.spacing.lg),
        ],
      ],
    );
  }
}

/// A small labelled demo tile — used to show a component in a named state.
class DemoTile extends StatelessWidget {
  const DemoTile({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        child,
        SizedBox(height: theme.spacing.xs),
        Text(
          label,
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Reveals the composing snippet in a sheet, using the mono/tabular register.
class CodePeek extends StatelessWidget {
  const CodePeek({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return MonoSheet(
      trigger: MonoButton(
        variant: MonoButtonVariant.link,
        size: MonoButtonSize.sm,
        leading: const MonoIcon(MonoIcons.grid, size: 14),
        child: const Text('View code'),
      ),
      child: MonoSheetContent(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.md),
          child: Text(code, style: theme.typography.code),
        ),
      ),
    );
  }
}
