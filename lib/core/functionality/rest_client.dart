import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/forecast_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/core/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';

@RestApi(baseUrl: Constants.ENDPOINT_ACCUWEATHER)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("/locations/v1/cities/autocomplete")
  Future<HttpResponse<List<CityModel>>> getCities(
      @Query("apikey") String apiKey,
      @Query("q") String query,
  );

  @GET("/locations/v1/cities/geoposition/search")
  Future<HttpResponse<CityModel>> getCityByGeolocation(
      @Query("apikey") String apiKey,
      @Query("q") String query,
  );

  @GET("/currentconditions/v1/{key}")
  Future<HttpResponse<List<WeatherModel>>> getCurrentConditions(
      @Path('key') String key,
      @Query("apikey") String apiKey,
  );

  @GET("/forecasts/v1/daily/5day/{key}")
  Future<HttpResponse<ForecastModel>> getForecast5Day(
      @Path('key') String key,
      @Query("apikey") String apiKey,
      @Query("metric") bool metric,
  );
}