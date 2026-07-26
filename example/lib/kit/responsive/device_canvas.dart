import 'package:monokit/monokit.dart';

import '../../container/app_scope.dart';
import 'viewport_controller.dart';

/// Wraps content in the device frame selected by the global [ViewportController].
///
/// In [ViewportMode.fluid] it is a pass-through — the real window drives layout.
/// In a framed mode it renders a bezelled canvas at the mode's logical size with
/// an overridden [MediaQuery] (including a realistic status-bar inset for phones),
/// scaling the whole frame down only when the pane is too small to hold it — a
/// full-fidelity device, never the old `Transform.scale` shrink of live content.
class DeviceCanvas extends StatelessWidget {
  const DeviceCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.viewportOf(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final mode = controller.mode;
        if (!mode.isFramed) return child;
        return _FramedDevice(mode: mode, child: child);
      },
    );
  }
}

class _FramedDevice extends StatelessWidget {
  const _FramedDevice({required this.mode, required this.child});

  final ViewportMode mode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final media = MediaQuery.of(context);
    final width = mode.width!;
    final height = mode.height!;
    final isPhone = mode == ViewportMode.phone;
    final inset = isPhone
        ? const EdgeInsets.only(top: 44, bottom: 24)
        : EdgeInsets.zero;

    return ColoredBox(
      color: theme.colors.muted,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pad = theme.spacing.xl;
          final maxW = constraints.maxWidth - pad * 2;
          final maxH = constraints.maxHeight - pad * 2;
          final scale = <double>[
            1.0,
            if (maxW > 0) maxW / width,
            if (maxH > 0) maxH / height,
          ].reduce((a, b) => a < b ? a : b).clamp(0.3, 1.0);

          return Center(
            child: Transform.scale(
              scale: scale,
              child: MonoSurface(
                tier: MonoElevationTier.e3,
                padding: EdgeInsets.all(theme.spacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radii.xl + 12),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: MediaQuery(
                      data: media.copyWith(
                        size: Size(width, height),
                        padding: inset,
                        viewPadding: inset,
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
