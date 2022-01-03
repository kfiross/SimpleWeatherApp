part of 'cities_bloc.dart';

abstract class CitiesEvent extends Equatable {
  const CitiesEvent();
}

class FetchCitiesEvent extends CitiesEvent{
  final String query;

  FetchCitiesEvent(this.query);

  @override
  List<Object> get props => [query];
}