import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/logic/flashlight/flashlight_state.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart';

/// Hidden flashlight. Talks to the plugin's Dart API only; the platform
/// channel itself lives inside `my_flashlight_plugin`.
class FlashlightCubit extends Cubit<FlashlightState> {
  FlashlightCubit() : super(const FlashlightState());

  /// Switches the torch. On an unsupported platform or device the plugin
  /// throws [FlashlightException]; it becomes a state, not a crash.
  Future<void> toggle() async {
    final next = state.eventId + 1;
    try {
      final isOn = await MyFlashlightPlugin.toggle();
      _emit(FlashlightState(isOn: isOn, eventId: next));
    } on FlashlightException catch (e) {
      _emit(FlashlightState(isOn: state.isOn, error: e.error, eventId: next));
    }
  }

  void _emit(FlashlightState next) {
    if (!isClosed) emit(next);
  }

  /// Leaving the screen switches the torch off, so it never stays on.
  @override
  Future<void> close() async {
    if (state.isOn) {
      try {
        await MyFlashlightPlugin.turnOff();
      } on FlashlightException {
        // Nothing to switch off.
      }
    }
    return super.close();
  }
}
