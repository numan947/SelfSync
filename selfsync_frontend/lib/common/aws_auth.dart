  import 'dart:io';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> signOutCurrentUser() async {
    // clear the entire shared preferences and local storage cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!kIsWeb){
      // delete the application directory
      final appDir = await getApplicationDocumentsDirectory();
      Directory('${appDir.path}/selfsync').deleteSync(recursive: true);
    }


    // invalidate the current session by deleting the local session
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      safePrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      safePrint('Error signing user out: ${result.exception.message}');
    }
  }
