import 'package:WeatherApp/core/functionality/hive.dart';
import 'package:WeatherApp/core/injector_container.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

import 'app/presentation/screens/home_screen.dart';
import 'config_reader.dart';
import 'core/constants/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the JSON config into memory
  await ConfigReader.initialize();

  await initHive();
  initLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var prefsBox = Hive.box('prefs');
    bool isPlatformDark = prefsBox.get('use_dark_theme', defaultValue: false);
    final initTheme = isPlatformDark ? AppThemes.dark(context) : AppThemes.light(context);

    return ThemeProvider(
      initTheme: initTheme,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            builder: (context, child) {
              return ThemeSwitchingArea(
                child: Builder(
                  builder: (context) {
                    return child ?? const SizedBox.shrink();
                  }
                ),
              );
            },
            debugShowCheckedModeBanner: false,
            title: 'Weather App',
            theme: initTheme, //?ThemeSwitcher.of(context),
            home: HomeScreen(),
            // home: ThemeSwitchingArea(
            //     child: Builder(
            //       builder: (context) {
            //         return HomeScreen();
            //       }
            //     )
            // ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // close the all the opened Hive boxes
    Hive.close();

    super.dispose();
  }
}
