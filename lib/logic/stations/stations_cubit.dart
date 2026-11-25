import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/domain/services/telemetry_service.dart';
import 'package:flutter_lab1/logic/stations/station_live_sync.dart';
import 'package:flutter_lab1/logic/stations/stations_state.dart';

/// All station logic: load (server or cache), CRUD and live MQTT values.
///
/// Data flow: UI calls a method → the cubit calls the repository → emits
/// a new [StationsState] → BlocBuilder redraws the list.
class StationsCubit extends Cubit<StationsState> {
  StationsCubit(this._repository, this._telemetry)
    : super(const StationsState());

  final IStationRepository _repository;
  final ITelemetryService _telemetry;
  String? _userId;
  StationLiveSync? _liveSync;

  Future<void> load(String userId) async {
    _userId = userId;
    emit(state.copyWith(status: StationsStatus.loading));
    try {
      final stations = await _repository.getStations(userId);
      emit(StationsState(status: StationsStatus.loaded, stations: stations));
      _startLiveSync(userId);
    } on StationException catch (error) {
      emit(StationsState(status: StationsStatus.failure, error: error.message));
    }
  }

  Future<void> refresh() async {
    final userId = _userId;
    if (userId != null) await load(userId);
  }

  Future<void> add(StationDraft draft) =>
      _mutate('Станцію додано', (userId) async {
        final created = await _repository.createStation(userId, draft);
        return [...state.stations, created];
      });

  Future<void> edit(WeatherStation station, StationDraft draft) =>
      _mutate('Зміни збережено', (userId) async {
        final updated = await _repository.updateStation(
          userId,
          station.id,
          draft,
        );
        return state.stations.replacing(updated);
      });

  Future<void> delete(WeatherStation station) =>
      _mutate('Станцію «${station.name}» видалено', (userId) async {
        await _repository.deleteStation(userId, station.id);
        return state.stations.without(station.id);
      });

  /// Forgets the user's data on logout.
  void clear() {
    _liveSync?.dispose();
    _liveSync = null;
    _userId = null;
    emit(const StationsState());
  }

  /// Runs a repository change with the overlay spinner, then emits the new
  /// list and a SnackBar message (or the error text).
  Future<void> _mutate(
    String successMessage,
    Future<List<WeatherStation>> Function(String userId) operation,
  ) async {
    final userId = _userId;
    if (userId == null) return;
    emit(state.copyWith(isBusy: true));
    try {
      final stations = await operation(userId);
      emit(state.copyWith(stations: stations).withMessage(successMessage));
    } on StationException catch (error) {
      emit(state.withMessage(error.message));
    }
  }

  /// MQTT readings addressed to a station update it in the state.
  void _startLiveSync(String userId) {
    _liveSync?.dispose();
    _liveSync = StationLiveSync(
      telemetry: _telemetry,
      repository: _repository,
      userId: userId,
      currentStations: () => state.stations,
      onStationUpdated: (station) {
        if (!isClosed) {
          emit(state.copyWith(stations: state.stations.replacing(station)));
        }
      },
    )..start();
  }

  @override
  Future<void> close() {
    _liveSync?.dispose();
    return super.close();
  }
}
