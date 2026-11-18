import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Rounded square with the app icon.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Icon(
        Icons.cloud_outlined,
        size: size * 0.55,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
