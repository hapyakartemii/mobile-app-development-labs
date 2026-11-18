import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';

/// Red strip at the top of every screen while there's no internet.
///
/// Listens to [IConnectivityService.onlineChanges] for the whole app
/// lifetime and cancels the subscription in [State.dispose].
class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  StreamSubscription<bool>? _subscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    final connectivity = AppScope.of(context).connectivityService;
    _subscription = connectivity.onlineChanges.listen(_update);
    connectivity.isOnline().then(_update);
  }

  void _update(bool isOnline) {
    if (mounted && isOnline != _isOnline) {
      setState(() => _isOnline = isOnline);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // The tree shape stays the same online and offline, so the navigator
    // below keeps its screens when the banner appears.
    return Column(
      children: [
        if (!_isOnline)
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
                        'Немає інтернету. Обмежений режим: MQTT та вхід '
                        'недоступні.',
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
            removeTop: !_isOnline,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
