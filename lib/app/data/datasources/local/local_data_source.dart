import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/core/error/exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

abstract class LocalDataSource{
  Future<WeatherModel> getLastWeather(String cityKey);
  Future<void> cacheWeather(String cityKey, WeatherModel weatherToCache);
}

class LocalDataSourceImpl extends LocalDataSource{
  final Box weathersBox;

  LocalDataSourceImpl({@required this.weathersBox});

  @override
  Future<WeatherModel> getLastWeather(String cityKey){
    var result = weathersBox.get(cityKey);
    if(result == null){
      throw CacheException("Could not get last known weather on this city");
    }
    return Future.value(result);
  }

  @override
  Future<void> cacheWeather(String cityKey, WeatherModel weatherToCache) async{
    await weathersBox.put(cityKey, weatherToCache);
  }
}