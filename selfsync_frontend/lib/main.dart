import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:selfsync_frontend/amplifyconfiguration.dart';
import 'package:selfsync_frontend/app.dart';

//global EvenBus
final EventBus eventBus = EventBus();
bool internetConnected = false;

Future<void> _configureAmplify() async {
  try {
    // need to install libsqlite3-dev on the system for storage to work, also remember to install the specific library for linux
    final auth = AmplifyAuthCognito();
    final storage = AmplifyStorageS3();
    final api = AmplifyAPI();
    await Amplify.addPlugins([auth, storage, api]);
    await Amplify.configure(amplifyconfig);
    safePrint('Amplify configured!!');
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
    rethrow;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // await backgroundSync.initialize(backgroundSyncInterval);
    await _configureAmplify();
    await _setConnectivity(); // check if internet is connected initially
    runApp(const SelfSyncApp());
  } on Exception catch (e) {
    safePrint('An error occurred starting the app: $e');
  }
}

_setConnectivity() async {
  final ConnectivityResult conn = await Connectivity().checkConnectivity();
  if (conn == ConnectivityResult.mobile ||
      conn == ConnectivityResult.wifi ||
      conn == ConnectivityResult.ethernet) {
    internetConnected = true;
  } else {
    internetConnected = false;
  }
}
