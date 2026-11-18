import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/station_details_screen.dart';
import 'package:flutter_lab1/features/dashboard/station_form_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_deps.dart';

void main() {
  late TestDeps deps;
  late AppUser user;

  setUp(() async {
    deps = await TestDeps.create();
    user = await deps.signUp();
  });

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(deps.app());
    await tester.pumpAndSettle();
  }

  Future<void> seedStation() => deps.stations.createStation(
    user.id,
    const StationDraft(name: 'Двір', location: 'Львів'),
  );

  testWidgets('create: adds a station through the form', (tester) async {
    await openApp(tester);

    await tap(tester, find.text('Станція'));
    expect(find.byType(StationFormScreen), findsOneWidget);
    await tester.enterText(field('Назва'), 'Дах офісу');
    await tester.enterText(field('Розташування'), 'Київ');
    await tap(tester, find.widgetWithText(FilledButton, 'Додати станцію'));

    expect(find.byType(StationFormScreen), findsNothing);
    expect(find.text('Дах офісу'), findsOneWidget);
    expect(find.text('Станцію «Дах офісу» додано'), findsOneWidget);
    expect(await deps.stations.getStations(user.id), hasLength(1));
  });

  testWidgets('create: invalid form is not saved', (tester) async {
    await openApp(tester);

    await tap(tester, find.text('Станція'));
    await tap(tester, find.widgetWithText(FilledButton, 'Додати станцію'));

    expect(find.byType(StationFormScreen), findsOneWidget);
    expect(find.textContaining('щонайменше 2 символи'), findsOneWidget);
    expect(find.text('Вкажіть розташування'), findsOneWidget);
    expect(await deps.stations.getStations(user.id), isEmpty);
  });

  testWidgets('read: card opens station details', (tester) async {
    await seedStation();
    await openApp(tester);

    await tap(tester, find.text('Двір'));

    expect(find.byType(StationDetailsScreen), findsOneWidget);
    expect(find.text('Температура'), findsOneWidget);
  });

  testWidgets('update: edits a station from the card menu', (tester) async {
    await seedStation();
    await openApp(tester);

    await tap(tester, find.byTooltip('Дії зі станцією'));
    await tap(tester, find.text('Редагувати'));
    expect(find.text('Двір'), findsOneWidget);
    await tester.enterText(field('Назва'), 'Сад');
    await tap(tester, find.text('Зберегти зміни'));

    expect(find.text('Сад'), findsOneWidget);
    expect(find.text('Двір'), findsNothing);
    final saved = await deps.stations.getStations(user.id);
    expect(saved.single.name, 'Сад');
  });

  testWidgets('delete: asks for confirmation, cancel keeps it', (tester) async {
    await seedStation();
    await openApp(tester);

    await tap(tester, find.byTooltip('Дії зі станцією'));
    await tap(tester, find.text('Видалити'));
    expect(find.text('Видалити станцію?'), findsOneWidget);
    await tap(tester, find.text('Скасувати'));

    expect(find.text('Двір'), findsOneWidget);
    expect(await deps.stations.getStations(user.id), hasLength(1));
  });

  testWidgets('delete: confirmed deletion removes the station', (tester) async {
    await seedStation();
    await openApp(tester);

    await tap(tester, find.byTooltip('Дії зі станцією'));
    await tap(tester, find.text('Видалити'));
    await tap(tester, find.widgetWithText(FilledButton, 'Видалити'));

    expect(find.text('Двір'), findsNothing);
    expect(find.text('Ще немає станцій'), findsOneWidget);
    expect(await deps.stations.getStations(user.id), isEmpty);
  });

  testWidgets('stations are loaded again after an app restart', (tester) async {
    await seedStation();
    await openApp(tester);
    expect(find.text('Двір'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await openApp(tester);

    expect(find.text('Двір'), findsOneWidget);
  });
}
