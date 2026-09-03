/// Monokit is a compact, token-driven, widgets-first Flutter UI system.
library;

// The widget layer monokit builds on, re-exported so
// `package:monokit_ui/monokit_ui.dart` is the single canonical import —
// mirroring how `material.dart`/`cupertino.dart` re-export it. Only
// `widgets.dart` is surfaced; Material and Cupertino are never re-exported,
// keeping the system Material-free by construction.
//
// Note the trade-off this makes: every Flutter name in `widgets.dart` becomes
// part of monokit's exported namespace, so a consumer that defines its own
// `Page`, `Action`, `Route` (etc.) will see an ambiguous-import error and must
// `hide` one side. `Mono`-prefixing monokit's own symbols does not help here —
// the collision is between Flutter's names and the consumer's.
export 'package:flutter/widgets.dart';

export 'src/app/mono_screen.dart';
export 'src/app/monokit_app.dart';
export 'src/widgets/accordion.dart';
export 'src/widgets/alert.dart';
export 'src/widgets/attachment.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/badge.dart';
export 'src/widgets/bottom_nav.dart';
export 'src/widgets/breadcrumb.dart';
export 'src/widgets/bubble.dart';
export 'src/widgets/button.dart';
export 'src/widgets/card.dart';
export 'src/widgets/checkbox.dart';
export 'src/widgets/chrome_recede.dart';
export 'src/widgets/chip.dart';
export 'src/widgets/combobox.dart';
export 'src/widgets/commerce.dart';
export 'src/widgets/command_palette.dart';
export 'src/widgets/context_menu.dart';
export 'src/widgets/dialog.dart';
export 'src/widgets/drawer.dart';
export 'src/widgets/dropdown_menu.dart';
export 'src/widgets/field.dart';
export 'src/widgets/hover_card.dart';
export 'src/widgets/immersive_feed.dart';
export 'src/widgets/input.dart';
export 'src/widgets/input_otp.dart';
export 'src/widgets/kbd.dart';
export 'src/widgets/list_row.dart';
export 'src/widgets/list_row_swipe.dart';
export 'src/widgets/media_card.dart';
export 'src/widgets/meta_line.dart';
export 'src/widgets/message.dart';
export 'src/widgets/message_scroller.dart';
export 'src/widgets/media.dart';
export 'src/widgets/mono_icon.dart';
export 'src/widgets/modal.dart';
export 'src/widgets/page_dots.dart';
export 'src/widgets/pager.dart';
export 'src/widgets/mono_screen_chrome.dart';
export 'src/widgets/mono_sidebar.dart';
export 'src/widgets/navigation_menu.dart';
export 'src/widgets/pagination.dart';
export 'src/widgets/popover.dart';
export 'src/widgets/progress.dart';
export 'src/widgets/radio_group.dart';
export 'src/widgets/separator.dart';
export 'src/widgets/select.dart';
export 'src/widgets/skeleton.dart';
export 'src/widgets/sheet.dart';
export 'src/widgets/spinner.dart';
export 'src/widgets/step_progress.dart';
export 'src/widgets/switch.dart';
export 'src/widgets/system_feedback.dart';
export 'src/widgets/tabs.dart';
export 'src/widgets/textarea.dart';
export 'src/widgets/tooltip.dart';
export 'src/widgets/upload_slot.dart';
export 'src/widgets/trust_badge.dart';
export 'src/primitives/mono_anchored_layout.dart';
export 'src/motion/mono_spring_controller.dart';
export 'src/motion/monokit_scroll_behavior.dart';
export 'src/primitives/mono_announcer.dart';
export 'src/primitives/mono_field_skin.dart';
export 'src/primitives/mono_focus_ring.dart';
export 'src/primitives/mono_focus_trap.dart';
export 'src/primitives/mono_heading.dart';
export 'src/primitives/mono_overlay_focus.dart';
export 'src/primitives/mono_overlay_layer.dart';
export 'src/primitives/mono_placement.dart';
export 'src/primitives/mono_pressable.dart';
export 'src/primitives/mono_surfaces.dart';
export 'src/primitives/mono_text_scale.dart';
export 'src/primitives/mono_width_scope.dart';
export 'src/primitives/mono_text_selection.dart';
export 'src/states/mono_state.dart';
export 'src/states/mono_phase.dart';
export 'src/states/mono_states_controller.dart';
export 'src/theme/monokit_colors.dart';
export 'src/theme/monokit_component_themes.dart';
export 'src/theme/monokit_density.dart';
export 'src/theme/monokit_layout.dart';
export 'src/theme/monokit_elevation.dart';
export 'src/theme/monokit_focus.dart';
export 'src/theme/monokit_labels.dart';
export 'src/theme/monokit_haptics.dart';
export 'src/theme/monokit_motion.dart';
export 'src/theme/monokit_radii.dart';
export 'src/theme/monokit_spacing.dart';
export 'src/theme/monokit_theme.dart';
export 'src/theme/monokit_theme_data.dart';
export 'src/theme/monokit_typography.dart';
