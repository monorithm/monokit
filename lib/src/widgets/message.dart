import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// The logical side of a chat message within a conversation.
enum MonoMessageAlign { start, end }

/// Makes a [MonoMessage]'s logical alignment available to message slots and
/// nested chat components.
class MonoMessageScope extends InheritedWidget {
  const MonoMessageScope({
    super.key,
    required this.align,
    required super.child,
  });

  final MonoMessageAlign align;

  static MonoMessageScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MonoMessageScope>();
  }

  @override
  bool updateShouldNotify(MonoMessageScope oldWidget) =>
      align != oldWidget.align;
}

/// A chat-message group with avatar, header, content, and footer slots.
///
/// [MonoMessage] is intentionally neutral about data models. Applications can
/// render plain text, rich markdown, attachments, or a [MonoBubble] in its
/// [child] slot without adapting their message domain objects first.
class MonoMessage extends StatelessWidget {
  const MonoMessage({
    super.key,
    required this.child,
    this.align = MonoMessageAlign.start,
    this.avatar,
    this.header,
    this.footer,
    this.padding,
    this.avatarGap,
    this.maxWidth,
    this.semanticLabel,
    this.liveRegion = false,
  }) : assert(maxWidth == null || maxWidth > 0);

  /// Main message content, typically a [MonoBubble].
  final Widget child;
  final MonoMessageAlign align;
  final Widget? avatar;
  final Widget? header;
  final Widget? footer;
  final EdgeInsetsGeometry? padding;
  final double? avatarGap;

  /// Caps the content column without imposing a fixed width.
  final double? maxWidth;
  final String? semanticLabel;

  /// Announces this group when its contents are inserted or updated.
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final isEnd = align == MonoMessageAlign.end;
    final messageSlots = <Widget>[
      ?header,
      if (header != null) SizedBox(height: theme.spacing.xs),
      child,
      if (footer != null) SizedBox(height: theme.spacing.xs),
      ?footer,
    ];
    final contentColumn = ConstrainedBox(
      constraints: maxWidth == null
          ? const BoxConstraints()
          : BoxConstraints(maxWidth: maxWidth!),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: messageSlots,
      ),
    );

    final group = avatar == null
        ? contentColumn
        : Row(
            mainAxisAlignment: isEnd
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: Directionality.of(context),
            children: isEnd
                ? <Widget>[
                    Flexible(fit: FlexFit.loose, child: contentColumn),
                    SizedBox(width: avatarGap ?? theme.spacing.md),
                    avatar!,
                  ]
                : <Widget>[
                    avatar!,
                    SizedBox(width: avatarGap ?? theme.spacing.md),
                    Flexible(fit: FlexFit.loose, child: contentColumn),
                  ],
          );

    return MonoMessageScope(
      align: align,
      child: Semantics(
        container: true,
        label: semanticLabel,
        liveRegion: liveRegion,
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(vertical: theme.spacing.xs),
          child: group,
        ),
      ),
    );
  }
}

/// A semantic content slot for a [MonoMessage].
class MonoMessageContent extends StatelessWidget {
  const MonoMessageContent({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DefaultTextStyle.merge(
        style: theme.typography.bodyMedium.copyWith(
          color: theme.colors.foreground,
        ),
        child: child,
      ),
    );
  }
}

/// A muted top metadata slot for a [MonoMessage].
class MonoMessageHeader extends StatelessWidget {
  const MonoMessageHeader({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final align =
        MonoMessageScope.maybeOf(context)?.align ?? MonoMessageAlign.start;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Align(
        alignment: align == MonoMessageAlign.end
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.mutedForeground,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A muted bottom metadata or action slot for a [MonoMessage].
class MonoMessageFooter extends StatelessWidget {
  const MonoMessageFooter({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final align =
        MonoMessageScope.maybeOf(context)?.align ?? MonoMessageAlign.start;
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Align(
        alignment: align == MonoMessageAlign.end
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: DefaultTextStyle.merge(
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.mutedForeground,
          ),
          child: child,
        ),
      ),
    );
  }
}
