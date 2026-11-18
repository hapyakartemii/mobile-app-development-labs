import 'package:flutter/material.dart';

/// Dims [child] and shows a spinner while an operation runs,
/// blocking taps so it can't be started twice.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) ...[
          const ModalBarrier(dismissible: false, color: Colors.black12),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
