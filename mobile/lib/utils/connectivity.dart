import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  static Stream<bool> get onlineStream =>
      Connectivity().onConnectivityChanged.map((r) => r != ConnectivityResult.none);
}
