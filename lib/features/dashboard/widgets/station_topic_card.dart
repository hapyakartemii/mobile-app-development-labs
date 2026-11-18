import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lab1/app/theme/app_theme.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';
import 'package:flutter_lab1/features/dashboard/widgets/telemetry_status_chip.dart';
import 'package:flutter_lab1/features/shared/widgets/app_message.dart';

/// The station's MQTT topic with a copy button, so it can be pasted into
/// MQTT Explorer or passed to `tool/sensor_publisher.dart`.
class StationTopicCard extends StatelessWidget {
  const StationTopicCard({
    required this.topic,
    required this.status,
    super.key,
  });

  final String topic;
  final TelemetryStatus status;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: topic));
    if (context.mounted) showAppMessage(context, 'Топік скопійовано');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          spacing: AppSpacing.s,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.xs,
                children: [
                  Row(
                    spacing: AppSpacing.s,
                    children: [
                      Text('MQTT-топік', style: textTheme.titleSmall),
                      TelemetryStatusChip(status: status),
                    ],
                  ),
                  SelectableText(topic, style: textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Скопіювати топік',
              icon: const Icon(Icons.copy),
              onPressed: () => _copy(context),
            ),
          ],
        ),
      ),
    );
  }
}
