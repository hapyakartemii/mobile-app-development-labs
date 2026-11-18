import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_routes.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/entities/forecast.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_view.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/confirm_dialog.dart';
import 'package:flutter_lab1/features/shared/widgets/loading_overlay.dart';

/// Dashboard with CRUD for the signed-in user's stations.
/// All state lives here and changes only through [setState].
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final AppScope _scope = AppScope.of(context);
  AppUser? _user;
  WeatherForecast? _forecast;
  List<WeatherStation> _stations = const [];
  bool _isBusy = false;

  IStationRepository get _repository => _scope.stationRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _scope.authRepository.currentUser();
    if (!mounted) return;
    if (user == null) return AppRoutes.resetTo(context, AppRoutes.login);
    final (stations, forecast) = await (
      _repository.getStations(user.id),
      _scope.weatherRepository.getForecast(),
    ).wait;
    if (!mounted) return;
    setState(() {
      _user = user;
      _stations = stations;
      _forecast = forecast;
    });
  }

  /// Opens the form; creates a new station, or updates [station] if given.
  Future<void> _saveStation([WeatherStation? station]) async {
    final draft = await Navigator.pushNamed(
      context,
      AppRoutes.stationForm,
      arguments: station,
    );
    if (draft is! StationDraft) return;
    if (station == null) {
      return _mutate('Станцію «${draft.name.trim()}» додано', (userId) async {
        final created = await _repository.createStation(userId, draft);
        return [..._stations, created];
      });
    }
    await _mutate('Зміни збережено', (userId) async {
      final updated = await _repository.updateStation(
        userId,
        station.id,
        draft,
      );
      return [
        for (final s in _stations)
          if (s.id == updated.id) updated else s,
      ];
    });
  }

  Future<void> _deleteStation(WeatherStation station) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Видалити станцію?',
      message: '«${station.name}» буде видалено разом з її даними.',
      confirmLabel: 'Видалити',
    );
    if (!confirmed) return;
    await _mutate('Станцію «${station.name}» видалено', (userId) async {
      await _repository.deleteStation(userId, station.id);
      return [
        for (final s in _stations)
          if (s.id != station.id) s,
      ];
    });
  }

  /// Runs a repository call with a loading overlay and applies the
  /// resulting list via [setState].
  Future<void> _mutate(
    String successMessage,
    Future<List<WeatherStation>> Function(String userId) operation,
  ) async {
    final user = _user;
    if (user == null) return;
    setState(() => _isBusy = true);
    try {
      final stations = await operation(user.id);
      if (!mounted) return;
      setState(() => _stations = stations);
      showAppMessage(context, successMessage);
    } on StationException catch (error) {
      if (mounted) showAppMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final forecast = _forecast;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Метеостанція'),
        actions: [
          IconButton(
            tooltip: 'Профіль',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      floatingActionButton: forecast == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _isBusy ? null : _saveStation,
              icon: const Icon(Icons.add),
              label: const Text('Станція'),
            ),
      body: forecast == null
          ? const Center(child: CircularProgressIndicator())
          : LoadingOverlay(
              isLoading: _isBusy,
              child: DashboardView(
                forecast: forecast,
                stations: _stations,
                onAdd: _saveStation,
                onOpen: (station) => Navigator.pushNamed(
                  context,
                  AppRoutes.stationDetails,
                  arguments: station,
                ),
                onEdit: _saveStation,
                onDelete: _deleteStation,
              ),
            ),
    );
  }
}
