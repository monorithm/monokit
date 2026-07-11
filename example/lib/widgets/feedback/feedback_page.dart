import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import '../shared/doc_widgets.dart';
import 'feedback_state.dart';

/// Interactive documentation for Monokit's action, feedback, and surface
/// widgets.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackState _state = FeedbackState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FeedbackScope(
      state: _state,
      child: Builder(builder: _buildBody),
    );
  }

  Widget _buildBody(BuildContext context) {
    final state = FeedbackScope.of(context);

    void showToast(MonoAlertVariant variant) {
      MonoScreen.of(context).overlays.showToast(
        MonoToast(
          variant: variant,
          message: Text(switch (variant) {
            MonoAlertVariant.success => 'Changes saved successfully.',
            MonoAlertVariant.warning => 'This workspace is nearly full.',
            MonoAlertVariant.destructive => 'The draft could not be deleted.',
            MonoAlertVariant.info => 'A new update is ready.',
            MonoAlertVariant.defaultStyle => 'A Monokit toast appeared.',
          }),
        ),
      );
    }

    return DocPageContent(
      children: <Widget>[
        const DocPageTitle(
          title: 'Actions, feedback, and surfaces',
          description:
              'A hands-on reference for token-aware controls, status feedback, loading states, identity, and composable surfaces.',
        ),
        const DocGroupTitle('Actions'),
        DocSection(
          name: 'MonoButton',
          description:
              'Use a semantic variant for intent, then choose a density or icon size that fits the surrounding layout. Every control below is live.',
          code: '''MonoButton(
  variant: MonoButtonVariant.primary,
  size: MonoButtonSize.md,
  onPressed: save,
  leading: const MonoIcon(MonoIcons.check),
  child: const Text('Save changes'),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _DemoCaption('Variants'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final entry in _buttonVariants)
                    MonoButton(
                      variant: entry.variant,
                      onPressed: state.advanceProgress,
                      child: Text(entry.label),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _DemoCaption('Text sizes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (final entry in _textButtonSizes)
                    MonoButton(
                      size: entry.size,
                      variant: MonoButtonVariant.secondary,
                      onPressed: state.advanceProgress,
                      child: Text(entry.label),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _DemoCaption('Icon sizes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (final entry in _iconButtonSizes)
                    MonoButton.icon(
                      size: entry.size,
                      variant: MonoButtonVariant.outline,
                      semanticLabel: entry.label,
                      icon: const MonoIcon(MonoIcons.sparkles),
                      onPressed: state.advanceProgress,
                    ),
                ],
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoBadge',
          description:
              'Badges label a status or count without competing with the surrounding content. The dot constructor also supports a dot-only indicator.',
          code: '''const MonoBadge.dot(
  variant: MonoBadgeVariant.secondary,
  child: Text('Live'),
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (final variant in MonoBadgeVariant.values)
                    MonoBadge(
                      variant: variant,
                      child: Text(_badgeVariantLabel(variant)),
                    ),
                  const MonoBadge.dot(
                    variant: MonoBadgeVariant.secondary,
                    child: Text('Online'),
                  ),
                  const MonoBadge.dot(
                    semanticLabel: 'Live status',
                    dotColor: Color(0xFF22C55E),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _DemoCaption('Sizes'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (final size in MonoBadgeSize.values)
                    MonoBadge(
                      size: size,
                      variant: MonoBadgeVariant.outline,
                      child: Text(_badgeSizeLabel(size)),
                    ),
                ],
              ),
            ],
          ),
        ),
        const DocGroupTitle('Surfaces and status'),
        DocSection(
          name: 'MonoCard and MonoSeparator',
          description:
              'Cards are deliberately slot-based. This anatomy demo explicitly composes MonoCardHeader, MonoCardTitle, MonoCardDescription, MonoCardAction, MonoCardContent, MonoCardFooter, and separators.',
          code: '''MonoCard(
  child: Column(children: [
    MonoCardHeader(child: ...),
    const MonoSeparator(),
    MonoCardContent(child: ...),
    MonoCardFooter(child: ...),
  ]),
)''',
          child: MonoCard(
            size: MonoCardSize.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MonoCardHeader(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const <Widget>[
                            MonoCardTitle(child: Text('Project Aurora')),
                            SizedBox(height: 4),
                            MonoCardDescription(
                              child: Text(
                                'A complete card composition using each public slot.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const MonoCardAction(
                        child: MonoBadge(
                          variant: MonoBadgeVariant.secondary,
                          child: Text('In review'),
                        ),
                      ),
                    ],
                  ),
                ),
                const MonoSeparator(),
                const MonoCardContent(
                  child: Text(
                    'Slot widgets own their padding, so a card can keep a crisp structure while its contents remain flexible.',
                  ),
                ),
                const MonoSeparator(),
                MonoCardFooter(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      MonoButton(
                        size: MonoButtonSize.sm,
                        variant: MonoButtonVariant.ghost,
                        onPressed: state.advanceProgress,
                        child: const Text('Preview'),
                      ),
                      MonoButton(
                        size: MonoButtonSize.sm,
                        onPressed: state.advanceProgress,
                        child: const Text('Publish'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        DocSection(
          name: 'MonoAlert and MonoToast',
          description:
              'MonoAlert is inline feedback. MonoToast uses the MonoScreen-owned overlay layer so transient feedback works without Material APIs.',
          code: '''MonoScreen.of(context).overlays.showToast(
  const MonoToast(
    variant: MonoAlertVariant.success,
    message: Text('Changes saved.'),
  ),
);''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final variant in MonoAlertVariant.values) ...<Widget>[
                MonoAlert(
                  variant: variant,
                  icon: const MonoIcon(MonoIcons.sparkles),
                  title: Text(_alertTitle(variant)),
                  description: Text(_alertDescription(variant)),
                  action: MonoButton(
                    size: MonoButtonSize.xs,
                    variant: MonoButtonVariant.ghost,
                    onPressed: () => showToast(variant),
                    child: const Text('Toast'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 4),
              MonoButton.icon(
                variant: MonoButtonVariant.outline,
                icon: const MonoIcon(MonoIcons.sparkles),
                label: const Text('Show a success toast'),
                onPressed: () => showToast(MonoAlertVariant.success),
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoProgress and MonoSpinner',
          description:
              'Use a value from 0 to 1 for determinate progress; omit it for an indeterminate indicator. MonoSpinner is the compact activity indicator.',
          code: '''MonoProgress(value: 0.62, width: 240)
const MonoProgress(type: MonoProgressType.circular)
const MonoSpinner()''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: MonoProgress(value: state.progress)),
                  const SizedBox(width: 12),
                  Text('${(state.progress * 100).round()}%'),
                  const SizedBox(width: 8),
                  MonoButton.icon(
                    size: MonoButtonSize.iconSm,
                    variant: MonoButtonVariant.outline,
                    semanticLabel: 'Advance progress',
                    icon: const MonoIcon(MonoIcons.arrowRight),
                    onPressed: state.advanceProgress,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  const _LabeledDemo(
                    label: 'Linear, indeterminate',
                    child: MonoProgress(width: 180),
                  ),
                  _LabeledDemo(
                    label: 'Circular, determinate',
                    child: MonoProgress(
                      type: MonoProgressType.circular,
                      value: state.progress,
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const _LabeledDemo(
                    label: 'Circular, indeterminate',
                    child: MonoProgress(
                      type: MonoProgressType.circular,
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const _LabeledDemo(
                    label: 'MonoSpinner',
                    child: MonoSpinner(size: 28),
                  ),
                ],
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoSkeleton',
          description:
              'Skeletons reserve the final layout while content is loading. Rectangle and circle shapes both respect reduced-motion settings.',
          code: '''const MonoSkeleton(width: 220, height: 16)
const MonoSkeleton.circle(size: 40)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MonoSkeleton.circle(
                    size: 44,
                    animate: state.skeletonsAnimate,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        MonoSkeleton(
                          width: 180,
                          height: 14,
                          animate: state.skeletonsAnimate,
                        ),
                        const SizedBox(height: 8),
                        MonoSkeleton(
                          width: 240,
                          height: 12,
                          animate: state.skeletonsAnimate,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MonoButton(
                size: MonoButtonSize.sm,
                variant: MonoButtonVariant.outline,
                onPressed: () =>
                    state.setSkeletonsAnimate(!state.skeletonsAnimate),
                child: Text(
                  state.skeletonsAnimate
                      ? 'Pause animation'
                      : 'Resume animation',
                ),
              ),
            ],
          ),
        ),
        const DocGroupTitle('Identity and supporting content'),
        DocSection(
          name: 'MonoAvatar',
          description:
              'Avatars can render initials, a supplied ImageProvider, a network image with an initials fallback, or fully custom content. Shapes and sizes keep identity markers consistent.',
          code: '''MonoAvatar.image(localImage, initials: 'IM')
MonoAvatar.network(url, initials: 'NW') // falls back if offline
MonoAvatar(child: const MonoIcon(MonoIcons.sparkles))''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _DemoCaption('Sizes'),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  for (final size in MonoAvatarSize.values)
                    MonoAvatar.initials(
                      'MK',
                      size: size,
                      semanticLabel: '${_avatarSizeLabel(size)} avatar',
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _DemoCaption('Shapes'),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  MonoAvatar.initials(
                    'CI',
                    size: MonoAvatarSize.lg,
                    shape: MonoAvatarShape.circle,
                  ),
                  MonoAvatar.initials(
                    'RO',
                    size: MonoAvatarSize.lg,
                    shape: MonoAvatarShape.rounded,
                  ),
                  MonoAvatar.initials(
                    'SQ',
                    size: MonoAvatarSize.lg,
                    shape: MonoAvatarShape.square,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _DemoCaption('Sources and fallback'),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  _LabeledDemo(
                    label: 'ImageProvider',
                    child: MonoAvatar.image(
                      _demoAvatarImage,
                      initials: 'IM',
                      name: 'In-memory image avatar',
                      size: MonoAvatarSize.lg,
                    ),
                  ),
                  _LabeledDemo(
                    label: 'Network + fallback',
                    child: MonoAvatar.network(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=96&q=80',
                      initials: 'NW',
                      name: 'Network image avatar',
                      size: MonoAvatarSize.lg,
                    ),
                  ),
                  const _LabeledDemo(
                    label: 'Custom child',
                    child: MonoAvatar(
                      size: MonoAvatarSize.lg,
                      backgroundColor: Color(0xFF4F46E5),
                      foregroundColor: Color(0xFFFFFFFF),
                      semanticLabel: 'Custom sparkles avatar',
                      child: MonoIcon(
                        MonoIcons.sparkles,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoAttachment',
          description:
              'Attachments make a file, media preview, or compact metadata row feel at home in cards, messages, and feeds.',
          code: '''MonoAttachment(
  name: 'specification.pdf',
  description: const Text('2.4 MB · PDF'),
  leading: const MonoIcon(MonoIcons.sparkles),
)''',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              MonoAttachment(
                name: 'specification.pdf',
                description: const Text('2.4 MB · PDF'),
                leading: const MonoIcon(MonoIcons.sparkles),
                trailing: const MonoIcon(MonoIcons.arrowRight),
                onPressed: state.advanceProgress,
              ),
              MonoAttachment.image(
                name: 'Launch preview',
                description: const Text('PNG · 1200 × 800'),
                thumbnail: const _AttachmentThumbnail(
                  label: 'IMG',
                  color: Color(0xFF6D28D9),
                ),
                onPressed: state.advanceProgress,
              ),
              MonoAttachment(
                variant: MonoAttachmentVariant.compact,
                name: 'notes.md',
                leading: const MonoIcon(MonoIcons.check),
                onPressed: state.advanceProgress,
              ),
            ],
          ),
        ),
        DocSection(
          name: 'MonoKbd and MonoSeparator',
          description:
              'MonoKbd communicates keyboard shortcuts, while MonoSeparator gives related content a quiet visual boundary in either direction.',
          code: '''Row(children: const [
  MonoKbd.text('⌘'),
  MonoKbd.text('K'),
])

const MonoSeparator(
  orientation: MonoSeparatorOrientation.horizontal,
)''',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  const Text('Open command palette'),
                  MonoKbd.text('⌘', size: MonoKbdSize.sm),
                  MonoKbd.text('K', size: MonoKbdSize.md),
                  MonoKbd.text('Enter', size: MonoKbdSize.lg),
                ],
              ),
              const SizedBox(height: 16),
              const MonoSeparator(
                semanticLabel: 'Horizontal separator example',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Text('Before'),
                    SizedBox(width: 12),
                    MonoSeparator(
                      orientation: MonoSeparatorOrientation.vertical,
                      semanticLabel: 'Vertical separator example',
                    ),
                    SizedBox(width: 12),
                    Text('After'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

const List<_ButtonVariantEntry> _buttonVariants = <_ButtonVariantEntry>[
  _ButtonVariantEntry(MonoButtonVariant.primary, 'Primary'),
  _ButtonVariantEntry(MonoButtonVariant.outline, 'Outline'),
  _ButtonVariantEntry(MonoButtonVariant.secondary, 'Secondary'),
  _ButtonVariantEntry(MonoButtonVariant.ghost, 'Ghost'),
  _ButtonVariantEntry(MonoButtonVariant.destructive, 'Destructive'),
  _ButtonVariantEntry(MonoButtonVariant.link, 'Link'),
];

/// A tiny local image keeps the ImageProvider example deterministic offline.
final ImageProvider<Object> _demoAvatarImage = MemoryImage(
  Uint8List.fromList(const <int>[
    71,
    73,
    70,
    56,
    57,
    97,
    1,
    0,
    1,
    0,
    128,
    0,
    0,
    79,
    70,
    229,
    255,
    255,
    255,
    33,
    249,
    4,
    1,
    0,
    0,
    0,
    0,
    44,
    0,
    0,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    2,
    2,
    76,
    1,
    0,
    59,
  ]),
);

const List<_ButtonSizeEntry> _textButtonSizes = <_ButtonSizeEntry>[
  _ButtonSizeEntry(MonoButtonSize.xs, 'Extra small'),
  _ButtonSizeEntry(MonoButtonSize.sm, 'Small'),
  _ButtonSizeEntry(MonoButtonSize.md, 'Medium'),
  _ButtonSizeEntry(MonoButtonSize.lg, 'Large'),
];

const List<_ButtonSizeEntry> _iconButtonSizes = <_ButtonSizeEntry>[
  _ButtonSizeEntry(MonoButtonSize.iconXs, 'Extra-small icon'),
  _ButtonSizeEntry(MonoButtonSize.iconSm, 'Small icon'),
  _ButtonSizeEntry(MonoButtonSize.icon, 'Medium icon'),
  _ButtonSizeEntry(MonoButtonSize.iconLg, 'Large icon'),
];

class _ButtonVariantEntry {
  const _ButtonVariantEntry(this.variant, this.label);

  final MonoButtonVariant variant;
  final String label;
}

class _ButtonSizeEntry {
  const _ButtonSizeEntry(this.size, this.label);

  final MonoButtonSize size;
  final String label;
}

class _DemoCaption extends StatelessWidget {
  const _DemoCaption(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: theme.typography.labelLarge.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

class _LabeledDemo extends StatelessWidget {
  const _LabeledDemo({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = MonokitTheme.of(context);
    return ColoredBox(
      color: color,
      child: Center(
        child: Text(
          label,
          style: theme.typography.labelMedium.copyWith(
            color: theme.colors.primaryForeground,
          ),
        ),
      ),
    );
  }
}

String _badgeVariantLabel(MonoBadgeVariant variant) {
  return switch (variant) {
    MonoBadgeVariant.primary => 'Primary',
    MonoBadgeVariant.secondary => 'Secondary',
    MonoBadgeVariant.outline => 'Outline',
    MonoBadgeVariant.destructive => 'Destructive',
  };
}

String _badgeSizeLabel(MonoBadgeSize size) {
  return switch (size) {
    MonoBadgeSize.sm => 'Small',
    MonoBadgeSize.md => 'Medium',
    MonoBadgeSize.lg => 'Large',
  };
}

String _alertTitle(MonoAlertVariant variant) {
  return switch (variant) {
    MonoAlertVariant.defaultStyle => 'Default status',
    MonoAlertVariant.info => 'Heads up',
    MonoAlertVariant.success => 'All set',
    MonoAlertVariant.warning => 'Review needed',
    MonoAlertVariant.destructive => 'Action failed',
  };
}

String _alertDescription(MonoAlertVariant variant) {
  return switch (variant) {
    MonoAlertVariant.defaultStyle => 'Neutral context for the current view.',
    MonoAlertVariant.info => 'A background task has completed.',
    MonoAlertVariant.success => 'Your configuration is up to date.',
    MonoAlertVariant.warning => 'Check this setting before publishing.',
    MonoAlertVariant.destructive => 'No data was changed; try again.',
  };
}

String _avatarSizeLabel(MonoAvatarSize size) {
  return switch (size) {
    MonoAvatarSize.xs => 'Extra-small',
    MonoAvatarSize.sm => 'Small',
    MonoAvatarSize.md => 'Medium',
    MonoAvatarSize.lg => 'Large',
    MonoAvatarSize.xl => 'Extra-large',
  };
}
