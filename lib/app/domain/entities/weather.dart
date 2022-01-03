import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import 'temperature.dart';

part 'weather.g.dart';


@HiveType(typeId: 2)
class Weather extends Equatable {
  @HiveField(0)
  final String cityKey;

  @HiveField(1)
  final int epochTime;

  @HiveField(2)
  final String conditions;

  @HiveField(3)
  final int iconNumber;

  @HiveField(4)
  final Temperature temperature;

  Weather({
    @required this.cityKey,
    @required this.conditions,
    @required this.iconNumber,
    @required this.temperature,
    @required this.epochTime,
  });

  @override
  List<Object> get props => [cityKey, conditions, iconNumber, temperature];

}
