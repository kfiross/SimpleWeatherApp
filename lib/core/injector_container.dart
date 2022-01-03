import 'package:WeatherApp/app/data/datasources/local/local_data_source.dart';
import 'package:WeatherApp/app/data/datasources/remote/remote_data_source.dart';
import 'package:WeatherApp/app/data/repository/weather_repository_impl.dart';
import 'package:WeatherApp/app/domain/repository_api/weather_repository.dart';
import 'package:WeatherApp/app/presentation/state/cities_bloc/cities_bloc.dart';
import 'package:WeatherApp/app/presentation/state/forecast_bloc/forecast_bloc.dart';
import 'package:WeatherApp/app/presentation/state/weather_bloc/weather_bloc.dart';
import 'package:WeatherApp/core/functionality/rest_client.dart';
import 'package:WeatherApp/core/network/network_info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

GetIt sl = GetIt.instance;

void initLocator(){
  /// App
  // State management
  sl.registerFactory<CitiesBloc>(() => CitiesBloc(sl.get()));
  sl.registerFactory<WeatherBloc>(() => WeatherBloc(sl.get()));
  sl.registerFactory<ForecastBloc>(() => ForecastBloc(sl.get()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(
    networkInfo: sl.get(),
    localDataSource: sl.get(),
    remoteDataSource: sl.get(),
  ));

  // Data sources
  sl.registerLazySingleton<RemoteDataSource>(() => RemoteDataSourceImpl(
    client: sl.get(),
  ));
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(
    weathersBox: sl.get(),
  ));

  /// Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(
      sl.get(),
  ));

  /// External
  sl.registerLazySingleton(() => RestClient(Dio()));
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Hive.box('weathers'));
}