import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lab1/app/app_config.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/features/dashboard/widgets/telemetry_status_chip.dart';
import 'package:flutter_lab1/features/shared/formatters.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_cubit.dart';
import 'package:flutter_lab1/logic/telemetry/telemetry_state.dart';

/// Card with the MQTT broker connection, drawn from [TelemetryState].
/// The values themselves are shown on each station's screen.
class LiveTelemetrySection extends StatelessWidget {
  const LiveTelemetrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return BlocBuilder<TelemetryCubit, TelemetryState>(
      builder: (context, state) {
        final lastMessage = state.lastMessageAt;
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
                    TelemetryStatusChip(status: state.status),
                  ],
                ),
                Text('Підписка: ${AppConfig.mqttTopic}', style: muted),
                Text(
                  lastMessage == null
                      ? 'Повідомлень ще не було. Відкрийте станцію, скопіюйте '
                            'її MQTT-топік і надсилайте дані туди.'
                      : 'Останнє повідомлення: '
                            '${Formatters.relative(lastMessage)}',
                  style: muted,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
