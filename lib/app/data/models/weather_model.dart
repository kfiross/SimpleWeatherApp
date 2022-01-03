import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:hive/hive.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 3)
class WeatherModel extends Weather {
  WeatherModel({
    String? cityKey,
    int? epochTime,
    TemperatureModel? temperature,
    String? conditions,
    int? iconNumber,
  })
      : super(
    cityKey: cityKey,
    epochTime: epochTime,
    temperature: temperature,
    conditions: conditions,
    iconNumber: iconNumber,
  );

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      WeatherModel(
        // city: city,
        epochTime: json['EpochTime'] as int?,
        iconNumber: json['WeatherIcon'] as int?,
        conditions: json['WeatherText'] as String?,
        temperature: TemperatureModel(json['Temperature']['Metric']['Value'] as double?),
      );

  static WeatherModel fromWeather(Weather weather) {
    return WeatherModel(
      cityKey: weather.cityKey,
      temperature: TemperatureModel.fromTemprature(weather.temperature!),
      conditions: weather.conditions,
      iconNumber: weather.iconNumber,
    );
  }
}

class WeatherRange {
  // final TemperatureRange temperatureRange; // default if in Celsius
  final WeatherModel day;
  final WeatherModel night;
  WeatherRange(this.day, this.night);

  WeatherRange.fromJson(Map<String, dynamic> json)
      : day = WeatherModel(
    temperature: TemperatureModel(json['Temperature']['Maximum']['Value']),
    iconNumber: json['Day']['Icon'],
    conditions:  json['Day']['IconPhrase'],
  ),
        night = WeatherModel(
          temperature: TemperatureModel(json['Temperature']['Minimum']['Value']),
          iconNumber: json['Night']['Icon'],
          conditions: json['Day']['IconPhrase'],
        );


  TemperatureRange get temperatureRange => TemperatureRange(night.temperature as TemperatureModel?, day.temperature as TemperatureModel?);
}
