import 'package:WeatherApp/app/data/datasources/local/local_data_source.dart';
import 'package:WeatherApp/app/data/datasources/remote/remote_data_source.dart';
import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:WeatherApp/app/domain/entities/forecast.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/app/domain/repository_api/weather_repository.dart';
import 'package:WeatherApp/core/enums/forecast_type.dart';
import 'package:WeatherApp/core/error/exceptions.dart';
import 'package:WeatherApp/core/error/failures.dart';
import 'package:WeatherApp/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

class WeatherRepositoryImpl extends WeatherRepository{
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo,
  });

  @override
  Future<Either<BaseFailure, List<City>>> getCity(String query) async {
    try {
      await _checkInternetConnection();
      final cities = await remoteDataSource.getCity(query);
      return Right(cities);
    }
    on ServerException catch (e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      return Left(NoInternetFailure("No internet available, please turn on your mobile data"));
    }
  }

  @override
  Future<Either<BaseFailure, City>> getCityByGeoLocation
      (double lat, double lon) async{
    try {
      await _checkInternetConnection();
      final city = await remoteDataSource.getCityByGeoLocation(lat, lon);
      return Right(city);
    }
    on ServerException catch (e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      return Left(NoInternetFailure("No internet available, please turn on your mobile data"));
    }
  }

  @override
  Future<Either<BaseFailure, Map>> getWeatherByQuery(String query) async {
    try {
      await _checkInternetConnection();
      final weather = await remoteDataSource.getWeatherByQuery(query);
      return Right({'weather' : weather, 'isCached': false});
    }
    on ServerException catch (e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      return Left(NoInternetFailure("No internet available, please turn on your mobile data"));
    }
  }

  @override
  Future<Either<BaseFailure ,Map>> getWeatherByKey(String key) async {
    Weather weather;
    bool isCached = false;
    try {
      await _checkInternetConnection();
      weather = await remoteDataSource.getWeatherByKey(key);
      await localDataSource.cacheWeather(key, weather);
    }
    on ServerException catch (e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      try {
        isCached = true;
        weather = await localDataSource.getLastWeather(key);
      }
      on CacheException catch(e){
        return Left(CacheFailure(e.message));
      }
    }
    return Right({'weather' : weather, 'isCached': isCached});
  }

  @override
  Future<Either<BaseFailure,Forecast>> getForecast(String cityKey, {ForecastType forecastType}) async {
    try {
      await _checkInternetConnection();
      final forecast = await remoteDataSource.getForecast(cityKey, forecastType: forecastType);
      return Right(forecast);
    }
    on ServerException catch (e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      return Left(NoInternetFailure("No internet available, please turn on your mobile data"));
    }
  }

  @override
  Future<Either<BaseFailure, Map>> getForecastAndCurrent(String cityKey, {ForecastType forecastType, bool byKey}) async {
    try {
      await _checkInternetConnection();
      Map result = await remoteDataSource.getForecastAndCurrent(
          cityKey, forecastType: forecastType, byKey: byKey);
      return Right(result);
    }
    on ServerException catch(e){
      return Left(ServerFailure(e.message));
    }
    on NoInternetException {
      return Left(NoInternetFailure("No internet available, please turn on your mobile data"));
    }
  }

  Future<void> _checkInternetConnection() async{
    if(!await networkInfo.isConnected){
      throw NoInternetException();
    }
  }
}
