import 'dart:io'; //InternetAddress utility
import 'dart:async'; //For StreamController/Stream

class ConnectionCheck {
  //This creates the single instance by calling the `_internal` constructor specified below
  static final ConnectionCheck _singleton = new ConnectionCheck._internal();
  ConnectionCheck._internal();

  //This is what's used to retrieve the instance through the app
  static ConnectionCheck getInstance() => _singleton;

  //The test to actually see if there is a connection
  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch(_) {
      return false;
    }
  }
}
