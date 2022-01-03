import 'dart:async';


import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:WeatherApp/app/domain/entities/forecast.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/app/domain/repository_api/weather_repository.dart';
import 'package:WeatherApp/core/enums/forecast_type.dart';
import 'package:WeatherApp/core/error/failures.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sealed_unions/implementations/union_4_impl.dart';
import 'package:sealed_unions/sealed_unions.dart';

part 'forecast_event.dart';
part 'forecast_state.dart';

class ForecastBloc extends Bloc<ForecastEvent, ForecastState> {
  WeatherRepository _repository;

  ForecastBloc(this._repository) : super(ForecastState.initial());

  // void checkInternet(){
  //   sl.get<NetworkInfo>
  // }

  @override
  Stream<ForecastState> mapEventToState(
    ForecastEvent event,
  ) async* {
    yield ForecastState.loading();

    if (event is FetchForecastEvent) {
        Either<BaseFailure, Map> failOrForecast = await _repository.getForecastAndCurrent(
          event.query,
          forecastType: event.type,
          byKey: event.byKey,
        );

        yield failOrForecast.fold(
          (failure) => ForecastState.failure(failure.message),
          (result) => ForecastState.success(result['current'], result['forecast']),
        );
    }
    else if (event is FetchForecastByGeolocationEvent){

      Either<BaseFailure, City?> failOrCity = await _repository.getCityByGeoLocation(
        event.latitude,
        event.longitude,
      );

      if(failOrCity.isLeft()){
        var message = failOrCity.fold((exception) => exception.message, (r) => null);
        yield ForecastState.failure(message);
        return;
      }

      City? city = failOrCity.getOrElse(() => throw "Exception");

      Either<BaseFailure, Map> failOrForecast = await _repository.getForecastAndCurrent(
        city?.key,
        forecastType: event.type,
        byKey: true,
      );

      yield failOrForecast.fold(
            (exception) => ForecastState.failure(exception.message),
            (result) => ForecastState.success(result['current'], result['forecast']),
      );
    }
    else if (event is NoInternetEvent){
      yield ForecastState.failure("No internet available, please turn on your mobile data");
    }
  }
}
