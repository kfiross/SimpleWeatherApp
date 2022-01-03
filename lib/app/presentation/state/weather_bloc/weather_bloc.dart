import 'dart:async';

import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/app/domain/repository_api/weather_repository.dart';
import 'package:WeatherApp/core/error/failures.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sealed_unions/sealed_unions.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherRepository _repository;
  WeatherBloc(this._repository) : super(WeatherState.initial());

  @override
  Stream<WeatherState> mapEventToState(
    WeatherEvent event,
  ) async* {
    yield WeatherState.loading();
    if(event is FetchWeatherEvent){
      Either<BaseFailure, Map> failOrWeather;
      if (event.byKey != null && event.byKey) {
        failOrWeather = await _repository.getWeatherByKey(event.query);
      }
      else {
        failOrWeather = await _repository.getWeatherByQuery(event.query);
      }

      yield failOrWeather.fold(
         (exception) => WeatherState.failure(exception.message),
         (result) => WeatherState.success(result['weather'], isCached: result['isCached']));
    }
  }
}


