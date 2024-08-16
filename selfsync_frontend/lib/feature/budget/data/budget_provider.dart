import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:selfsync_frontend/feature/budget/model/budget_model.dart';
import 'package:selfsync_frontend/main.dart';

class BudgetProvider {
  // add or update a todo
  Future<bool> syncBudget(BudgetModel budgetModel) async {
    if (!internetConnected) {
      return false;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.post('/budget/createOrUpdate',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(jsonEncode(budgetModel.toJson())));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      print('Error syncing budget from provider: $e');
      return false;
    }
  }

  Future<String?> getBudgets({required int year, required int month}) async {
    if (!internetConnected) {
      return null;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.get('/budget/', headers: <String, String>{
        'Authorization': idToken,
      }, queryParameters: <String, String>{
        'year': year.toString(),
        'month': month.toString()
      });
      final response = await rstOp.response;
      // print('Response: ${response.decodeBody()}');
      if (response.statusCode == 200) {
        return jsonDecode(response.decodeBody())['budget'];
      }
      return null;
    } catch (e) {
      // this should only happen for network errors
      print('Error fetching budgets: $e');
      return null;
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    if (!internetConnected) {
      return false;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.delete('/budget/delete/',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(jsonEncode({'id': budgetId})));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting budget from provider: $e');
      return false;
    }
  }
}
