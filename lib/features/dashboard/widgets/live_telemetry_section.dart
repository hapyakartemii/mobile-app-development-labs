import 'package:flutter/material.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/app/app_scope.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/features/dashboard/live_telemetry_controller.dart';
import 'package:flutter_lab1/features/dashboard/widgets/telemetry_status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:provider/provider.dart';

/// Card with the MQTT broker connection on the dashboard.
///
/// [ChangeNotifierProvider] creates the [LiveTelemetryController] when the
/// dashboard opens (it connects to the broker) and calls its `dispose`
/// when the dashboard closes (subscriptions cancelled, connection closed).
/// The values themselves are shown on each station's screen.
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
      child: const _BrokerCard(),
    );
  }
}

/// Rebuilt by `context.watch` on every `notifyListeners()`: a new status
/// or a message from any station.
class _BrokerCard extends StatelessWidget {
  const _BrokerCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveTelemetryController>();
    final lastMessage = controller.lastMessageAt;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s,
          children: [
            Row(
              spacing: AppSpacing.s,
              children: [
                Icon(Icons.podcasts, color: theme.colorScheme.primary),
                Expanded(
                  child: Text(
                    AppConfig.mqttHost,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                TelemetryStatusChip(status: controller.status),
              ],
            ),
            Text('Підписка: ${controller.topic}', style: muted),
            Text(
              lastMessage == null
                  ? 'Повідомлень ще не було. Відкрийте станцію, скопіюйте її '
                        'MQTT-топік і надсилайте дані туди.'
                  : 'Останнє повідомлення: ${Formatters.relative(lastMessage)}',
              style: muted,
            ),
          ],
        ),
      ),
    );
  }
}
