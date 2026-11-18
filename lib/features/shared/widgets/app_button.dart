import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined }

/// Full-width button used for the main actions on every screen.
/// While [isLoading] it shows a spinner and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon == null ? null : Icon(icon));
    final text = Text(label);
    final action = isLoading ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.filled => FilledButton.icon(
        onPressed: action,
        icon: leading,
        label: text,
      ),
      AppButtonVariant.outlined => OutlinedButton.icon(
        onPressed: action,
        icon: leading,
        label: text,
      ),
    };
  }
}
