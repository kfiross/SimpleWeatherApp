import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:hive/hive.dart';

part 'city_model.g.dart';

@HiveType(typeId: 1)
class CityModel extends City {
  CityModel({String name, String key}) : super(key: key, name: name);

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
        name: json['LocalizedName'] as String,
        key: json['Key'] as String,
      );

  static CityModel fromCity(City city) => CityModel(
      name: city.name,
      key: city.key
  );
}
