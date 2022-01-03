import 'package:WeatherApp/core/error/failures.dart';

import '../entities/city.dart';
import '../entities/forecast.dart';
import 'package:WeatherApp/core/enums/forecast_type.dart';
import 'package:dartz/dartz.dart';

abstract class WeatherRepository {
  Future<Either<BaseFailure, List<City>>> getCity(String query);
  Future<Either<BaseFailure, City>> getCityByGeoLocation(double? lat, double? lon);
  Future<Either<BaseFailure, Map>> getWeatherByQuery(String? query);
  Future<Either<BaseFailure, Map>> getWeatherByKey(String? key);
  Future<Either<BaseFailure, Forecast>> getForecast(String cityKey, {ForecastType? forecastType});

  Future<Either<BaseFailure, Map>> getForecastAndCurrent(String? cityKey, {ForecastType? forecastType, bool? byKey});
}