import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_shell.dart';
import 'package:flutter_lab1/app/di.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/logic/auth/auth_cubit.dart';
import 'package:flutter_lab1/logic/connectivity/connectivity_cubit.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_cubit.dart';

/// Root widget: puts the app-wide cubits above [MaterialApp], so every
/// screen (route) can read them with `context.read` / `BlocBuilder`.
class MeteoApp extends StatelessWidget {
  const MeteoApp({super.key});

  static final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auto-login: the saved session is checked as soon as the app opens.
        BlocProvider(create: (_) => getIt<AuthCubit>()..checkSession()),
        BlocProvider(create: (_) => getIt<ConnectivityCubit>()),
        BlocProvider(create: (_) => getIt<StationsCubit>()),
        BlocProvider(create: (_) => getIt<TelemetryCubit>()),
      ],
      child: MaterialApp(
        title: 'Метеостанція',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: _navigatorKey,
        initialRoute: AppRoutes.gate,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        builder: (context, child) =>
            AppShell(navigatorKey: _navigatorKey, child: child!),
      ),
    );
  }
}
