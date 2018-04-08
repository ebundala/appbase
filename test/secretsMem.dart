import 'dart:io';

var apiKey = const String.fromEnvironment('firebase_api_key') ??
    Platform.environment['FIREBASE_API_KEY'];
var host = const String.fromEnvironment('firebase_host') ??
    Platform.environment['FIREBASE_HOST'];
Map get secrets => const {"host": "mem://database", "secret": "x"};
