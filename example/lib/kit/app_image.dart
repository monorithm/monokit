import 'package:monokit/monokit.dart';

/// An asset-backed image with a graceful, *designed* fallback.
///
/// While the real photography pipeline is being curated, most call sites pass a
/// [seed] only: [AppImage] then renders a deterministic procedural gradient
/// (never the old flat two-colour placeholder). When an [asset] is bundled it is
/// used instead, fading in over a skeleton, and still falling back to the
/// procedural art if the asset is missing — so the showcase looks intentional in
/// every state.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.asset,
    required this.seed,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.icon,
    this.label,
    this.onMediaCanvas = false,
  });

  /// Optional bundled asset path (e.g. `assets/images/products/chair.jpg`).
  final String? asset;

  /// Stable seed driving the procedural fallback's palette and pattern.
  final String seed;

  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Optional glyph drawn faintly over the procedural art.
  final MonoIconData? icon;

  /// Optional caption drawn over the procedural art.
  final String? label;

  /// When true, the procedural palette leans into the always-dark media canvas.
  final bool onMediaCanvas;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    final fallback = _ProceduralArt(
      seed: seed,
      icon: icon,
      label: label,
      onMediaCanvas: onMediaCanvas,
    );

    final Widget content = asset == null
        ? fallback
        : Image.asset(
            asset!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, _, _) => fallback,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync || frame != null) return child;
              return fallback;
            },
          );

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(width: width, height: height, child: content),
    );
  }
}

/// Deterministic gradient art derived from a seed — the dependency-free,
/// intentional stand-in for real photography.
class _ProceduralArt extends StatelessWidget {
  const _ProceduralArt({
    required this.seed,
    this.icon,
    this.label,
    this.onMediaCanvas = false,
  });

  final String seed;
  final MonoIconData? icon;
  final String? label;
  final bool onMediaCanvas;

  int get _hash {
    var h = 0;
    for (final unit in seed.codeUnits) {
      h = (h * 31 + unit) & 0x7fffffff;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final h = _hash;
    final hue = (h % 360).toDouble();
    final base = onMediaCanvas ? 0.32 : 0.62;
    final a = HSLColor.fromAHSL(1, hue, 0.42, base).toColor();
    final b = HSLColor.fromAHSL(1, (hue + 42) % 360, 0.48, base - 0.16).toColor();
    final onArt = theme.colors.onMedia;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[a, b],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // A soft radial highlight so the art reads as a surface, not a swatch.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  ((h >> 3) % 100) / 50 - 1,
                  ((h >> 7) % 100) / 50 - 1,
                ),
                radius: 1.1,
                colors: <Color>[
                  onArt.withValues(alpha: 0.18),
                  onArt.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          if (icon != null)
            Center(
              child: MonoIcon(
                icon!,
                size: 40,
                color: onArt.withValues(alpha: 0.55),
              ),
            ),
          if (label != null)
            Padding(
              padding: EdgeInsets.all(theme.spacing.md),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  label!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.mediaCaption.copyWith(color: onArt),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
