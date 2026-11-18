import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/widgets/station_card.dart';
import 'package:flutter_lab1/features/shared/widgets/app_button.dart';
import 'package:flutter_lab1/features/shared/widgets/section_header.dart';

/// "My stations" section: list of cards or an empty state.
class StationList extends StatelessWidget {
  const StationList({
    required this.stations,
    required this.onAdd,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<WeatherStation> stations;
  final VoidCallback onAdd;
  final ValueChanged<WeatherStation> onOpen;
  final ValueChanged<WeatherStation> onEdit;
  final ValueChanged<WeatherStation> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s,
      children: [
        SectionHeader(
          title: 'Мої станції (${stations.length})',
          actionLabel: 'Додати',
          onAction: onAdd,
        ),
        if (stations.isEmpty) _EmptyStations(onAdd: onAdd),
        for (final station in stations)
          StationCard(
            key: ValueKey(station.id),
            station: station,
            onTap: () => onOpen(station),
            onEdit: () => onEdit(station),
            onDelete: () => onDelete(station),
          ),
      ],
    );
  }
}

class _EmptyStations extends StatelessWidget {
  const _EmptyStations({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          spacing: AppSpacing.s,
          children: [
            Icon(
              Icons.sensors_off_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            Text('Ще немає станцій', style: theme.textTheme.titleMedium),
            const Text(
              'Додайте першу метеостанцію, щоб бачити її показники',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            AppButton(
              label: 'Додати станцію',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
