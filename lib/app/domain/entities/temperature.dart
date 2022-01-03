import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'temperature.g.dart';

@HiveType(typeId: 4)
class Temperature extends Equatable{
  @HiveField(0)
  final double? celsius;

  Temperature(this.celsius);

  @override
  List<Object?> get props => [celsius];
}