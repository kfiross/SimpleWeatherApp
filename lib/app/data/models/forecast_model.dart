import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/domain/entities/forecast.dart';

class ForecastModel extends Forecast{
  ForecastModel({List<WeatherRange> dailyForecasts, String conditions})
      : super(dailyForecasts: dailyForecasts, conditions: conditions);

  static ForecastModel fromForecast(Forecast forecast) =>
      ForecastModel(
          dailyForecasts: forecast.dailyForecasts,
          conditions: forecast.conditions
      );

  static ForecastModel fromJson(Map<String, dynamic> json) {
    List<WeatherRange> dailyForecasts = [];

    var daysData = json['DailyForecasts'];
    for(Map dayJson in daysData){
      dailyForecasts.add(WeatherRange.fromJson(dayJson));
    }

    return ForecastModel(
        dailyForecasts: dailyForecasts,
        conditions: json['Headline']['Text']
    );
  }
}