import 'dart:ui' show PathMetric;

import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../states/mono_state.dart';
import '../theme/monokit_theme.dart';
import '../theme/monokit_theme_data.dart';
import 'mono_icon.dart';

/// What a set of slots is allowed to hold.
///
/// *"The set is either photos or one video, never a mix — the slots enforce
/// it."* A mixed set has no coherent order, no single aspect, and no answer to
/// what "next" means; the enforcement belongs here rather than in a validation
/// message after the fact.
enum MonoUploadKind {
  /// Up to the caller's cap, ordered, each carrying its position.
  photos,

  /// Exactly one, and no photo may join it.
  video,

  /// A document — the row form. A certificate, an ID, a receipt.
  document,
}

/// One place a file goes: filled, empty, or disabled because the set is full.
///
/// **The dashed ring is the affordance grey, not a border.** It is drawn from
/// `ring` rather than `border` because it is not enclosing anything yet — it
/// is the shape of a thing that could exist, which is why it is dashed and why
/// it disappears the moment the slot fills.
///
/// Two forms. The tile is for media, square, carrying its position badge so
/// the order the buyer will see is the order the seller arranged. The row is
/// for documents, where the name of the thing matters more than a thumbnail
/// and there is room to say what a good one looks like.
class MonoUploadSlot extends StatelessWidget {
  /// A slot holding something. [child] is the thumbnail; [position] numbers it
  /// within its set.
  const MonoUploadSlot.filled({
    super.key,
    required Widget this.child,
    this.position,
    this.onPressed,
    this.semanticLabel,
    this.size = tile,
  }) : kind = MonoUploadKind.photos,
       enabled = true,
       title = null,
       hint = null;

  /// An empty media slot. [enabled] false when the set is full, or the mode
  /// forbids another — a photo slot beside a chosen video.
  const MonoUploadSlot.empty({
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.enabled = true,
    this.kind = MonoUploadKind.photos,
    this.size = tile,
  }) : child = null,
       position = null,
       title = null,
       hint = null;

  /// The row form: a document rather than media. [title] names what to add and
  /// [hint] says what a usable one looks like — *"All four corners visible"*
  /// prevents more re-takes than any error message after the upload.
  const MonoUploadSlot.document({
    super.key,
    required String this.title,
    this.hint,
    this.onPressed,
    this.semanticLabel,
    this.enabled = true,
  }) : child = null,
       position = null,
       kind = MonoUploadKind.document,
       size = tile;

  /// The media tile's edge. Square, and large enough that a thumbnail is
  /// recognisable at arm's length without becoming the subject of the screen.
  static const double tile = 72;

  final Widget? child;
  final int? position;
  final String? title;
  final String? hint;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final bool enabled;
  final MonoUploadKind kind;
  final double size;

  bool get _isFilled => child != null;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final bool interactive = enabled && onPressed != null;

    Widget body(BuildContext context, Set<MonoState> states) {
      final Widget content = kind == MonoUploadKind.document
          ? _row(context)
          : _tile(context);
      return Opacity(opacity: enabled ? 1 : 0.5, child: content);
    }

    return Semantics(
      button: true,
      enabled: interactive,
      label: semanticLabel ?? _defaultLabel(theme),
      child: MonoPressable(
        onPressed: interactive ? onPressed : null,
        // A filled slot opens full screen; an empty one opens the picker.
        child: body,
      ),
    );
  }

  String _defaultLabel(MonokitThemeData theme) {
    if (title != null) return hint == null ? title! : '$title. $hint';
    if (_isFilled) {
      return position == null ? 'Photo' : 'Photo $position';
    }
    return switch (kind) {
      MonoUploadKind.video => 'Add a video',
      _ => 'Add another photo',
    };
  }

  Widget _tile(BuildContext context) {
    final theme = MonokitTheme.of(context);
    if (_isFilled) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(theme.radii.lg),
          child: ColoredBox(
            color: theme.colors.mediaCanvas,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ?child,
                if (position != null)
                  PositionedDirectional(
                    end: theme.spacing.xs,
                    bottom: theme.spacing.xs,
                    child: _PositionBadge(position: position!),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    return _DashedRing(
      radius: theme.radii.lg,
      color: theme.colors.ring,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: MonoIcon(
            kind == MonoUploadKind.video ? MonoIcons.video : MonoIcons.plus,
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return _DashedRing(
      radius: theme.radii.xl,
      color: theme.colors.ring,
      child: Container(
        constraints: BoxConstraints(minHeight: theme.density.row2),
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
        child: Row(
          children: <Widget>[
            MonoIcon(MonoIcons.document, color: theme.colors.mutedForeground),
            SizedBox(width: theme.spacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title!, style: theme.typography.labelLarge),
                  if (hint != null) ...<Widget>[
                    SizedBox(height: 2),
                    Text(
                      hint!,
                      style: theme.typography.labelMedium.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: theme.spacing.sm),
            MonoIcon(
              MonoIcons.chevronRight,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

/// The affordance ring: a real dashed stroke, in `ring` rather than `border`.
///
/// Flutter's `Border` cannot dash, and the dash is not decoration here — it is
/// the difference between "a thing could go here" and "a thing is here". A
/// solid ring reads as a bordered box, which is exactly the shape the rest of
/// the system spent 4.3.0 removing.
class _DashedRing extends StatelessWidget {
  const _DashedRing({
    required this.child,
    required this.radius,
    required this.color,
  });

  final Widget child;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRingPainter(radius: radius, color: color),
      child: child,
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  /// Long enough to read as a dash rather than a dotted line, short enough to
  /// turn a 10px corner without a straight segment cutting it.
  static const double _dash = 5;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + _dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.color != color || old.radius != radius;
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({required this.position});

  final int position;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: theme.radii.borderRadiusFull,
      ),
      child: Text(
        '$position',
        style: theme.typography
            .tabular(theme.typography.labelMedium)
            .copyWith(
              color: theme.colors.primaryForeground,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
      ),
    );
  }
}
