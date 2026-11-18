import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';

/// [IConnectivityService] built on the `connectivity_plus` plugin.
///
/// The plugin only knows whether Wi-Fi / mobile data is on, so every
/// change is double-checked with a DNS lookup: a Wi-Fi network without
/// internet counts as offline.
class ConnectivityPlusService implements IConnectivityService {
  ConnectivityPlusService({required this.probeHost, Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  static const _probeTimeout = Duration(seconds: 3);
  static const _probeAttempts = 3;
  static const _retryDelay = Duration(seconds: 1);

  final String probeHost;
  final Connectivity _connectivity;

  @override
  Future<bool> isOnline() async =>
      _check(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.asyncMap(_check).distinct();

  Future<bool> _check(List<ConnectivityResult> results) async {
    final hasNetwork = results.any(
      (result) => result != ConnectivityResult.none,
    );
    if (!hasNetwork) return false;
    // Right after Wi-Fi reconnects the interface is up before DNS works,
    // so retry a few times instead of reporting a false "offline".
    for (var attempt = 0; attempt < _probeAttempts; attempt++) {
      if (await _canReachInternet()) return true;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  Future<bool> _canReachInternet() async {
    try {
      final addresses = await InternetAddress.lookup(
        probeHost,
      ).timeout(_probeTimeout);
      return addresses.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
