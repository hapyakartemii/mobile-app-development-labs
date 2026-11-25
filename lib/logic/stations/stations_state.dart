import 'package:equatable/equatable.dart';
import 'package:flutter_lab1/domain/entities/weather_station.dart';

enum StationsStatus { initial, loading, loaded, failure }

/// Immutable list of the user's stations plus what the screen shows
/// around it. Every change creates a new state via [copyWith].
class StationsState extends Equatable {
  const StationsState({
    this.status = StationsStatus.initial,
    this.stations = const [],
    this.isBusy = false,
    this.error,
    this.message,
    this.messageId = 0,
  });

  final StationsStatus status;
  final List<WeatherStation> stations;

  /// A create / update / delete request is running (overlay spinner).
  final bool isBusy;

  /// Why loading failed (shown instead of the list).
  final String? error;

  /// One-off feedback for a SnackBar; [messageId] grows with each one, so
  /// the same text twice is still shown twice.
  final String? message;
  final int messageId;

  WeatherStation? byId(String id) =>
      stations.where((station) => station.id == id).firstOrNull;

  StationsState copyWith({
    StationsStatus? status,
    List<WeatherStation>? stations,
    bool? isBusy,
    String? error,
  }) => StationsState(
    status: status ?? this.status,
    stations: stations ?? this.stations,
    isBusy: isBusy ?? this.isBusy,
    error: error ?? this.error,
    message: message,
    messageId: messageId,
  );

  /// Same state plus a new SnackBar message; the busy spinner stops.
  StationsState withMessage(String text) => StationsState(
    status: status,
    stations: stations,
    error: error,
    message: text,
    messageId: messageId + 1,
  );

  @override
  List<Object?> get props => [
    status,
    stations,
    isBusy,
    error,
    message,
    messageId,
  ];
}
