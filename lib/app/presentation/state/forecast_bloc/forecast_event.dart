part of 'forecast_bloc.dart';

abstract class ForecastEvent extends Equatable {
  const ForecastEvent();
}

class FetchForecastEvent extends ForecastEvent{
  final String? query;   // a name of a city if byKey is false, otherwise city's Key
  final ForecastType? type;
  final bool? byKey;

  FetchForecastEvent(this.query, {this.type, this.byKey});

  @override
  List<Object?> get props => [query, type];

}

class FetchForecastByGeolocationEvent extends ForecastEvent{
  final double? latitude;
  final double? longitude;
  final ForecastType? type;

  FetchForecastByGeolocationEvent(this.latitude, this.longitude, {this.type});

  @override
  List<Object?> get props => [latitude, longitude, type];
}

class NoInternetEvent extends ForecastEvent{
  @override
  List<Object> get props => [];

}
