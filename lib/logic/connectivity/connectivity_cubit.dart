import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/services/connectivity_service.dart';

/// Whether the internet is reachable right now (`true` / `false`).
/// The state is a plain `bool`, which is already immutable.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(IConnectivityService connectivity) : super(true) {
    _subscription = connectivity.onlineChanges.listen(_set);
    unawaited(connectivity.isOnline().then(_set));
  }

  late final StreamSubscription<bool> _subscription;

  void _set(bool isOnline) {
    if (!isClosed) emit(isOnline);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
