import 'package:flutter/material.dart';

/// Short feedback at the bottom of the screen; replaces the previous one.
void showAppMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Placeholder feedback for features planned for later labs.
void showComingSoon(BuildContext context) =>
    showAppMessage(context, 'Буде доступно в наступних лабораторних');
