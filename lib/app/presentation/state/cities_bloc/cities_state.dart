part of 'cities_bloc.dart';


class CitiesState extends Union4Impl<Initial, Loading, Success, Failure>{
  static final unions = const Quartet<Initial, Loading, Success, Failure>();

  CitiesState._(Union4<Initial, Loading, Success, Failure> union) : super(union);

  factory CitiesState.initial() => CitiesState._(unions.first(Initial()));

  factory CitiesState.loading() => CitiesState._(unions.second(Loading()));

  factory CitiesState.success(List<City> cities) =>
      CitiesState._(unions.third(Success(cities)));

  factory CitiesState.failure(String message) =>
      CitiesState._(unions.fourth(Failure(message)));
}

abstract class _CitiesState extends Equatable {
  const _CitiesState();
}

class Initial extends _CitiesState {
  @override
  List<Object> get props => [];
}

class Loading extends _CitiesState {
  @override
  List<Object> get props => [];
}

class Success extends _CitiesState {
  final List<City> cities;

  Success(this.cities);

  @override
  List<Object> get props => [cities];
}

class Failure extends _CitiesState {
  final String message;

  Failure(this.message);

  @override
  List<Object> get props => [message];
}

