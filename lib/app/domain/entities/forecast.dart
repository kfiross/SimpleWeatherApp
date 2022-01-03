import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:equatable/equatable.dart';

class Forecast extends Equatable{
  final List<WeatherRange>? dailyForecasts;
  final String? conditions;

  Forecast({this.dailyForecasts, this.conditions});

  @override
  List<Object?> get props => [dailyForecasts, conditions];

}