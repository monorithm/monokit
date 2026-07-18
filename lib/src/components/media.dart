import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../primitives/mono_surfaces.dart';
import '../theme/monokit_theme.dart';
import 'badge.dart';
import 'button.dart';
import 'mono_icon.dart';

abstract interface class MonoVideoController {
  ValueListenable<bool> get isPlaying;
  ValueListenable<Duration> get position;
  Duration? get duration;
  Widget buildView(BuildContext context);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
}

abstract interface class MonoPlaybackController {
  ValueListenable<bool> get isPlaying;
  ValueListenable<Duration> get position;
  Duration? get duration;
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
}

abstract interface class MonoRecordingController {
  ValueListenable<bool> get isRecording;
  ValueListenable<Duration> get elapsed;
  Future<void> start();
  Future<void> stop();
  Future<void> cancel();
}

abstract interface class MonoCameraController {
  ValueListenable<bool> get isReady;
  Widget buildPreview(BuildContext context);
  Future<void> capture();
}

abstract interface class MonoDocumentController {
  int get pageCount;
  Widget buildPage(BuildContext context, int index);
  String? semanticLabelForPage(int index);
}

class MonoMediaSurface extends StatelessWidget {
  const MonoMediaSurface({
    super.key,
    required this.child,
    this.overlay,
    this.semanticLabel,
    this.aspectRatio,
  });
  final Widget child;
  final Widget? overlay;
  final String? semanticLabel;
  final double? aspectRatio;
  @override
  Widget build(BuildContext context) {
    final body = Semantics(
      label: semanticLabel,
      image: true,
      child: ColoredBox(
        color: MonokitTheme.of(context).colors.mediaCanvas,
        child: Stack(fit: StackFit.expand, children: <Widget>[child, ?overlay]),
      ),
    );
    return aspectRatio == null
        ? body
        : AspectRatio(aspectRatio: aspectRatio!, child: body);
  }
}

class MonoVideoSurface extends StatelessWidget {
  const MonoVideoSurface({
    super.key,
    required this.controller,
    this.overlay,
    this.semanticLabel = 'Video',
  });
  final MonoVideoController controller;
  final Widget? overlay;
  final String semanticLabel;
  @override
  Widget build(BuildContext context) => MonoMediaSurface(
    semanticLabel: semanticLabel,
    overlay: overlay,
    child: controller.buildView(context),
  );
}

class MonoFeedPager extends StatelessWidget {
  const MonoFeedPager({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: controller,
    scrollDirection: Axis.vertical,
    itemCount: itemCount,
    itemBuilder: itemBuilder,
    onPageChanged: onPageChanged,
  );
}

class MonoActionRail extends StatelessWidget {
  const MonoActionRail({super.key, required this.actions});
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Semantics(
      container: true,
      label: 'Media actions',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            actions
                .expand((a) => <Widget>[a, SizedBox(height: t.spacing.md)])
                .toList()
              ..removeLast(),
      ),
    );
  }
}

class MonoLiveBadge extends StatelessWidget {
  const MonoLiveBadge({super.key, this.label = 'LIVE'});
  final String label;
  @override
  Widget build(BuildContext context) => MonoBadge(
    variant: MonoBadgeVariant.live,
    semanticLabel: 'Live',
    child: Text(label),
  );
}

