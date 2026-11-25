import 'package:flutter/material.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/widgets/status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/info_tile.dart';

/// Location, online state, battery and last update of a station.
class StationInfoCard extends StatelessWidget {
  const StationInfoCard({required this.station, super.key});

  final WeatherStation station;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InfoTile(
            icon: Icons.place_outlined,
            label: 'Розташування',
            value: station.location,
          ),
          ListTile(
            leading: const Icon(Icons.wifi_tethering),
            title: const Text('Стан'),
            trailing: StatusChip(isOnline: station.isOnline),
          ),
          InfoTile(
            icon: Icons.battery_std,
            label: 'Батарея',
            value: '${station.battery}%',
          ),
          InfoTile(
            icon: Icons.update,
            label: 'Останнє оновлення',
            value: Formatters.relative(station.updatedAt),
          ),
        ],
      ),
    );
  }
}
