import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/di.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/station_navigation.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_app_bar.dart';
import 'package:flutter_lab1/features/dashboard/widgets/dashboard_view.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';
import 'package:flutter_lab1/features/shared/widgets/error_view.dart';
import 'package:flutter_lab1/features/shared/widgets/loading_overlay.dart';
import 'package:flutter_lab1/logic/stations/stations_cubit.dart';
import 'package:flutter_lab1/logic/stations/stations_state.dart';
import 'package:flutter_lab1/logic/weather/weather_cubit.dart';

/// Dashboard. Stateless: it only draws [StationsState] and sends user
/// actions to [StationsCubit] / [WeatherCubit].
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The forecast belongs to this screen: created here, closed with it.
    return BlocProvider(
      create: (_) => getIt<WeatherCubit>()..load(),
      child: const _DashboardScaffold(),
    );
  }
}

class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold();

  void _refresh(BuildContext context) {
    context.read<StationsCubit>().refresh();
    context.read<WeatherCubit>().load();
  }

  /// Form → cubit: create a new station, or edit [station] if given.
  Future<void> _save(BuildContext context, [WeatherStation? station]) async {
    final cubit = context.read<StationsCubit>();
    final draft = await openStationForm(context, station);
    if (draft == null) return;
    await (station == null ? cubit.add(draft) : cubit.edit(station, draft));
  }

  Future<void> _delete(BuildContext context, WeatherStation station) async {
    final cubit = context.read<StationsCubit>();
    if (await confirmStationDeletion(context, station)) {
      await cubit.delete(station);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationsCubit, StationsState>(
      // One-off feedback (added / saved / deleted / error) as a SnackBar.
      listenWhen: (previous, current) =>
          previous.messageId != current.messageId,
      listener: (context, state) {
        if (state.message case final message?) {
          showAppMessage(context, message);
        }
      },
      builder: (context, state) => Scaffold(
        appBar: DashboardAppBar(onRefresh: () => _refresh(context)),
        floatingActionButton: state.status == StationsStatus.loaded
            ? FloatingActionButton.extended(
                onPressed: state.isBusy ? null : () => _save(context),
                icon: const Icon(Icons.add),
                label: const Text('Станція'),
              )
            : null,
        body: switch (state.status) {
          StationsStatus.initial || StationsStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          StationsStatus.failure => ErrorView(
            message: state.error ?? 'Не вдалося завантажити станції.',
            onAction: () => context.read<StationsCubit>().refresh(),
          ),
          StationsStatus.loaded => LoadingOverlay(
            isLoading: state.isBusy,
            child: DashboardView(
              stations: state.stations,
              onAdd: () => _save(context),
              onOpen: (station) => openStationDetails(context, station),
              onEdit: (station) => _save(context, station),
              onDelete: (station) => _delete(context, station),
            ),
          ),
        },
      ),
    );
  }
}
