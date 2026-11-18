import 'package:flutter/material.dart';

/// Warning after an offline auto-login: the app opens, but only with the
/// data saved on the device.
Future<void> showOfflineModeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.wifi_off),
      title: const Text('Немає підключення до інтернету'),
      content: const Text(
        'Ви увійшли зі збереженої сесії. Застосунок працює в режимі '
        'обмеженої функціональності: доступні лише дані на пристрої, '
        'MQTT-датчики не оновлюються.',
      ),
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
