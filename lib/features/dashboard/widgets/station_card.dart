import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';
import 'package:flutter_lab1/features/dashboard/widgets/status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';

enum _StationAction { edit, delete }

/// Station summary with a menu to edit or delete it.
class StationCard extends StatelessWidget {
  const StationCard({
    required this.station,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final WeatherStation station;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.m, AppSpacing.m, 0, 12),
          child: Row(
            spacing: AppSpacing.m,
            children: [
              CircleAvatar(
                backgroundColor: scheme.secondaryContainer,
                child: Icon(Icons.sensors, color: scheme.onSecondaryContainer),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${station.location} · '
                      '${Formatters.relative(station.updatedAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                    Wrap(
                      spacing: AppSpacing.s,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(isOnline: station.isOnline),
                        Text('Батарея ${station.battery}%', style: muted),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_StationAction>(
                tooltip: 'Дії зі станцією',
                onSelected: (action) => switch (action) {
                  _StationAction.edit => onEdit(),
                  _StationAction.delete => onDelete(),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: _StationAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Редагувати'),
                    ),
                  ),
                  PopupMenuItem(
                    value: _StationAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Видалити'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
