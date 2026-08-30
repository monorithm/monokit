import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_motion.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// Layout treatments for a [MonoAttachment].
enum MonoAttachmentVariant { file, image, link, compact }

/// A rich attachment surface that previews content *as much as possible* —
/// large image previews, document cards, and link unfurls — the way a
/// conversation app does.
///
/// Use the named constructors for the common shapes:
/// * [MonoAttachment.image] — a large media preview with an optional caption.
/// * [MonoAttachment.document] — a file card with icon, name, and metadata.
/// * [MonoAttachment.link] — a link unfurl with optional image, title, and domain.
///
/// The default constructor still composes a compact file-style row, and [child]
/// gives full control.
class MonoAttachment extends StatelessWidget {
  const MonoAttachment({
    super.key,
    this.child,
    this.name,
    this.description,
    this.thumbnail,
    this.leading,
    this.trailing,
    this.variant = MonoAttachmentVariant.file,
    this.padding,
    this.maxWidth,
    this.onPressed,
    this.statesController,
    this.semanticLabel,
    this.title,
    this.domain,
    this.meta,
    this.aspectRatio,
  }) : assert(
         child != null ||
             name != null ||
             thumbnail != null ||
             leading != null ||
             title != null,
         'Provide child or attachment metadata.',
       ),
       assert(maxWidth == null || maxWidth > 0);

  /// A large image/media preview with an optional caption below.
  const MonoAttachment.image({
    super.key,
    required this.thumbnail,
    Widget? caption,
    this.aspectRatio = 4 / 3,
    this.maxWidth = 280,
    this.onPressed,
    this.statesController,
    this.semanticLabel,
  }) : description = caption,
       variant = MonoAttachmentVariant.image,
       child = null,
       name = null,
       leading = null,
       trailing = null,
       padding = null,
       title = null,
       domain = null,
       meta = null;

  /// A document card: a document icon, the file [name], and [meta]
  /// (e.g. `'PDF · 2.8 MB'`), with a download affordance.
  const MonoAttachment.document({
    super.key,
    required this.name,
    this.meta,
    this.maxWidth = 300,
    this.onPressed,
    this.trailing,
    this.statesController,
    this.semanticLabel,
  }) : variant = MonoAttachmentVariant.file,
       child = null,
       description = null,
       thumbnail = null,
       leading = null,
       padding = null,
       title = null,
       domain = null,
       aspectRatio = null;

  /// A link unfurl: optional preview [thumbnail], a [title], an optional
  /// [description] snippet, and the [domain].
  const MonoAttachment.link({
    super.key,
    required this.domain,
    required this.title,
    this.description,
    this.thumbnail,
    this.maxWidth = 300,
    this.onPressed,
    this.statesController,
    this.semanticLabel,
  }) : variant = MonoAttachmentVariant.link,
       child = null,
       name = null,
       leading = null,
       trailing = null,
       padding = null,
       meta = null,
       aspectRatio = null;

  final Widget? child;
  final String? name;
  final Widget? description;
  final Widget? thumbnail;
  final Widget? leading;
  final Widget? trailing;
  final MonoAttachmentVariant variant;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final VoidCallback? onPressed;
  final MonoStatesController? statesController;
  final String? semanticLabel;
  final String? title;
  final String? domain;
  final String? meta;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel ?? name ?? title ?? 'Attachment';

    Widget buildVisual(Set<MonoState> states) {
      final visual =
          child ??
          switch (variant) {
            MonoAttachmentVariant.image => _buildImage(context),
            MonoAttachmentVariant.link => _buildLink(context, states),
            MonoAttachmentVariant.file ||
            MonoAttachmentVariant.compact => _buildFile(context, states),
          };
      return ConstrainedBox(
        constraints: maxWidth == null
            ? const BoxConstraints()
            : BoxConstraints(maxWidth: maxWidth!),
        child: visual,
      );
    }

