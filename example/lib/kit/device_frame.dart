import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

/// Monorithm is a mobile product, so the *blocks* (production-style screens) are
/// shown phone-first: on wide viewports they render inside a centred phone
/// frame; on compact viewports they go full-bleed. The frame scales down to fit
/// short viewports so it never overflows.
class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    super.key,
    required this.child,
    this.width = 402,
    this.height = 874,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < theme.breakpoints.medium) {
          return child; // compact: full-bleed
        }
        final available = constraints.maxHeight - theme.spacing.giant;
        final scale = available < height ? (available / height) : 1.0;
        return Center(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing.xl),
            child: Transform.scale(
              scale: scale.clamp(0.4, 1.0),
              child: MonoSurface(
                tier: MonoElevationTier.e3,
                padding: EdgeInsets.all(theme.spacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radii.xl + 12),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: MediaQuery(
                      // The framed screen believes it has a status-bar inset,
                      // so scrim/immersive modes read realistically.
                      data: MediaQuery.of(context).copyWith(
                        padding: const EdgeInsets.only(top: 44, bottom: 24),
                        viewPadding: const EdgeInsets.only(top: 44, bottom: 24),
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
