import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:selfsync_frontend/common/service/storage_service.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';

import '../../../common/common_functions.dart';
import '../../../main.dart';

class MemoriesProvider {
  late final StorageService storageService;

  MemoriesProvider({required this.storageService});
  
  Future<String?> getMemories() async {
    if (!internetConnected) {
      return null;
    }
    
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.get('/memories/',
          headers: <String, String>{
            'Authorization': idToken,
          });
      final response = await rstOp.response;
      if (response.statusCode == 200) {
        return jsonDecode(response.decodeBody())['memories'];
      }
      return null;
    } catch (e) {
      // this should only happen for network errors
      print('Error fetching memories: $e');
      return null;
    }
  }

  Future<bool> syncMemories(MemoriesModel memory) async {
    // only sync the memory, the images should be synced separately, 
    //must be called after the images are uploaded
    if (!internetConnected) {
      return false;
    }
    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.post('/memories/createOrUpdate',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(jsonEncode(memory.toJson())));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      print('Error syncing memories: $e');
      return false;
    }
  }

  // delete a memory
  Future<bool> deleteMemories(String id) async {
    if (!internetConnected) {
      return false;
    }
    // this function doesn't deal with S3 images, only the table entry,
    // this has to be called after adding the images to the deleted images cache

    try {
      final sess = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      String idToken =
          sess.userPoolTokensResult.value.toJson()['idToken'] as String;
      final rstOp = Amplify.API.delete('/memories/delete',
          headers: <String, String>{
            'Authorization': idToken,
          },
          body: HttpPayload(
            jsonEncode({
              'id': id
            })
          ));
      final response = await rstOp.response;
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting memories: $e');
      return false;
    }
  }

  Future<String?> uploadImage(String key, String filePath) async {
    if (!internetConnected) {
      return null;
    }
    if (!isLocalPath(filePath)) {
      return filePath;
    }
    String? updatedKey = await storageService.uploadFile(key, filePath);
    return updatedKey;
  }


  Future<bool>deleteImage(String key)async{
    if (!internetConnected) {
      return false;
    }
    return await storageService.deleteFile(key);
  }
}
