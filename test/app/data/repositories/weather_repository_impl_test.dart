import 'package:WeatherApp/app/data/datasources/local/local_data_source.dart';
import 'package:WeatherApp/app/data/datasources/remote/remote_data_source.dart';
import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/data/repository/weather_repository_impl.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/core/error/exceptions.dart';
import 'package:WeatherApp/core/error/failures.dart';
import 'package:WeatherApp/core/network/network_info.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRemoteDataSource extends Mock implements RemoteDataSource {}
class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  WeatherRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getWeather', () {
    final tKey = '328328';
    final tWeatherModel  =
    WeatherModel(
      cityKey: '328328',
      conditions: 'Clear',
      iconNumber: 1,
      temperature: TemperatureModel(20),
    );

    final Weather tWeather = tWeatherModel;

    test(
      'should check if the device is online',
          () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repository.getWeatherByKey(tKey);
        // assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
            () async {
          // arrange
          when(mockRemoteDataSource.getWeatherByKey(any))
              .thenAnswer((_) async => tWeatherModel);

          // act
          final result = await repository.getWeatherByKey(tKey);

          // assert
          verify(mockRemoteDataSource.getWeatherByKey(tKey));
          expect(result, equals(Right(tWeather)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
            () async {
              // arrange
              when(mockRemoteDataSource.getWeatherByKey(any))
                  .thenAnswer((_) async => tWeatherModel);

              // act
              await repository.getWeatherByKey(tKey);

              // assert
              verify(mockRemoteDataSource.getWeatherByKey(tKey));
              verify(mockLocalDataSource.cacheWeather(tKey, tWeatherModel));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
            () async {
              // arrange
              when(mockRemoteDataSource.getWeatherByKey(any))
                  .thenThrow(ServerException());

              // act
              final result = await repository.getWeatherByKey(tKey);

              // assert
              verify(mockRemoteDataSource.getWeatherByKey(tKey));
              verifyZeroInteractions(mockLocalDataSource);
              expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
            () async {
          // arrange
          when(mockLocalDataSource.getLastWeather(tKey))
              .thenAnswer((_) async => tWeatherModel);

          // act
          final result = await repository.getWeatherByKey(tKey);

          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastWeather(tKey));
          expect(result, equals(Right(tWeather)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
            () async {
          // arrange
          when(mockLocalDataSource.getLastWeather(tKey))
              .thenThrow(CacheException());
          // act
          final result = await repository.getWeatherByKey(tKey);
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(mockLocalDataSource.getLastWeather(tKey));
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}