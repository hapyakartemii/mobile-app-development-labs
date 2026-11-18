import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/features/dashboard/live_telemetry_controller.dart';
import 'package:flutter_lab1/features/dashboard/sensor_readings.dart';
import 'package:flutter_lab1/features/dashboard/widgets/sensor_tile.dart';
import 'package:flutter_lab1/features/dashboard/widgets/telemetry_status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/features/shared/widgets/responsive_grid.dart';
import 'package:provider/provider.dart';

/// Live values from the MQTT broker.
///
/// [ChangeNotifierProvider] creates the [LiveTelemetryController] when the
/// dashboard opens and calls its `dispose` (cancelling all stream
/// subscriptions) when the dashboard closes.
class LiveTelemetrySection extends StatelessWidget {
  const LiveTelemetrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);

    return ChangeNotifierProvider(
      create: (_) => LiveTelemetryController(
        telemetry: scope.telemetryService,
        connectivity: scope.connectivityService,
      )..start(),
      child: const _LiveTelemetryView(),
    );
  }
}

/// Rebuilt by `context.watch` on every `notifyListeners()` — i.e. on each
/// MQTT message — while the rest of the dashboard stays untouched.
class _LiveTelemetryView extends StatelessWidget {
  const _LiveTelemetryView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveTelemetryController>();
    final lastUpdate = controller.lastMessageAt;
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s,
      children: [
        Row(
          spacing: AppSpacing.s,
          children: [
            Expanded(
              child: Text(
                'Топік: ${controller.topic}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ),
            TelemetryStatusChip(status: controller.status),
          ],
        ),
        ResponsiveGrid(
          children: [
            for (final metric in SensorMetric.values)
              SensorTile(
                reading: SensorReading.of(
                  metric,
                  controller.latest(metric)?.value,
                ),
              ),
          ],
        ),
        Text(
          lastUpdate == null
              ? 'Очікуємо повідомлення від датчиків…'
              : 'Останнє повідомлення: ${Formatters.relative(lastUpdate)}',
          style: muted,
        ),
      ],
    );
  }
}
