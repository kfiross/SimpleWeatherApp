part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
}

class FetchWeatherEvent extends WeatherEvent{
  final String query;
  final bool byKey;

  FetchWeatherEvent(this.query, {this.byKey});

  @override
  List<Object> get props => [query, byKey];

}



