import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/auth/login_screen.dart';
import 'package:flutter_lab1/features/auth/registration_screen.dart';
import 'package:flutter_lab1/features/dashboard/main_screen.dart';
import 'package:flutter_lab1/features/dashboard/station_details_screen.dart';
import 'package:flutter_lab1/features/dashboard/station_form_screen.dart';
import 'package:flutter_lab1/features/profile/user_profile_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_deps.dart';

/// Renders every screen with real data on several device sizes.
/// A RenderFlex overflow is reported as an exception and fails the test.
void main() {
  const sizes = {
    'small phone 320x568': Size(320, 568),
    'iPhone 8 375x667': Size(375, 667),
    'tablet portrait 768x1024': Size(768, 1024),
    'tablet landscape 1366x1024': Size(1366, 1024),
  };

  final screens = <String, Widget Function(WeatherStation station)>{
    'LoginScreen': (_) => const LoginScreen(),
    'RegistrationScreen': (_) => const RegistrationScreen(),
    'MainScreen': (_) => const MainScreen(),
    'UserProfileScreen': (_) => const UserProfileScreen(),
    'StationDetailsScreen': (station) => StationDetailsScreen(station: station),
    'StationFormScreen': (station) => StationFormScreen(initial: station),
  };

  for (final size in sizes.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} has no overflow on ${size.key}', (
        tester,
      ) async {
        tester.view
          ..physicalSize = size.value
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final deps = await TestDeps.create();
        final user = await deps.signUp();
        late WeatherStation station;
        for (final name in ['Двір', 'Дах офісу у центрі міста', 'Дача']) {
          station = await deps.stations.createStation(
            user.id,
            StationDraft(name: name, location: 'Львівська область, Пустомити'),
          );
        }

        await tester.pumpWidget(deps.screen(screen.value(station)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
