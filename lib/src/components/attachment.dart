import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../states/mono_states_controller.dart';
import '../theme/monokit_theme.dart';

/// Layout treatments for a [MonoAttachment].
enum MonoAttachmentVariant { file, image, compact }

/// A compact attachment surface for files, media previews, and custom content.
///
/// Supplying [child] gives complete control over the inner layout. Otherwise,
/// [name], [description], [thumbnail], [leading], and [trailing] compose a
/// useful file-style row.
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
  }) : assert(
         child != null || name != null || thumbnail != null || leading != null,
         'Provide child or attachment metadata.',
       ),
       assert(maxWidth == null || maxWidth > 0);

  /// A shorthand for a media attachment with a larger [thumbnail].
  const MonoAttachment.image({
    super.key,
    required this.thumbnail,
    this.name,
    this.description,
    this.trailing,
    this.padding,
    this.maxWidth,
    this.onPressed,
    this.statesController,
    this.semanticLabel,
  }) : child = null,
       leading = null,
       variant = MonoAttachmentVariant.image;

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

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final label = semanticLabel ?? name ?? 'Attachment';

    Widget buildVisual(Set<MonoState> states) {
      final isHovered = states.contains(MonoState.hovered);
      final isPressed = states.contains(MonoState.pressed);
      final background = isPressed || isHovered
          ? theme.colors.accent
          : variant == MonoAttachmentVariant.image
          ? theme.colors.card
          : theme.colors.muted;
      return ConstrainedBox(
        constraints: maxWidth == null
            ? const BoxConstraints()
            : BoxConstraints(maxWidth: maxWidth!),
        child: AnimatedContainer(
          duration: MediaQuery.maybeOf(context)?.disableAnimations ?? false
              ? Duration.zero
              : theme.motion.fast,
          curve: theme.motion.curve,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(theme.radii.md),
            border: Border.all(color: theme.colors.border),
          ),
          padding: padding ?? EdgeInsets.all(theme.spacing.sm),
          child: DefaultTextStyle.merge(
            style: theme.typography.bodyMedium.copyWith(
              color: theme.colors.foreground,
            ),
            child: child ?? _buildMetadata(context),
          ),
        ),
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
      child: (context, states) => buildVisual(states),
    );
  }

  Widget _buildMetadata(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final preview = thumbnail ?? leading;
    final previewSize = switch (variant) {
      MonoAttachmentVariant.file => theme.spacing.xxxl,
      MonoAttachmentVariant.image => theme.spacing.giant + theme.spacing.xxl,
      MonoAttachmentVariant.compact => theme.spacing.xxl,
    };
    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (name != null)
          DefaultTextStyle.merge(
            style: theme.typography.labelLarge.copyWith(
              color: theme.colors.foreground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: Text(name!),
          ),
        if (description != null) ...<Widget>[
          if (name != null) SizedBox(height: theme.spacing.xs / 2),
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
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (preview != null) ...<Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(theme.radii.sm),
            child: SizedBox.square(dimension: previewSize, child: preview),
          ),
          SizedBox(width: theme.spacing.sm),
        ],
        if (name != null || description != null)
          Flexible(fit: FlexFit.loose, child: details),
        if (trailing != null) ...<Widget>[
          if (name != null || description != null)
            SizedBox(width: theme.spacing.sm),
          trailing!,
        ],
      ],
    );
  }
}