    if (onPressed == null) {
      return Semantics(
        container: true,
        label: label,
        child: buildVisual(const <MonoState>{}),
      );
    }
    return MonoPressable(
      onPressed: onPressed,
      statesController: statesController,
      semanticLabel: label,
      focusRing: true,
      child: (context, states) => buildVisual(states),
    );
  }

  // --- Image preview ---------------------------------------------------------
  Widget _buildImage(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = AspectRatio(
      aspectRatio: aspectRatio ?? 4 / 3,
      child: ColoredBox(color: theme.colors.mediaCanvas, child: thumbnail),
    );
    if (description == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: media,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.circular(theme.radii.lg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            media,
            Padding(
              padding: EdgeInsets.all(theme.spacing.sm),
              child: DefaultTextStyle.merge(
                style: theme.typography.bodyMedium.copyWith(
                  color: theme.colors.foreground,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                child: description!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Document card ---------------------------------------------------------
  Widget _buildFile(BuildContext context, Set<MonoState> states) {
    final theme = MonokitTheme.of(context);
    final active =
        states.contains(MonoState.hovered) ||
        states.contains(MonoState.pressed);
    final preview = thumbnail ?? leading;
    return _surface(
      context,
      active: active,
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.spacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (preview != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(theme.radii.sm),
                child: SizedBox.square(
                  dimension: theme.spacing.giant,
                  child: preview,
                ),
              )
            else
              _iconTile(context, MonoIcons.document),
            SizedBox(width: theme.spacing.sm),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (name != null)
                    Text(
                      name!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.labelLarge.copyWith(
                        color: theme.colors.foreground,
                      ),
                    ),
                  if (meta != null || description != null) ...<Widget>[
                    SizedBox(height: theme.spacing.xs / 2),
                    DefaultTextStyle.merge(
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: meta != null ? Text(meta!) : description!,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: theme.spacing.sm),
            trailing ??
                MonoIcon(
                  MonoIcons.download,
                  color: theme.colors.mutedForeground,
                ),
          ],
        ),
      ),
    );
  }

  // --- Link unfurl -----------------------------------------------------------
  Widget _buildLink(BuildContext context, Set<MonoState> states) {
    final theme = MonokitTheme.of(context);
    final active =
        states.contains(MonoState.hovered) ||
        states.contains(MonoState.pressed);
    return _surface(
      context,
      active: active,
      clip: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (thumbnail != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: theme.colors.mediaCanvas,
                child: thumbnail,
              ),
            ),
          Padding(
            padding: EdgeInsets.all(theme.spacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MonoIcon(
                      MonoIcons.link,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                    SizedBox(width: theme.spacing.xs),
                    Flexible(
                      child: Text(
                        domain ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.labelMedium.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: theme.spacing.xs),
                Text(
                  title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.labelLarge.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
                if (description != null) ...<Widget>[
                  SizedBox(height: theme.spacing.xs / 2),
                  DefaultTextStyle.merge(
                    style: theme.typography.labelMedium.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: description!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTile(BuildContext context, MonoIconData icon) {
    final theme = MonokitTheme.of(context);
    return Container(
      width: theme.spacing.giant,
      height: theme.spacing.giant,
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(theme.radii.sm),
      ),
      alignment: Alignment.center,
      child: MonoIcon(icon, color: theme.colors.mutedForeground),
    );
  }

  Widget _surface(
    BuildContext context, {
    required Widget child,
    required bool active,
    bool clip = false,
  }) {
    final theme = MonokitTheme.of(context);
    final decorated = AnimatedContainer(
      duration: MonokitMotion.noAnimation(context)
          ? Duration.zero
          : theme.motion.fast,
      curve: theme.motion.standard,
      decoration: BoxDecoration(
        color: active ? theme.colors.muted : theme.colors.card,
        borderRadius: BorderRadius.circular(theme.radii.md),
      ),
      child: child,
    );
    return clip
        ? ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.md),
            child: decorated,
          )
        : decorated;
  }
}
