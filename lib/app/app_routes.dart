import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/auth/auth_gate.dart';
import 'package:flutter_lab1/features/auth/login_screen.dart';
import 'package:flutter_lab1/features/auth/registration_screen.dart';
import 'package:flutter_lab1/features/dashboard/main_screen.dart';
import 'package:flutter_lab1/features/dashboard/station_details_screen.dart';
import 'package:flutter_lab1/features/dashboard/station_form_screen.dart';
import 'package:flutter_lab1/features/profile/user_profile_screen.dart';

/// Named routes of the app (Navigator 1.0).
abstract final class AppRoutes {
  static const gate = '/';
  static const login = '/login';
  static const registration = '/registration';
  static const main = '/main';
  static const profile = '/profile';
  static const stationDetails = '/station';
  static const stationForm = '/station/form';

  /// Opens [route] and clears the back stack, so "back" can't return to
  /// the login form after signing in, or to the app after logging out.
  static Future<void> resetTo(BuildContext context, String route) =>
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);

  static Route<Object?> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      login => const LoginScreen(),
      registration => const RegistrationScreen(),
      main => const MainScreen(),
      profile => const UserProfileScreen(),
      stationDetails => StationDetailsScreen(
        station: settings.arguments! as WeatherStation,
      ),
      stationForm => StationFormScreen(
        initial: settings.arguments as WeatherStation?,
      ),
      _ => const AuthGate(),
    };

    return MaterialPageRoute<Object?>(builder: (_) => page, settings: settings);
  }
}
