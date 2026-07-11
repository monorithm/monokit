import 'package:flutter/widgets.dart';

import '../theme/monokit_theme.dart';

/// Available dimensions for a [MonoAvatar].
enum MonoAvatarSize { xs, sm, md, lg, xl }

/// Available clipping treatments for a [MonoAvatar].
enum MonoAvatarShape { circle, rounded, square }

/// An image, initials, or custom-content identity marker.
class MonoAvatar extends StatelessWidget {
  const MonoAvatar({
    super.key,
    this.image,
    this.imageUrl,
    this.initials,
    this.name,
    this.child,
    this.size = MonoAvatarSize.md,
    this.shape = MonoAvatarShape.circle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.fit = BoxFit.cover,
    this.filterQuality = FilterQuality.medium,
    this.semanticLabel,
    this.imageErrorBuilder,
  }) : assert(
         image == null || imageUrl == null,
         'Use image or imageUrl, not both.',
       );

  /// Creates an avatar whose fallback always shows [initials].
  const MonoAvatar.initials(
    String initials, {
    Key? key,
    MonoAvatarSize size = MonoAvatarSize.md,
    MonoAvatarShape shape = MonoAvatarShape.circle,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    String? semanticLabel,
  }) : this(
         key: key,
         initials: initials,
         size: size,
         shape: shape,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
         borderColor: borderColor,
         semanticLabel: semanticLabel,
       );

  /// Creates an avatar from an [ImageProvider], with initials/name fallback.
  const MonoAvatar.image(
    ImageProvider<Object> image, {
    Key? key,
    String? initials,
    String? name,
    MonoAvatarSize size = MonoAvatarSize.md,
    MonoAvatarShape shape = MonoAvatarShape.circle,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BoxFit fit = BoxFit.cover,
    FilterQuality filterQuality = FilterQuality.medium,
    String? semanticLabel,
    ImageErrorWidgetBuilder? imageErrorBuilder,
  }) : this(
         key: key,
         image: image,
         initials: initials,
         name: name,
         size: size,
         shape: shape,
         backgroundColor: backgroundColor,
         foregroundColor: foregroundColor,
         borderColor: borderColor,
         fit: fit,
         filterQuality: filterQuality,
         semanticLabel: semanticLabel,
         imageErrorBuilder: imageErrorBuilder,
       );

  /// Creates an avatar from a network image URL.
  factory MonoAvatar.network(
    String imageUrl, {
    Key? key,
    String? initials,
    String? name,
    MonoAvatarSize size = MonoAvatarSize.md,
    MonoAvatarShape shape = MonoAvatarShape.circle,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
    BoxFit fit = BoxFit.cover,
    FilterQuality filterQuality = FilterQuality.medium,
    String? semanticLabel,
    ImageErrorWidgetBuilder? imageErrorBuilder,
  }) {
    return MonoAvatar(
      key: key,
      imageUrl: imageUrl,
      initials: initials,
      name: name,
      size: size,
      shape: shape,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      fit: fit,
      filterQuality: filterQuality,
      semanticLabel: semanticLabel,
      imageErrorBuilder: imageErrorBuilder,
    );
  }

  final ImageProvider<Object>? image;
  final String? imageUrl;
  final String? initials;
  final String? name;
  final Widget? child;
  final MonoAvatarSize size;
  final MonoAvatarShape shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final BoxFit fit;
  final FilterQuality filterQuality;
  final String? semanticLabel;
  final ImageErrorWidgetBuilder? imageErrorBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final dimension = switch (size) {
      MonoAvatarSize.xs => theme.spacing.xxl,
      MonoAvatarSize.sm => theme.spacing.xxxl,
      MonoAvatarSize.md => theme.spacing.huge,
      MonoAvatarSize.lg => theme.spacing.giant,
      MonoAvatarSize.xl => theme.spacing.giant + theme.spacing.lg,
    };
    final borderRadius = switch (shape) {
      MonoAvatarShape.circle => BorderRadius.circular(theme.radii.full),
      MonoAvatarShape.rounded => BorderRadius.circular(theme.radii.lg),
      MonoAvatarShape.square => BorderRadius.zero,
    };

    final avatar = SizedBox.square(
      dimension: dimension,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.colors.muted,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor ?? theme.colors.border),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: _buildContents(context, dimension),
        ),
      ),
    );

    return Semantics(
      image: true,
      label: semanticLabel ?? name ?? initials ?? 'Avatar',
      child: ExcludeSemantics(child: avatar),
    );
  }

  Widget _buildContents(BuildContext context, double dimension) {
    if (image != null) {
      return Image(
        image: image!,
        width: dimension,
        height: dimension,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) {
          return imageErrorBuilder?.call(context, error, stackTrace) ??
              _buildFallback(context, dimension);
        },
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: dimension,
        height: dimension,
        fit: fit,
        filterQuality: filterQuality,
        errorBuilder: (context, error, stackTrace) {
          return imageErrorBuilder?.call(context, error, stackTrace) ??
              _buildFallback(context, dimension);
        },
      );
    }
    return _buildFallback(context, dimension);
  }

  Widget _buildFallback(BuildContext context, double dimension) {
    final theme = MonokitTheme.of(context);
    final fallbackInitials = initials ?? _initialsFromName(name);
    return Center(
      child: DefaultTextStyle.merge(
        style: theme.typography.labelLarge.copyWith(
          color: foregroundColor ?? theme.colors.mutedForeground,
          fontSize: dimension / 2.5,
          fontWeight: FontWeight.w600,
        ),
        child: child ?? Text(fallbackInitials),
      ),
    );
  }

  static String _initialsFromName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '';
    }
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return _firstRune(parts.first).toUpperCase();
    }
    return '${_firstRune(parts.first)}${_firstRune(parts.last)}'.toUpperCase();
  }

  static String _firstRune(String value) =>
      String.fromCharCode(value.runes.first);
}
