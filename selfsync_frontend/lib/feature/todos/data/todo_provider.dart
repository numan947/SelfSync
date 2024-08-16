import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:selfsync_frontend/feature/todos/model/todo_model.dart';
import 'package:selfsync_frontend/main.dart';

class TodosProvider {
  Future<String?> getTodos() async {
    if (!internetConnected) {
      return null;
    }
    
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.get('/todos/',
          headers: <String, String>{
            'Authorization': idToken,
          });
      final response = await rstOp.response;
      if (response.statusCode == 200) {
        return jsonDecode(response.decodeBody())['todos'];
      }
      return null;
    } catch (e) {
      // this should only happen for network errors
      print('Error fetching todos: $e');
      return null;
    }
  }

  // add or update a todo
  Future<bool> syncTodos(Todo todo) async {
    if (!internetConnected) {
      return false;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.post('/todos/createOrUpdate',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(
            jsonEncode(todo.toJson())
          ));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // delete a todo
  Future<bool> deleteTodos(Todo todo) async {
    if (!internetConnected) {
      return false;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.delete('/todos/delete',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(
            jsonEncode(todo.toJson())
          ));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting todo: $e');
      return false;
    }
  }
}
