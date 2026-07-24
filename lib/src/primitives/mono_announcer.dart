import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Sends an imperative announcement to the platform screen reader for a
/// transient event that no persistent live region covers — copy-to-clipboard,
/// "sort applied", an async command finishing, a page changing.
///
/// This is the imperative counterpart to `Semantics(liveRegion: true)`: use a
/// live region when a piece of the tree changes and should be re-read; use
/// [MonoAnnouncer] for a one-off event that has no lasting widget.
class MonoAnnouncer {
  const MonoAnnouncer._();

  /// Announces [message] via the platform screen reader, respecting the
  /// ambient text direction. No-op visually; does nothing when no screen reader
  /// is active.
  ///
  /// [assertiveness] chooses politeness: [Assertiveness.polite] waits for the
  /// reader to finish its current utterance (the default, correct for most
  /// events); [Assertiveness.assertive] interrupts (reserve for errors).
  static void announce(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    if (message.isEmpty) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: assertiveness,
    );
  }
}
