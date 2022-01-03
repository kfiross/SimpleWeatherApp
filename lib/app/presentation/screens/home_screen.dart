import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/forecast_model.dart';
import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/domain/entities/forecast.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/app/presentation/drawer/navigation_drawer.dart';
import 'package:WeatherApp/app/presentation/state/cities_bloc/cities_bloc.dart';
import 'package:WeatherApp/app/presentation/state/forecast_bloc/forecast_bloc.dart';
import 'package:WeatherApp/app/presentation/widgets/search_bar.dart';
import 'package:WeatherApp/core/network/network_info.dart';
import 'package:WeatherApp/core/utils/string_utils.dart';
import 'package:WeatherApp/core/enums/temperature_unit.dart';
import 'package:WeatherApp/core/injector_container.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomeScreen extends StatefulWidget {
  final CityModel? city;

  const HomeScreen({Key? key, this.city}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ignore: close_sinks
  final _forecastBloc = sl.get<ForecastBloc>();
  // ignore: close_sinks
  final _citiesBloc = sl.get<CitiesBloc>();

  // Hive boxes
  final prefsBox = Hive.box('prefs');
  final citiesBox = Hive.box('cities');
  var favouritesBox = Hive.box('favorite_locations');

  // Controllers
  late RefreshController _refreshController;
  late AnimationController _lottieController;
  
  // state members
  bool? _useCelsius = false;
  CityModel? _currentCity;


  @override
  void initState() {
    super.initState();

    _refreshController = RefreshController(initialRefresh: false);
    _lottieController = AnimationController(vsync: this);

    _useCelsius = prefsBox.get('use_celsius', defaultValue: true);

    if (widget.city != null) {
      _forecastBloc.add(FetchForecastEvent(widget.city!.key, byKey: true));
    }
    else{
      _showCurrentLocationForecast();
    }
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
        title: Text("Weather & Forecast"),
        actions: [
          ToggleButtons(
            selectedColor: Colors.white,
            selectedBorderColor: Colors.white,
            focusColor: Colors.white60,
            fillColor: Colors.blue[700],
            onPressed: (int index) {
              setState(() {
                _useCelsius = index == 0;
                prefsBox.put('use_celsius', _useCelsius);
              });
            },
            isSelected: [_useCelsius!, !_useCelsius!],
            children: [
              Text("℃", style: TextStyle(fontSize: 20)),
              Text("℉", style: TextStyle(fontSize: 20)),
            ],
          )
        ],
      ),
      drawer: MyDrawerNavigation(),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SearchBar(
          onAdd: (String selectedTerm){
            _citiesBloc.add(FetchCitiesEvent(selectedTerm));
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(top: 60),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                _citiesBody(context),
                Expanded(child: _forecastBody(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _citiesBody(BuildContext context) {
    return BlocListener(
        bloc: _citiesBloc,
        listener: (context, CitiesState state) {
          state.join(
                (_) => null,
                (_) => null,
                (success) {
                  final cities = success.cities;

                  final dialog = AlertDialog(
                    title: Text("Choose A city"),
                    actions: [
                      FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Close"),
                      ),
                    ],
                    content: cities.isEmpty
                    ? Text("No Cities Found, try to enter another query...")
                    : Container(
                      width: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: success.cities.length,
                        itemBuilder: (context, index){
                          final city = cities[index];
                          return ListTile(
                            title: Text(city.name),
                            onTap: (){
                              // save for caching
                              var searchedBox = Hive.box('cities');
                              if(!searchedBox.containsKey(city.key)){
                                searchedBox.put(city.key, city);
                              }

                              _forecastBloc.add(FetchForecastEvent(city.key, byKey: true));
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  );

                  showDialog(context: context, builder: (_) => dialog);
                },
                (failure) {
              final dialog = AlertDialog(
                title: Text("Error"),
                content: Text(failure.message!),
                actions: [
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
              showDialog(context: context, builder: (_) => dialog);
            },
          );
        },
        child: Container(),
    );
  }

  Widget _forecastBody(BuildContext context) {
    return BlocListener(
      bloc: _forecastBloc,
      listener: (context, ForecastState state) {
       state.join(
          (_) => null,
          (_) => null,
          (success) { },
          (failure) {
            final dialog = AlertDialog(
              title: Text("Error"),
              content: Text(failure.message!),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
            showDialog(context: context, builder: (_) => dialog);
          },
       );
      },
      child: BlocBuilder(
        bloc: _forecastBloc,
        builder: (context, ForecastState state) {
        return state.join(
            (initial) => Center(child: Text("")),
            (loading) => Center(child: CircularProgressIndicator()),
            (success) => _buildData(success.current!, success.forecast!),
            (failure) => _buildError(failure),
        );
      },
    ));
  }

  Widget _buildWeatherInfo(WeatherModel weather) {
    final city = citiesBox.get(weather.cityKey);

    return OrientationLayoutBuilder(
      portrait: (context) => Container(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Container(
                  width: MediaQuery.of(context).size.width *0.7,
                  height: 120,
                  child: Stack(
                    children: [
                      Positioned(
                        left: -30,
                        child: Container(
                          height: 80,
                          width: 120,
                          child: CachedNetworkImage(
                            imageUrl: StringUtils.getWeatherIconUrl(weather.iconNumber!),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (weather.temperature as TemperatureModel).toStringWithUnit(_useCelsius! ? TemperatureUnit.celsius : TemperatureUnit.fahrenheit),
                              style: TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weather.conditions!,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              _buildFavouritesButton(weather),
            ],
          ),
      ),
      landscape: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Container(
                width: MediaQuery.of(context).size.width *0.7,
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: -20,
                      child: Container(
                        height: 70,
                        width: 110,
                        child: CachedNetworkImage(
                          imageUrl: StringUtils.getWeatherIconUrl(weather.iconNumber!),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            style: TextStyle(fontSize: 38 * 0.7, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (weather.temperature as TemperatureModel).toStringWithUnit(_useCelsius! ? TemperatureUnit.celsius : TemperatureUnit.fahrenheit),
                            style: TextStyle(fontSize: 26* 0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weather.conditions!,
                            style: TextStyle(fontSize: 20* 0.7),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            _buildFavouritesButton(weather),
          ],
        ),
      ),
    );

  }

  Widget _buildFavouritesButton(WeatherModel weather){
    final isInFavourites = favouritesBox.containsKey(weather.cityKey);

    return Tooltip(
      message: "${isInFavourites ? 'Remove from' : 'Add to'} favourites",
      child: InkWell(
        child: Lottie.asset(
          'assets/34905-like-icon.json',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          controller: _lottieController,
          onLoaded: (composition) {
            _lottieController
              ..duration = Duration(milliseconds: 1200)
              ..value = isInFavourites? 0.8 : 0;
          },
        ),
        onTap: () {
          if (!favouritesBox.containsKey(weather.cityKey)) {
            _lottieController.forward(from: 0);
            setState(() {
              favouritesBox.put(weather.cityKey, '');
            });

            // show toast to notify user
            Fluttertoast.showToast(
                msg: "${citiesBox.get(weather.cityKey).name} added to favourites",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                textColor: Colors.white,
                fontSize: 16.0
            );
          } else {
            _lottieController.reverse(from: 0.8);
            setState(() {
              favouritesBox.delete(weather.cityKey);
            });
          }
        },
      ),
    );
  }

  Widget _buildForecastInfo(ForecastModel forecast) {
    return OrientationLayoutBuilder(
      portrait: (context) => Padding(
        padding: const EdgeInsets.all(11.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (forecast.dailyForecasts != null) ...[
              Container(
                child: Expanded(
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9
                    ),
                    itemBuilder: (context, index) {
                      WeatherRange dailyForecast = forecast.dailyForecasts![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(StringUtils.dayName(index) ?? "", style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 4),
                            CachedNetworkImage(
                              imageUrl: StringUtils.getWeatherIconUrl(dailyForecast.day.iconNumber!),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                dailyForecast.temperatureRange.toStringWithUnit(_useCelsius! ? TemperatureUnit.celsius : TemperatureUnit.fahrenheit),
                                style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
      landscape: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (forecast.dailyForecasts != null) ...[
              Container(
                child: Expanded(
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 7,
                      childAspectRatio: 1.2
                    ),
                    itemBuilder: (context, index) {
                      WeatherRange dailyForecast = forecast.dailyForecasts![index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(StringUtils.dayName(index) ?? "", style: TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 4),
                            CachedNetworkImage(
                              imageUrl: StringUtils.getWeatherIconUrl(dailyForecast.day.iconNumber!),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                dailyForecast.temperatureRange.toStringWithUnit(_useCelsius! ? TemperatureUnit.celsius : TemperatureUnit.fahrenheit),
                                style: TextStyle(fontSize: 17)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _onRefresh() async{
    await Future.delayed(Duration(milliseconds: 900));
    if(_currentCity!=null) {
      _forecastBloc.add(FetchForecastEvent(_currentCity!.key, byKey: true));
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(Duration(milliseconds: 900));

    _refreshController.loadComplete();
  }

  _showCurrentLocationForecast() async {
    if(!await sl.get<NetworkInfo>().isConnected){
      _forecastBloc.add(NoInternetEvent());
      return;
    }
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var locationData = await location.getLocation();
    _forecastBloc.add(FetchForecastByGeolocationEvent(locationData.latitude, locationData.longitude));
  }

  Widget _buildData(Weather current, Forecast forecast) {
    // fetch current city details
    _currentCity = CityModel.fromCity(Hive.box('cities').get(current.cityKey));

    var forecastModel = ForecastModel.fromForecast(forecast);
    return Container(
      child: Column(
        children: [
          Expanded(
            child: _buildWeatherInfo(WeatherModel.fromWeather(current)),
          ),
          Text(forecastModel.conditions ?? ""),
          Expanded(
            child: _buildForecastInfo(forecastModel),
          ),
        ],
      ),
    );
  }

  Widget _buildError(failure) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(failure.message, textAlign: TextAlign.center),
    ));
  }
}
