import 'package:monokit/monokit.dart';

/// A fixed breakpoint pane for [ViewportRow].
class ViewportSize {
  const ViewportSize(this.label, this.width);
  final String label;
  final double width;
}

const List<ViewportSize> kDefaultViewports = <ViewportSize>[
  ViewportSize('Compact', 375),
  ViewportSize('Medium', 768),
  ViewportSize('Expanded', 1280),
];

/// Renders the same component at several breakpoints *simultaneously*, in
/// adjacent framed panes, so reflow differences are visible at a glance without
/// interaction. Each pane gets its own overridden [MediaQuery] and builds a
/// fresh subtree (via [builder]) so stateful demos stay independent.
class ViewportRow extends StatelessWidget {
  const ViewportRow({
    super.key,
    required this.builder,
    this.viewports = kDefaultViewports,
    this.height = 480,
  });

  final WidgetBuilder builder;
  final List<ViewportSize> viewports;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: theme.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final viewport in viewports)
            Padding(
              padding: EdgeInsets.only(right: theme.spacing.lg),
              child: _Pane(viewport: viewport, height: height, builder: builder),
            ),
        ],
      ),
    );
  }
}

class _Pane extends StatelessWidget {
  const _Pane({
    required this.viewport,
    required this.height,
    required this.builder,
  });

  final ViewportSize viewport;
  final double height;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: theme.spacing.xs),
          child: Row(
            children: <Widget>[
              Text(viewport.label, style: theme.typography.labelLarge),
              SizedBox(width: theme.spacing.sm),
              Text(
                '${viewport.width.round()}pt',
                style: theme.typography.mono.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: viewport.width,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.background,
              borderRadius: BorderRadius.circular(theme.radii.md),
              border: Border.all(color: theme.colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radii.md),
              child: MediaQuery(
                data: media.copyWith(
                  size: Size(viewport.width, height),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: Builder(builder: builder),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
