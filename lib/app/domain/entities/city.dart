import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'city.g.dart';

@HiveType(typeId: 0)
class City extends Equatable{
  @HiveField(0)
  final name;

  @HiveField(1)
  final String key;

  City({this.name, this.key});

  @override
  List<Object> get props => [this.name, this.key];
}