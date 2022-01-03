import 'dart:async';

import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/presentation/drawer/navigation_drawer.dart';
import 'package:WeatherApp/app/presentation/widgets/weather_item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavouriteLocationsScreen extends StatefulWidget {
  FavouriteLocationsScreen({Key key}) : super(key: key);

  @override
  _FavouriteLocationsScreenState createState() => _FavouriteLocationsScreenState();
}

class _FavouriteLocationsScreenState extends State<FavouriteLocationsScreen> {
  bool _useCelsius = false;
  final prefsBox = Hive.box('prefs');
  final citiesBox = Hive.box('cities');

  RefreshController _refreshController;

  var _updater = Updater();

  @override
  void initState() {
    super.initState();
    _useCelsius = prefsBox.get('use_celsius', defaultValue: true);
    _refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite Locations"),
        actions: [
          ToggleButtons(
              onPressed: (int index) {
                setState(() {
                  _useCelsius = index == 0;
                  prefsBox.put('use_celsius', _useCelsius);
                });
              },
              selectedColor: Colors.white,
              selectedBorderColor: Colors.white,
              focusColor: Colors.white60,
              fillColor: Colors.blue[700],
              isSelected: [_useCelsius, !_useCelsius],
            children: [
              Text("℃", style: TextStyle(fontSize: 20)),
              Text("℉", style: TextStyle(fontSize: 20)),
            ],
          )
        ],
      ),
      drawer: MyDrawerNavigation(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
            child: _body(context),
        ),
      ),
    );
  }
  Widget _body(BuildContext context){
    var favouritesBox = Hive.box('favorite_locations');


    if(favouritesBox.isEmpty){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 40, color: Colors.red),
          const SizedBox(height: 6),
          Text(
            "No Favorite locations yet!\n Please search for your favorite location and press on the ❤ button to add to your favorites list.",
            textAlign: TextAlign.center,
          )
        ],
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 5,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        var item = favouritesBox.toMap().entries.toList()[index];
        var cityModel = CityModel.fromCity(citiesBox.get(item.key));

        return ChangeNotifierProvider(
            create: (context) => _updater,
            child: WeatherItem(city: cityModel, useCelsius: _useCelsius),
        );
      },
      itemCount: favouritesBox.keys.length,
    );
  }

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 900));
    _updater.update();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 900));

    _refreshController.loadComplete();
  }
}

class Updater extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
