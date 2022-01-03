import 'package:equatable/equatable.dart';

abstract class BaseFailure extends Equatable{
  final String? message;

  const BaseFailure(this.message);

  @override
  List<Object?> get props =>[message];
}

class NoInternetFailure extends BaseFailure{
  NoInternetFailure(String message) : super(message);

  @override
  List<Object> get props =>[];
}

class ServerFailure extends BaseFailure{
  ServerFailure([String? message]): super(message);

  @override
  List<Object?> get props =>[message];
}

class CacheFailure extends BaseFailure{
  CacheFailure([String? message]): super(message);

  @override
  List<Object?> get props =>[message];
}