class MonoPresence extends StatelessWidget {
  const MonoPresence({super.key, required this.child, this.online = true});
  final Widget child;
  final bool online;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: Semantics(
            label: online ? 'Online' : 'Offline',
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: online ? t.colors.success : t.colors.mutedForeground,
                border: Border.all(color: t.colors.background, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MonoWaveform extends StatelessWidget {
  const MonoWaveform({
    super.key,
    required this.amplitudes,
    this.progress = 0,
    this.height = 32,
  });
  final List<double> amplitudes;
  final double progress, height;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Audio waveform',
    value: '${(progress.clamp(0, 1) * 100).round()}%',
    child: CustomPaint(
      size: Size(double.infinity, height),
      painter: _WaveformPainter(
        amplitudes,
        progress.clamp(0, 1),
        MonokitTheme.of(context).colors,
      ),
    ),
  );
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter(this.values, this.progress, this.colors);
  final List<double> values;
  final double progress;
  final dynamic colors;
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final step = size.width / values.length;
    final muted = Paint()..color = colors.mutedForeground;
    final active = Paint()..color = colors.primary;
    for (var i = 0; i < values.length; i++) {
      final h = values[i].clamp(0, 1) * size.height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset((i + .5) * step, size.height / 2),
            width: (step * .45).clamp(1, 4),
            height: h,
          ),
          const Radius.circular(2),
        ),
        i / values.length <= progress ? active : muted,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.values != values || old.progress != progress || old.colors != colors;
}

class MonoVoiceNote extends StatelessWidget {
  const MonoVoiceNote({
    super.key,
    required this.controller,
    required this.amplitudes,
    this.semanticLabel = 'Voice note',
  });
  final MonoPlaybackController controller;
  final List<double> amplitudes;
  final String semanticLabel;
  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: ValueListenableBuilder<bool>(
      valueListenable: controller.isPlaying,
      builder: (context, playing, _) => Row(
        children: <Widget>[
          MonoButton.icon(
            icon: MonoIcon(playing ? MonoIcons.pause : MonoIcons.play),
            semanticLabel: playing ? 'Pause' : 'Play',
            onPressed: playing ? controller.pause : controller.play,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<Duration>(
              valueListenable: controller.position,
              builder: (context, position, _) {
                final total = controller.duration?.inMilliseconds ?? 0;
                return MonoWaveform(
                  amplitudes: amplitudes,
                  progress: total == 0 ? 0 : position.inMilliseconds / total,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class MonoCameraShutter extends StatelessWidget {
  const MonoCameraShutter({
    super.key,
    required this.onPressed,
    this.semanticLabel = 'Capture',
  });
  final VoidCallback? onPressed;
  final String semanticLabel;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: MonoPressable(
        onPressed: onPressed,
        child: (context, states) => Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: t.colors.onMedia,
            border: Border.all(color: t.colors.glassBorder, width: 6),
          ),
        ),
      ),
    );
  }
}

class MonoCaptureBar extends StatelessWidget {
  const MonoCaptureBar({
    super.key,
    required this.shutter,
    this.leading,
    this.trailing,
  });
  final Widget shutter;
  final Widget? leading, trailing;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      leading ?? const SizedBox(width: 48),
      shutter,
      trailing ?? const SizedBox(width: 48),
    ],
  );
}

class MonoCallControls extends StatelessWidget {
  const MonoCallControls({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => MonoGlassSurface(
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: children,
    ),
  );
}

class MonoCallGrid extends StatelessWidget {
  const MonoCallGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => GridView.builder(
    itemCount: children.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: children.length <= 2 ? 1 : 2,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
    ),
    itemBuilder: (context, index) => children[index],
  );
}

class MonoMediaGrid extends StatelessWidget {
  const MonoMediaGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 3,
  });
  final int itemCount, crossAxisCount;
  final IndexedWidgetBuilder itemBuilder;
  @override
  Widget build(BuildContext context) => GridView.builder(
    itemCount: itemCount,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
    ),
    itemBuilder: itemBuilder,
  );
}

class MonoGalleryViewer extends StatelessWidget {
  const MonoGalleryViewer({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final PageController? controller;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: MonokitTheme.of(context).colors.mediaCanvas,
    child: PageView.builder(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    ),
  );
}

class MonoDocReader extends StatelessWidget {
  const MonoDocReader({
    super.key,
    required this.controller,
    this.pageController,
  });
  final MonoDocumentController controller;
  final PageController? pageController;
  @override
  Widget build(BuildContext context) => PageView.builder(
    controller: pageController,
    itemCount: controller.pageCount,
    itemBuilder: (context, index) => Semantics(
      label: controller.semanticLabelForPage(index) ?? 'Page ${index + 1}',
      child: controller.buildPage(context, index),
    ),
  );
}

class MonoComposerBar extends StatelessWidget {
  const MonoComposerBar({
    super.key,
    required this.input,
    required this.send,
    this.leading,
    this.trailing,
  });
  final Widget input, send;
  final Widget? leading, trailing;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ?leading,
        if (leading != null) SizedBox(width: t.spacing.sm),
        Expanded(child: input),
        if (trailing != null) ...[SizedBox(width: t.spacing.sm), trailing!],
        SizedBox(width: t.spacing.sm),
        send,
      ],
    );
  }
}

class MonoTypingIndicator extends StatelessWidget {
  const MonoTypingIndicator({super.key, this.label = 'Typing'});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: label,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[Text('•'), Text(' •'), Text(' •')],
    ),
  );
}

enum MonoReceiptState { pending, sent, delivered, read, failed }

class MonoReceipt extends StatelessWidget {
  const MonoReceipt({super.key, required this.state});
  final MonoReceiptState state;
  @override
  Widget build(BuildContext context) {
    final t = MonokitTheme.of(context);
    final label = switch (state) {
      MonoReceiptState.pending => 'Pending',
      MonoReceiptState.sent => 'Sent',
      MonoReceiptState.delivered => 'Delivered',
      MonoReceiptState.read => 'Read',
      MonoReceiptState.failed => 'Failed',
    };
    return Semantics(
      label: label,
      child: Text(
        label,
        style: t.typography.labelMedium.copyWith(
          color: state == MonoReceiptState.failed
              ? t.colors.destructiveText
              : t.colors.mutedForeground,
        ),
      ),
    );
  }
}
