import 'package:WeatherApp/app/presentation/screens/favourite_locations_screen.dart';
import 'package:WeatherApp/app/presentation/screens/home_screen.dart';
import 'package:WeatherApp/core/constants/app_themes.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DrawerItem {
  String? title;
  IconData? icon;

  DrawerItem({required String title, IconData? icon});
}

class MyDrawerNavigation extends StatefulWidget {
  MyDrawerNavigation();

  @override
  State<MyDrawerNavigation> createState() => _MyDrawerNavigationState();
}

class _MyDrawerNavigationState extends State<MyDrawerNavigation> {
  final prefsBox = Hive.box('prefs');

  bool? _isDarkMode;
  @override
  Widget build(BuildContext context) {
    _isDarkMode ??= Theme.of(context).brightness ==  Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _drawerHeader(),
          ListTile(
            leading: Icon(Icons.wb_sunny_outlined),
            title: Text("Weather & Forecast"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text("Favorite Locations"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => FavouriteLocationsScreen()));
            },
          ),
          Divider(
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("OPTIONS", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ThemeSwitcher(
            builder: (ctx) {
              return SwitchListTile(
                title: Text("Dark Theme"),
                onChanged: (val){
                  _changeTheme(val, ctx);
                  // _changeTheme(val);
                },
                value: _isDarkMode ?? false,
                );}
            ),
        ],
      ),
    );
  }

  void _changeTheme(val, ctx){
    print("val=$val");

    final newTheme = val == true ? AppThemes.dark(context) : AppThemes.light(context);

    ThemeSwitcher.of(ctx).changeTheme(
      theme: newTheme,
    );

    prefsBox.put('use_dark_theme', val);

    setState(() {
      _isDarkMode = val;
    });
  }

  Widget _drawerHeader() {
    return Container(
      height: 200,
      color: Theme.of(context).primaryColor,
      child: DrawerHeader(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[

          ],
        ),
      ),
    );
  }
}