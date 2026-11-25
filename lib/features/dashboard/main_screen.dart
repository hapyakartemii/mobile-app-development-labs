import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/domain/entities/app_user.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/domain/repositories/auth_repository.dart';
import 'package:flutter_lab1/domain/repositories/station_repository.dart';
import 'package:flutter_lab1/features/dashboard/station_live_sync.dart';
import 'package:flutter_lab1/features/dashboard/station_navigation.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_app_bar.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_view.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/async_body.dart';
import 'package:flutter_lab1/features/shared/widgets/loading_overlay.dart';
import 'package:flutter_lab1/features/shared/widgets/offline_mode_dialog.dart';

/// Dashboard: stations from the server (or the cache when offline) loaded
/// with a [FutureBuilder]; CRUD changes the list through [setState].
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final AppScope _scope = AppScope.of(context);
  late Future<AppUser> _loading = _load();
  AppUser? _user;
  List<WeatherStation> _stations = const [];
  bool _isBusy = false;
  int _refreshCount = 0;
  StationLiveSync? _liveSync;

  IStationRepository get _repository => _scope.stationRepository;

  @override
  void dispose() {
    _liveSync?.dispose();
    super.dispose();
  }

  /// Loads the user and their stations. Its [Future] drives the builder.
  Future<AppUser> _load() async {
    final user = await _scope.authRepository.currentUser();
    if (user == null) {
      throw const AuthException('Сесія закінчилась. Увійдіть знову.');
    }
    _stations = await _repository.getStations(user.id);
    _user = user;
    _liveSync ??= StationLiveSync(
      telemetry: _scope.telemetryService,
      repository: _repository,
      userId: user.id,
      currentStations: () => _stations,
      onStationUpdated: (station) {
        if (mounted) setState(() => _stations = _stations.replacing(station));
      },
    )..start();
    if (_refreshCount == 0) unawaited(_warnIfOffline());
    return user;
  }

  /// Launched from the saved session without the internet: warn once.
  Future<void> _warnIfOffline() async {
    final isOnline = await _scope.connectivityService.isOnline();
    if (!isOnline && mounted) await showOfflineModeDialog(context);
  }

  void _refresh() => setState(() {
    _refreshCount++;
    _loading = _load();
  });

  /// Opens the form; creates a new station, or updates [station] if given.
  Future<void> _saveStation([WeatherStation? station]) async {
    final draft = await openStationForm(context, station);
    if (draft == null) return;
    final message = station == null ? 'Станцію додано' : 'Зміни збережено';
    await _mutate(message, (userId) async {
      if (station == null) {
        return [..._stations, await _repository.createStation(userId, draft)];
      }
      final updated = await _repository.updateStation(
        userId,
        station.id,
        draft,
      );
      return _stations.replacing(updated);
    });
  }

  Future<void> _deleteStation(WeatherStation station) async {
    if (!await confirmStationDeletion(context, station)) return;
    await _mutate('Станцію «${station.name}» видалено', (userId) async {
      await _repository.deleteStation(userId, station.id);
      return _stations.without(station.id);
    });
  }

  /// Runs a repository call with a loading overlay; applies the new list.
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
    return Scaffold(
      appBar: DashboardAppBar(onRefresh: _refresh),
      floatingActionButton: _user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _isBusy ? null : _saveStation,
              icon: const Icon(Icons.add),
              label: const Text('Станція'),
            ),
      body: AsyncBody<AppUser>(
        future: _loading,
        onRetry: _refresh,
        builder: (context, _) => LoadingOverlay(
          isLoading: _isBusy,
          child: DashboardView(
            refreshCount: _refreshCount,
            stations: _stations,
            onAdd: _saveStation,
            onOpen: (station) => openStationDetails(context, station),
            onEdit: _saveStation,
            onDelete: _deleteStation,
          ),
        ),
      ),
    );
  }
}
