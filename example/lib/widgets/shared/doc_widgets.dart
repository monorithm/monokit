import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

/// Constrains a documentation page to a readable desktop and mobile width and
/// scrolls its own content.
///
/// The page is self-scrolling because the router's [ShellRoute] hosts each page
/// inside a Navigator, which cannot itself be wrapped in a scroll view by the
/// shell.
class DocPageContent extends StatelessWidget {
  const DocPageContent({
    super.key,
    required this.children,
    this.maxWidth = 960,
  });

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(theme.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A documentation card containing a component description, live demo, and
/// a compact API usage sketch.
class DocSection extends StatelessWidget {
  const DocSection({
    super.key,
    required this.name,
    required this.description,
    required this.child,
    this.code,
  });

  final String name;
  final String description;
  final Widget child;
  final String? code;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.lg),
      child: MonoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MonoCardHeader(
              title: Semantics(header: true, child: Text(name)),
              description: Text(description),
              action: MonoBadge(
                variant: MonoBadgeVariant.outline,
                size: MonoBadgeSize.sm,
                child: const Text('Live demo'),
              ),
            ),
            const MonoSeparator(),
            MonoCardContent(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.muted,
                  borderRadius: BorderRadius.circular(theme.radii.md),
                ),
                child: Padding(
                  padding: EdgeInsets.all(theme.spacing.lg),
                  child: child,
                ),
              ),
            ),
            if (code != null) ...<Widget>[
              const MonoSeparator(),
              MonoCardFooter(
                child: DefaultTextStyle.merge(
                  style: theme.typography.labelMedium.copyWith(
                    color: theme.colors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                  child: Text(code!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DocPageTitle extends StatelessWidget {
  const DocPageTitle({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(title, style: theme.typography.displayMedium),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            description,
            style: theme.typography.bodyLarge.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class DocGroupTitle extends StatelessWidget {
  const DocGroupTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.md),
      child: Semantics(
        header: true,
        child: Text(title, style: theme.typography.headlineMedium),
      ),
    );
  }
}
