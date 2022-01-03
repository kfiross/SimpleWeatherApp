import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/forecast_model.dart';
import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:WeatherApp/config_reader.dart';
import 'package:WeatherApp/core/enums/forecast_type.dart';
import 'package:WeatherApp/core/error/exceptions.dart';
import 'package:WeatherApp/core/functionality/rest_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:retrofit/dio.dart';

abstract class RemoteDataSource{
  Future<List<CityModel>> getCity(String query);
  Future<CityModel> getCityByGeoLocation(double lat, double lon);
  Future<WeatherModel> getWeatherByQuery(String query);
  Future<WeatherModel> getWeatherByKey(String key);
  Future<ForecastModel> getForecast(String cityKey, {ForecastType forecastType});

  Future<Map> getForecastAndCurrent(String query, {ForecastType forecastType, bool byKey});
}

class RemoteDataSourceImpl extends RemoteDataSource{
  final RestClient client;

  RemoteDataSourceImpl({@required this.client});

  @override
  Future<List<CityModel>> getCity(String query) async{
    List<CityModel> cities = [];

    HttpResponse<List<City>> httpResponse;
    try {
      httpResponse = await client.getCities(ConfigReader.accweatherApiKey, query);
    }
    catch(e){
      if (e is DioError) {
        final res = e.response;
        throw ServerException("${res.data['Message']}");
      } else {
        throw ServerException('Unknown Error');
      }
    }

    cities.addAll(httpResponse.data.map((c) => CityModel.fromCity(c)));
    return cities;
  }

  @override
  Future<CityModel> getCityByGeoLocation(double lat, double lon) async{
    final String query = "$lat,$lon";

    HttpResponse httpResponse;
    try {
      httpResponse = await client.getCityByGeolocation(ConfigReader.accweatherApiKey, query);
    }
    catch(e){
      if (e is DioError) {
        final res = e.response;
         throw ServerException("${res.data['Message']}");
      } else {
        throw ServerException('Unknown Error');
      }
    }

    CityModel city = httpResponse.data;

    // save city for more efficient fetch in future requests
    var searchedBox = Hive.box('cities');
    if(!searchedBox.containsKey(city.key)){
      searchedBox.put(city.key, city);
    }

    return city;
  }

  @override
  Future<ForecastModel> getForecast(String cityKey, {ForecastType forecastType}) async{
    if(forecastType == null){
      forecastType = ForecastType.FIVE_DAYS;
    }

    Future httpResponseFuture;
    switch(forecastType){
      case ForecastType.FIVE_DAYS:
        httpResponseFuture = client.getForecast5Day(
            cityKey,
            ConfigReader.accweatherApiKey,
            true,
        );
        break;
    }

    // then, fetch the location's forcast for the the next days (by forecastType)
    HttpResponse httpResponse;
    try {
      httpResponse = await httpResponseFuture;
    }
    catch(e) {
      if (e is DioError) {
        final res = e.response;
        throw ServerException("${res.data['Message']}");
      } else {
        throw ServerException('Unknown Error');
      }
    }
    var forecast = httpResponse.data;
    return forecast;
  }

  @override
  Future<Map> getForecastAndCurrent(String query, {ForecastType forecastType, bool byKey}) async{
    if(forecastType == null){
      forecastType = ForecastType.FIVE_DAYS;
    }

    WeatherModel weather;
    ForecastModel forecast;

    try {
      if (byKey != null && byKey) {
        // query is key
        weather = await getWeatherByKey(query);
      }
      else {
        // query is city's name
        weather = await getWeatherByQuery(query);
      }
    }
    on ServerException catch (e){
      throw ServerException(e.message);
    }

    try {
      forecast = await getForecast(weather.cityKey, forecastType: forecastType);
    }
    on ServerException catch (e){
      throw ServerException(e.message);
    }

    return {
      'current': weather,
      'forecast': forecast,
    };
  }

  @override
  Future<WeatherModel> getWeatherByKey(String key) async{
    HttpResponse<List<WeatherModel>> httpResponse;
    try {
      httpResponse = await client.getCurrentConditions(
          key, ConfigReader.accweatherApiKey);
    }
    catch(e) {
      if (e is DioError) {
        final res = e.response;
        throw ServerException("${res.data['Message']}");
      } else {
        throw ServerException('Unknown Error');
      }
    }

    var weather = WeatherModel(
      cityKey: key,
      epochTime: httpResponse.data[0].epochTime,
      conditions: httpResponse.data[0].conditions,
      temperature: httpResponse.data[0].temperature,
      iconNumber: httpResponse.data[0].iconNumber,
    );

    return weather;
  }

  @override
  Future<WeatherModel> getWeatherByQuery(String query) async{
    // first, fetch the (best-matched) location's key
    var cities;
    try {
      cities = await getCity(query);
    }
    on ServerException catch (e){
      throw ServerException(e.message);
    }

    if(cities.isEmpty){
      throw ServerException("We couldn't find a city with the query you entered");
    }

    var city = cities[0];

    // save city for more efficient fetch in future requests
    var searchedBox = Hive.box('cities');
    if(!searchedBox.containsKey(city.key)){
      searchedBox.put(city.key, city);
    }

    // then, fetch the city's current conditions
    HttpResponse<List<WeatherModel>> httpResponse;
    try {
      httpResponse = await client.getCurrentConditions(
          city.key, ConfigReader.accweatherApiKey);
    }
    catch(e) {
      if (e is DioError) {
        final res = e.response;
         throw ServerException("${res.data['Message']}");
      } else {
        throw ServerException('Unknown Error');
      }
    }

    var weather = WeatherModel(
      cityKey: city.key,
      conditions: httpResponse.data[0].conditions,
      temperature: TemperatureModel(httpResponse.data[0].temperature.celsius),
      iconNumber: httpResponse.data[0].iconNumber,
    );

    return weather;
  }

}