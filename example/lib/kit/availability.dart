import 'package:monokit/monokit.dart';

/// A demo-only availability state for the gallery's sample data.
///
/// This mirrors the library's former `MonoAvailability`, which was removed along
/// with the command/honest vocabulary. The example keeps its own enum so the
/// sample feed and post-detail demos still render availability badges.
enum DemoAvailability { available, reserved, fulfilled, closed, expired }

extension DemoAvailabilityX on DemoAvailability {
  String get label => switch (this) {
    DemoAvailability.available => 'Available',
    DemoAvailability.reserved => 'Reserved',
    DemoAvailability.fulfilled => 'Fulfilled',
    DemoAvailability.closed => 'Closed',
    DemoAvailability.expired => 'Expired',
  };

  MonoBadgeVariant get badgeVariant => switch (this) {
    DemoAvailability.available => MonoBadgeVariant.success,
    DemoAvailability.reserved => MonoBadgeVariant.warning,
    DemoAvailability.fulfilled => MonoBadgeVariant.info,
    DemoAvailability.closed => MonoBadgeVariant.secondary,
    DemoAvailability.expired => MonoBadgeVariant.destructive,
  };

  /// Whether a buy/claim action still applies.
  bool get isActionable => this == DemoAvailability.available;
}
