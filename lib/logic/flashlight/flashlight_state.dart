import 'package:equatable/equatable.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart';

/// Immutable state of the hidden flashlight (Easter egg).
class FlashlightState extends Equatable {
  const FlashlightState({this.isOn = false, this.error, this.eventId = 0});

  /// Whether the torch is on, as reported by the plugin.
  final bool isOn;

  /// Why the last attempt failed, or `null` if it worked.
  final FlashlightError? error;

  /// Grows with every attempt, so the screen reacts even when the result
  /// is the same as last time (for example, two failures in a row).
  final int eventId;

  @override
  List<Object?> get props => [isOn, error, eventId];
}
