import 'package:connectivity/connectivity.dart';

abstract class NetworkInfo{
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectionChecker;
  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    return (await connectionChecker.checkConnectivity()) != ConnectivityResult.none;
  }
}