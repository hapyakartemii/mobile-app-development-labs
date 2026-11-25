import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/logic/connectivity/connectivity_cubit.dart';

/// Red strip at the top of every screen while there's no internet.
/// Redrawn by [BlocBuilder] whenever [ConnectivityCubit] emits.
class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) => Column(
        // The tree shape stays the same online and offline, so the
        // navigator below keeps its screens when the banner appears.
        children: [
          if (!isOnline)
            Material(
              color: scheme.error,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.m,
                    vertical: AppSpacing.s,
                  ),
                  child: Row(
                    spacing: AppSpacing.s,
                    children: [
                      Icon(Icons.wifi_off, color: scheme.onError, size: 20),
                      Expanded(
                        child: Text(
                          'Немає інтернету. Показано збережені дані.',
                          style: TextStyle(color: scheme.onError),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            key: const ValueKey('app-content'),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: !isOnline,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
