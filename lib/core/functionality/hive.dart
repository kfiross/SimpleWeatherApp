import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/domain/entities/city.dart';
import 'package:WeatherApp/app/domain/entities/temperature.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

Future<void> initHive() async {
  if (kIsWeb) {
    Hive.init('');
  } else {
    final appDocumentDirectory =
        await pathProvider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  }

  Hive.registerAdapter(CityAdapter());
  Hive.registerAdapter(CityModelAdapter());
  Hive.registerAdapter(WeatherAdapter());
  Hive.registerAdapter(WeatherModelAdapter());
  Hive.registerAdapter(TemperatureAdapter());
  Hive.registerAdapter(TemperatureModelAdapter());

  await Hive.openBox(
    "favorite_locations",
  );

  await Hive.openBox(
    "cities", // keeps all searched cities
  );

  await Hive.openBox(
    "history_queries",
  );

  await Hive.openBox(
    "weathers",
  );

  await Hive.openBox('prefs');
}
