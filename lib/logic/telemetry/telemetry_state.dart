import 'package:equatable/equatable.dart';
import 'package:flutter_lab1/domain/entities/telemetry.dart';

/// MQTT connection shown on the dashboard and station screens.
class TelemetryState extends Equatable {
  const TelemetryState({
    this.status = TelemetryStatus.disconnected,
    this.lastMessageAt,
  });

  final TelemetryStatus status;

  /// When the last message from any station arrived, or `null`.
  final DateTime? lastMessageAt;

  TelemetryState copyWith({TelemetryStatus? status, DateTime? lastMessageAt}) =>
      TelemetryState(
        status: status ?? this.status,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      );

  @override
  List<Object?> get props => [status, lastMessageAt];
}
