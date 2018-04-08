library secrects;

import 'dart:async';
import 'dart:io';

Future<Map> main() async {
  var apiKey =
      const String.fromEnvironment('firebase_api_key', defaultValue: 'x');
  var host = const String.fromEnvironment('firebase_host',
      defaultValue: 'mem://database');
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected use firebase database');
      apiKey = Platform.environment['FIREBASE_API_KEY'];
      host = Platform.environment['FIREBASE_HOST'];
    }
  } on SocketException catch (_) {
    print('not connected use memory database');
  }

  var secrets = {'host': host, 'secret': apiKey};
  return secrets;
}
