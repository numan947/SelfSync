import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:selfsync_frontend/main.dart';

class HomeProvider{
  Future<String?> getHomeData() async {
    if (!internetConnected) {
      return null;
    }
        
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.get('/summary/',
          headers: <String, String>{
            'Authorization': idToken,
          });
      final response = await rstOp.response;
      if (response.statusCode == 200) {
        return jsonDecode(response.decodeBody())['summary'];
      }
      return null;
    } catch (e) {
      // this should only happen for network errors
      print('Error fetching summary: $e');
      return null;
    }
  }
}