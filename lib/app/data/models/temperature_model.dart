import 'package:WeatherApp/app/domain/entities/temperature.dart';
import 'package:WeatherApp/core/enums/temperature_unit.dart';
import 'package:hive/hive.dart';

part 'temperature_model.g.dart';

@HiveType(typeId: 5)
class TemperatureModel extends Temperature{
  TemperatureModel(double celsius) : super(celsius);

  double get fahrenheit => celsius * 1.8 + 32.0;

  // ignore: missing_return
  String toStringWithUnit(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return "${celsius.toInt()} ℃";
      case TemperatureUnit.fahrenheit:
        return "${fahrenheit.toInt()} ℉";
    }
  }

  static TemperatureModel fromTemprature(Temperature temperature)
      => TemperatureModel(temperature.celsius);
}

class TemperatureRange{
  final TemperatureModel min;
  final TemperatureModel max;

  TemperatureRange(this.min, this.max);

  TemperatureRange.fromJson(Map<String, dynamic> json)
    : min = TemperatureModel(json['Minimum']['Value']),
      max = TemperatureModel(json['Maximum']['Value']);


  // ignore: missing_return
  String toStringWithUnit(TemperatureUnit unit) {
    switch(unit){
      case TemperatureUnit.celsius:
        return "${min.celsius.toInt()}° / ${max.celsius.toInt()} ℃";
      case TemperatureUnit.fahrenheit:
        return "${min.fahrenheit.toInt()}° / ${max.fahrenheit.toInt()} ℉";
    }
  }
}