import 'package:WeatherApp/app/data/models/city_model.dart';
import 'package:WeatherApp/app/data/models/temperature_model.dart';
import 'package:WeatherApp/app/data/models/weather_model.dart';
import 'package:WeatherApp/app/domain/entities/weather.dart';
import 'package:WeatherApp/app/presentation/screens/favourite_locations_screen.dart';
import 'package:WeatherApp/app/presentation/screens/home_screen.dart';
import 'package:WeatherApp/app/presentation/state/weather_bloc/weather_bloc.dart';
import 'package:WeatherApp/core/utils/string_utils.dart';
import 'package:WeatherApp/core/enums/temperature_unit.dart';
import 'package:WeatherApp/core/injector_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class WeatherItem extends StatefulWidget{
  final CityModel? city;
  final bool? useCelsius;

  WeatherItem({Key? key, this.city, this.useCelsius}) : super(key: key);

  @override
  _WeatherItemState createState() => _WeatherItemState();
}

class _WeatherItemState extends State<WeatherItem> {
  final _weatherBloc = sl.get<WeatherBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _weatherBloc.add(FetchWeatherEvent(widget.city!.key, byKey: true));
    Provider.of<Updater>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: BlocListener(
        bloc: _weatherBloc,
        listener: (context, WeatherState state) {
          state.join(
                (_) => null,
                (_) => null,
                (success) {

                  if(success.isCached!){
                    Fluttertoast.showToast(
                        msg: "No internet, using last data",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                },
                (failure) {
                  Fluttertoast.showToast(
                      msg: "Can't load weather: ${failure.message}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0
                  );
                },
          );
        },
        child: BlocBuilder(
          bloc: _weatherBloc,
          // ignore: missing_return
          builder: (context, WeatherState state) {
            return state.join(
                  (initial) => _buildErrorItem(),
                  (loading) => _buildLoadingItem(),
                  (success) => _buildItem(success.weather!),
                  (failure) => _buildErrorItem(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(Weather weather) {
    var weatherModel = WeatherModel.fromWeather(weather);
    return InkWell(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(
              builder: (_) => HomeScreen(city: widget.city))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 20,
                child: Text(widget.city!.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold),)),
            const SizedBox(height: 5),
            Expanded(
              child: Image.network(StringUtils.getWeatherIconUrl(
                  weatherModel.iconNumber!)),
            ),
            Text(
              (weatherModel.temperature as TemperatureModel)
                  .toStringWithUnit(widget.useCelsius!
                  ? TemperatureUnit.celsius
                  : TemperatureUnit.fahrenheit),
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorItem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 20,
              child: Text(widget.city!.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold),)),
          const SizedBox(height: 5),
          Expanded(
            child: Icon(Icons.wb_sunny_outlined, size: 42,),
          ),
          Text("-- ${widget.useCelsius! ? '℃': '℉'}",
            style: TextStyle(fontSize: 17),
          ),
        ],
      ),
    );
  }

  _buildLoadingItem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 20,
              child: Text(widget.city!.name,
                style: TextStyle(
                    fontWeight: FontWeight.bold),)),
          const SizedBox(height: 5),
          Expanded(
            child: Center(child: CircularProgressIndicator()),
          ),
          Text(""),
        ],
      ),
    );
  }
}