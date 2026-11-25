import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/features/shared/widgets/connectivity_banner.dart';
import 'package:flutter_lab1/features/shared/widgets/offline_mode_dialog.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/auth/auth_state.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_cubit.dart';

/// Reacts to session changes in one place:
/// * signed in → load stations, connect MQTT, open the dashboard
///   (and warn if it happened offline);
/// * signed out → forget the data, disconnect, open the login screen.
/// Also shows the red "no internet" strip above every screen.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigatorKey, required this.child, super.key});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  void _onAuthChanged(BuildContext context, AuthState state) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    final stations = context.read<StationsCubit>();
    final telemetry = context.read<TelemetryCubit>();

    if (state.status == AuthStatus.authenticated) {
      stations.load(state.user!.id);
      telemetry.start();
      navigator.pushNamedAndRemoveUntil(AppRoutes.main, (_) => false);
      if (state.startedOffline) {
        showOfflineModeDialog(navigator.context);
      }
    } else if (state.status == AuthStatus.unauthenticated) {
      stations.clear();
      telemetry.stop();
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onAuthChanged,
      child: ConnectivityBanner(child: child),
    );
  }
}
