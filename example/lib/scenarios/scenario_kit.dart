import 'package:go_router/go_router.dart';
import 'package:monokit/monokit.dart';

/// Chrome for a scenario "app screen": a status-bar-aware header with an
/// optional back button and actions, a body, and an optional pinned bottom bar.
/// Scenarios render inside the shell's [DeviceCanvas], so pinning the device
/// switcher to Phone/Tablet frames them like a real app.
class ScenarioShell extends StatelessWidget {
  const ScenarioShell({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions = const <Widget>[],
    this.bottom,
    this.showBack = true,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget> actions;
  final Widget? bottom;
  final bool showBack;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    return ColoredBox(
      color: backgroundColor ?? theme.colors.page,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(
              theme.spacing.md,
              media.padding.top + theme.spacing.sm,
              theme.spacing.md,
              theme.spacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.colors.page,
              border: Border(bottom: BorderSide(color: theme.colors.separator)),
            ),
            child: Row(
              children: <Widget>[
                if (showBack)
                  Padding(
                    padding: EdgeInsets.only(right: theme.spacing.xs),
                    child: MonoButton(
                      variant: MonoButtonVariant.ghost,
                      size: MonoButtonSize.sm,
                      iconOnly: true,
                      semanticLabel: 'Back',
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/scenarios');
                        }
                      },
                      child: const MonoIcon(MonoIcons.chevronLeft),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.titleMedium,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.labelMedium.copyWith(
                            color: theme.colors.foregroundMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Expanded(child: body),
          if (bottom != null)
            Container(
              padding: EdgeInsets.fromLTRB(
                theme.spacing.md,
                theme.spacing.sm,
                theme.spacing.md,
                media.padding.bottom + theme.spacing.sm,
              ),
              decoration: BoxDecoration(
                color: theme.colors.page,
                border: Border(top: BorderSide(color: theme.colors.separator)),
              ),
              child: bottom,
            ),
        ],
      ),
    );
  }
}

/// A section label used inside scenario bodies.
class ScenarioLabel extends StatelessWidget {
  const ScenarioLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.sm),
      child: Text(
        text.toUpperCase(),
        style: theme.typography.labelMedium.copyWith(
          color: theme.colors.foregroundMuted,
        ),
      ),
    );
  }
}
