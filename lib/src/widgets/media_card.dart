import 'package:flutter/widgets.dart';

import '../primitives/mono_pressable.dart';
import '../theme/monokit_theme.dart';
import 'mono_icon.dart';

/// Where a media object is in its trading life.
enum MonoMediaLifecycle { live, ended, archived, sold }

/// A bounded media object with lifecycle state — a product tile in a grid, an
/// order, a gallery item.
///
/// From the proposal register (MediaCard):
///
/// * Media renders at one aspect ratio, on the media canvas, with the
///   declared placeholder (dark well + glyph) when no media exists.
/// * A non-live state is expressed by at least two independent signals —
///   the muted treatment of the media well *and* the [stateLabel] chip —
///   never colour alone, which is why non-live cards require a label.
/// * A price on a non-live card is historical: it renders in the muted label
///   register, never typographically identical to a live price. The framing
///   copy ("Last at …", "Sold at …") belongs to the caller, in the user's
///   language.
/// * Critical data (price, freshness, locality) lives outside the media box
///   in [meta], so it renders before decode and never truncates.
/// * [action] is one optional trailing slot; the card itself owns no CTA
///   styling. There is deliberately no promoted, sponsored or featured
///   variant.
class MonoMediaCard extends StatelessWidget {
  const MonoMediaCard({
    super.key,
    this.lifecycle = MonoMediaLifecycle.live,
    this.media,
    required this.title,
    required this.price,
    this.stateLabel,
    this.meta,
    this.action,
    this.aspectRatio = 1,
    this.onPressed,
    this.semanticLabel,
  }) : assert(
         lifecycle == MonoMediaLifecycle.live || stateLabel != null,
         'A non-live card must carry a state label: lifecycle is never '
         'expressed by treatment alone.',
       );

  final MonoMediaLifecycle lifecycle;

  /// The media content. When null the card renders the declared placeholder
  /// rather than an empty rectangle.
  final Widget? media;

  /// The object's name, rendered outside the media box.
  final Widget title;

  /// The price string, already formatted and framed by the caller. Live cards
  /// render it bold in tabular figures; non-live cards render it in the muted
  /// historical register.
  final String price;

  /// The lifecycle chip's text (e.g. "Ended 3d ago", "Sold"), in the user's
  /// language. Required whenever [lifecycle] is not live.
  final String? stateLabel;

  /// Freshness, locality, counters — the critical line under the title.
  final Widget? meta;

  /// One optional trailing action slot. The card does not style it.
  final Widget? action;

  /// One aspect ratio, fixed per grid by the host.
  final double aspectRatio;

  final VoidCallback? onPressed;
  final String? semanticLabel;

  bool get _live => lifecycle == MonoMediaLifecycle.live;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    final colors = theme.colors;

    final mediaBox = AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radii.lg),
        child: ColoredBox(
          // Live media sits on the true-black canvas; a non-live object moves
          // to the muted well — the first of the two lifecycle signals.
          color: _live ? colors.canvas : colors.fill,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (media != null)
                Opacity(opacity: _live ? 1 : 0.7, child: media)
              else
                Center(
                  child: MonoIcon(
                    MonoIcons.image,
                    size: theme.spacing.xxl,
                    color: _live
                        ? colors.onMediaMuted
                        : colors.foregroundMuted.withValues(alpha: 0.5),
                  ),
                ),
              if (stateLabel != null)
                PositionedDirectional(
                  top: theme.spacing.sm,
                  start: theme.spacing.sm,
                  child: _StateChip(label: stateLabel!),
                ),
            ],
          ),
        ),
      ),
    );

    final priceStyle = _live
        ? theme.typography.labelLarge.copyWith(
            color: colors.foreground,
            fontWeight: FontWeight.w700,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          )
        : theme.typography.labelMedium.copyWith(
            color: colors.foregroundMuted,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          );

    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: theme.spacing.xs + 2),
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(price, style: priceStyle),
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: theme.typography.labelMedium.copyWith(
                      color: _live ? colors.foreground : colors.foregroundMuted,
                    ),
                    child: title,
                  ),
                  if (meta != null) ...<Widget>[
                    const SizedBox(height: 2),
                    DefaultTextStyle.merge(
                      style: theme.typography.labelMedium.copyWith(
                        color: colors.foregroundMuted,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                      child: meta!,
                    ),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
      ],
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[mediaBox, caption],
    );

    if (onPressed == null) {
      return Semantics(label: semanticLabel, child: content);
    }
    return MonoPressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      focusRing: true,
      focusRingBorderRadius: BorderRadius.circular(theme.radii.lg),
      child: (context, states) => content,
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.page,
        border: Border.all(color: theme.colors.separator),
        borderRadius: BorderRadius.circular(theme.radii.full),
      ),
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.sm - 2),
      height: theme.spacing.xl,
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.typography.labelMedium.copyWith(
          color: theme.colors.foregroundMuted,
          fontWeight: FontWeight.w600,
          fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
