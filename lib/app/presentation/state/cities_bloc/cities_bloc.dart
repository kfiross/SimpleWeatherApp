import 'dart:async';

import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:WeatherApp/app/domain/repository_api/weather_repository.dart';
import 'package:WeatherApp/core/error/failures.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sealed_unions/sealed_unions.dart';

part 'cities_event.dart';
part 'cities_state.dart';

class CitiesBloc extends Bloc<CitiesEvent, CitiesState> {
  WeatherRepository _repository;

  CitiesBloc(this._repository) : super(CitiesState.initial());

  @override
  Stream<CitiesState> mapEventToState(
    CitiesEvent event,
  ) async* {
    if (event is FetchCitiesEvent) {
      Either<BaseFailure, List<City>> failOrCities = await _repository.getCity(
        event.query,
      );

      yield failOrCities.fold(
            (failure) => CitiesState.failure(failure.message),
            (cities) => CitiesState.success(cities),
      );
    }
  }
}
