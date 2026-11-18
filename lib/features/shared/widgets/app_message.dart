import 'package:flutter/material.dart';

/// Short feedback at the bottom of the screen; replaces the previous one.
void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Shown when an action needs the internet, e.g. login or registration.
const noInternetMessage =
    'Немає підключення до інтернету. Перевірте Wi-Fi або мобільні дані.';

/// Placeholder feedback for features planned for later labs.
void showComingSoon(BuildContext context) =>
    showAppMessage(context, 'Буде доступно в наступних лабораторних');
