import 'package:WeatherApp/app/data/datasources/remote/remote_data_source.dart';
import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/forecast_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/core/constants/constants.dart';
import 'package:WeatherApp/core/functionality/rest_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mockito/mockito.dart';

class MockRestClient extends Mock implements RestClient {}

void main() {
  RemoteDataSourceImpl dataSource;
  RestClient mockRestClient;

  final Dio tDio = Dio();

  setUp(() {
    tDio.options = BaseOptions(
      baseUrl: Constants.ENDPOINT_ACCUWEATHER,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    mockRestClient = RestClient(tDio);
    dataSource = RemoteDataSourceImpl(client: mockRestClient);
  });


  group('getCity', () {
    test(
      'returns City Details by query',
          () async {
        /// arrange

        final tQuery = 'London';
        final tCityModel = CityModel.fromJson({
          'LocalizedName': 'London',
          'Key': '328328',
        });

        /// act
        List<CityModel> result = await dataSource.getCity(tQuery);

        /// assert
        expect(result[0], equals(tCityModel));
      },
    );

    test(
      'returns City Details by geolocation',
          () async {
        /// arrange

        final tMyLocation = LocationData.fromMap({
          'latitude': 31.911381,
          'longitude': 35.0074583
        });

        final tCityModel = CityModel.fromJson({
          'LocalizedName': 'Maccabim',
          'Key': '212597',
        });

        /// act
        CityModel result = await dataSource.getCityByGeoLocation(tMyLocation.latitude, tMyLocation.longitude);

        /// assert
        expect(result, equals(tCityModel));
      },
    );
  });

  group('getWeather', () {
    test(
      'returns current weather by query',
          () async {
        /// arrange
        final tQuery = 'London';

        /// assert
        expect(await dataSource.getWeatherByKey(tQuery), isA<WeatherModel>());
      },
    );

    test(
      'returns current weather by key',
          () async {
        /// arrange
        final tKey = '328328';

        /// assert
        expect(await dataSource.getWeatherByKey(tKey), isA<WeatherModel>());
      },
    );
  });

  group('getForecast', () {
    test(
      'returns current forecast (by key)',
          () async {
        /// arrange
        final tKey = '328328';
        // final tForecastType = ForecastType.FIVE_DAYS;

        /// assert
        expect(await dataSource.getForecast(tKey), isA<ForecastModel>());
      },
    );

    test(
      'returns current forecast(5-day)+weather by key',
          () async {
        /// arrange
        final tKey = '328328';
        // final tForecastType = ForecastType.FIVE_DAYS;

        /// assert
        expect(await dataSource.getForecastAndCurrent(tKey, byKey: true), isA<Map>());
      },
    );

    test(
      'returns current forecast(5-day)+weather by query',
          () async {
        /// arrange
        final tQuery = 'London';
        // final tForecastType = ForecastType.FIVE_DAYS;

        /// assert
        expect(await dataSource.getForecastAndCurrent(tQuery, byKey: false), isA<Map>());
      },
    );
  });
}
