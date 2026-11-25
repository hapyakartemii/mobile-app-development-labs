import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/di.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/logic/flashlight/flashlight_cubit.dart';
import 'package:flutter_lab1/logic/flashlight/flashlight_state.dart';
import 'package:my_flashlight_plugin/my_flashlight_plugin.dart';

/// Easter egg: a long press on [child] (the profile avatar) toggles the
/// flashlight. Where it can't work, a warning dialog is shown instead.
class FlashlightEasterEgg extends StatelessWidget {
  const FlashlightEasterEgg({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FlashlightCubit>(),
      child: BlocListener<FlashlightCubit, FlashlightState>(
        listenWhen: (previous, current) => previous.eventId != current.eventId,
        listener: _onResult,
        child: Builder(
          builder: (context) => GestureDetector(
            onLongPress: () => context.read<FlashlightCubit>().toggle(),
            child: child,
          ),
        ),
      ),
    );
  }

  void _onResult(BuildContext context, FlashlightState state) {
    final error = state.error;
    if (error == null) {
      showAppMessage(
        context,
        state.isOn ? '🔦 Ліхтарик увімкнено' : 'Ліхтарик вимкнено',
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.flashlight_off_outlined),
        title: const Text('Ліхтарик недоступний'),
        content: Text(_reason(error)),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: Size.zero),
            onPressed: () => Navigator.pop(context),
            child: const Text('Зрозуміло'),
          ),
        ],
      ),
    );
  }

  static String _reason(FlashlightError error) => switch (error) {
    FlashlightError.unsupportedPlatform =>
      'Керування ліхтариком підтримується лише на Android. '
          'На цій платформі функція недоступна.',
    FlashlightError.noFlash => 'На цьому пристрої немає спалаху камери.',
    FlashlightError.permissionDenied =>
      'Застосунку бракує дозволу на використання ліхтарика.',
    FlashlightError.cameraError =>
      'Камера зайнята іншим застосунком. Спробуйте пізніше.',
  };
}
