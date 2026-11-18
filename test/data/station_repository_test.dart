import 'package:flutter_lab1/data/local/shared_prefs_station_repository.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_deps.dart';

void main() {
  late TestDeps deps;
  const userId = 'user-1';
  const draft = StationDraft(name: ' Двір ', location: 'Львів');

  setUp(() async => deps = await TestDeps.create());

  test('starts empty', () async {
    expect(await deps.stations.getStations(userId), isEmpty);
  });

  test('create adds a trimmed station with simulated readings', () async {
    final station = await deps.stations.createStation(userId, draft);

    expect(station.name, 'Двір');
    expect(station.metrics.humidity, inInclusiveRange(40, 85));
    expect(await deps.stations.getStations(userId), hasLength(1));
  });

  test('create rejects invalid data', () {
    expect(
      () => deps.stations.createStation(
        userId,
        const StationDraft(name: 'Д', location: ''),
      ),
      throwsA(isA<StationException>()),
    );
  });

  test('update changes name and location only', () async {
    final created = await deps.stations.createStation(userId, draft);

    final updated = await deps.stations.updateStation(
      userId,
      created.id,
      const StationDraft(name: 'Дах', location: 'Київ'),
    );

    expect(updated.name, 'Дах');
    expect(updated.location, 'Київ');
    expect(updated.metrics.temperature, created.metrics.temperature);
    final saved = await deps.stations.getStations(userId);
    expect(saved.single.name, 'Дах');
  });

  test('delete removes the station', () async {
    final created = await deps.stations.createStation(userId, draft);

    await deps.stations.deleteStation(userId, created.id);

    expect(await deps.stations.getStations(userId), isEmpty);
  });

  test('update and delete of a missing station fail', () async {
    await expectLater(
      deps.stations.updateStation(userId, 'missing', draft),
      throwsA(isA<StationException>()),
    );
    await expectLater(
      deps.stations.deleteStation(userId, 'missing'),
      throwsA(isA<StationException>()),
    );
  });

  test('stations are separate per user', () async {
    await deps.stations.createStation(userId, draft);

    expect(await deps.stations.getStations('user-2'), isEmpty);
  });

  test('data survives a new repository instance (app restart)', () async {
    final created = await deps.stations.createStation(userId, draft);

    final restarted = SharedPrefsStationRepository(deps.prefs);
    final stations = await restarted.getStations(userId);
    expect(stations.single.id, created.id);
    expect(stations.single.updatedAt, created.updatedAt);
  });
}
