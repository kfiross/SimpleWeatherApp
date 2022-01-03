part of 'weather_bloc.dart';

class WeatherState extends Union4Impl<Initial, Loading, Success, Failure> {
  static final unions = const Quartet<Initial, Loading, Success, Failure>();

  WeatherState._(Union4<Initial, Loading, Success, Failure> union) : super(union);

  factory WeatherState.initial() => WeatherState._(unions.first(Initial()));

  factory WeatherState.loading() => WeatherState._(unions.second(Loading()));

  factory WeatherState.success(Weather? weather, {bool? isCached}) =>
      WeatherState._(unions.third(Success(weather, isCached: isCached)));

  factory WeatherState.failure(String? message) =>
      WeatherState._(unions.fourth(Failure(message)));
}

abstract class _WeatherState extends Equatable {
  const _WeatherState();
}

class Initial extends _WeatherState {
  @override
  List<Object> get props => [];
}

class Loading extends _WeatherState {
  @override
  List<Object> get props => [];
}

class Success extends _WeatherState {
  final Weather? weather;
  final bool? isCached;

  Success(this.weather, {this.isCached});

  @override
  List<Object?> get props => [weather];
}

class Failure extends _WeatherState {
  final String? message;

  Failure(this.message);

  @override
  List<Object?> get props => [message];
}