part of 'forecast_bloc.dart';

class ForecastState extends Union4Impl<Initial, Loading, Success, Failure>{
  static final unions = const Quartet<Initial, Loading, Success, Failure>();

  ForecastState._(Union4<Initial, Loading, Success, Failure> union) : super(union);

  factory ForecastState.initial() => ForecastState._(unions.first(Initial()));

  factory ForecastState.loading() => ForecastState._(unions.second(Loading()));

  factory ForecastState.success(Weather current, Forecast forecast) =>
      ForecastState._(unions.third(Success(current, forecast)));

  factory ForecastState.failure(String message) =>
      ForecastState._(unions.fourth(Failure(message)));
}

abstract class _ForecastState extends Equatable {
  const _ForecastState();
}

class Initial extends _ForecastState {
  @override
  List<Object> get props => [];
}

class Loading extends _ForecastState {
  @override
  List<Object> get props => [];
}

class Success extends _ForecastState {
  final Forecast forecast;
  final Weather current;

  Success(this.current, this.forecast);

  @override
  List<Object> get props => [forecast];
}

class Failure extends _ForecastState {
  final String message;

  Failure(this.message);

  @override
  List<Object> get props => [message];
}
