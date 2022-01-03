import 'package:WeatherApp/core/network/network_info.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late NetworkInfoImpl networkInfo;
  MockConnectivity? mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    networkInfo = NetworkInfoImpl(mockConnectivity);
  });

  group('isConnected', () {
    test(
      'should forward the call to DataConnectionChecker.hasConnection',
          () async {
        // arrange
        final tHasConnectionFuture = true;

        when((await mockConnectivity!.checkConnectivity()) != ConnectivityResult.none)
            .thenAnswer((_) => tHasConnectionFuture);
        // act
        final result = networkInfo.isConnected;
        // assert
        verify((await mockConnectivity!.checkConnectivity()) != ConnectivityResult.none);
        expect(result, tHasConnectionFuture);
      },
    );
  });
}