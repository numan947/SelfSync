import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfsync_frontend/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;


class StorageService {
  static const placeholderImageUrl = 'https://place-hold.it/200X200';
  StorageService();

  Future<String?> getImageUrl(String key) async {
    // try to cache the image url for 7 days
    const cacheDuration = 3;
    final String cacheKey = 'image_$key';
    final String cacheKeyDate = 'date_image_$key';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(cacheKey) && prefs.containsKey(cacheKeyDate) && DateTime.now().difference(DateTime.parse(prefs.getString(cacheKeyDate)!)).inDays < cacheDuration){
      return prefs.getString(cacheKey);
    }
    
    //check if internet is available
    if (!internetConnected) {
      return placeholderImageUrl; //return empty string if there is no internet
    }
    //check if the file exists
    if (!await exists(key)) {
      print('File does not exist');
      return ''; //return empty string if the file does not exist
    }
    try {
      final result = await Amplify.Storage.getUrl(
          key: key,
          options: const StorageGetUrlOptions(
              accessLevel: StorageAccessLevel.private,
              pluginOptions: S3GetUrlPluginOptions(
                validateObjectExistence: true,
                expiresIn: Duration(days: cacheDuration),
              ))).result;
      prefs.setString(cacheKey, result.url.toString());
      prefs.setString(cacheKeyDate, DateTime.now().toString());
      return result.url.toString();
    } on Exception catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<String?> uploadFile(String key, String filePath) async {
    //check if internet is available
    if (!internetConnected) {
      return null;
    }
    // do not upload if the file already exists
    if (await exists(key)) {
      return key;
    }
    try {
      final awsFile = AWSFile.fromPath(filePath);
      await Amplify.Storage.uploadFile(
          localFile: awsFile,
          key: key,
          options: const StorageUploadFileOptions(
            accessLevel: StorageAccessLevel.private,
          )).result;
      return key;
    } on Exception catch (e) {
      return null;
    }
  }

  Future<bool> deleteFile(String key) async {
    //check if internet is available
    if (!internetConnected) {
      return false;
    }
    // do not delete if the file does not exist
    try {
      if (!await exists(key)) {
        print('File does not exist');
        print(key);
        return true;
      }
      try {
        await Amplify.Storage.remove(
            key: key,
            options: const StorageRemoveOptions(
              accessLevel: StorageAccessLevel.private,
            )).result;
        return true;
      } on Exception catch (e) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> exists(String key) async {
    try {
      final result = await Amplify.Storage.list(
          options: const StorageListOptions(
        accessLevel: StorageAccessLevel.private,
      )).result;
      return result.items.any((element) => element.key == key);
    } on Exception catch (e) {
      return false;
    }
  }

  static Future<String?> downloadFile(String imageKey, String folder) async {
    // unique download name
    final String saveAs = DateTime.now().millisecondsSinceEpoch.toString(); // unique download name
    final String fileExtension = imageKey.split('.').last;
    if (!kIsWeb) {
      final dlDir = await getDownloadsDirectory();
      final directory = Directory('${dlDir?.path}/selfsync_images/$folder');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final filepath = '${directory.path}/$saveAs.$fileExtension';
      try {
        final result = await Amplify.Storage.downloadFile(
          key: imageKey,
          localFile: AWSFile.fromPath(filepath),
          options: const StorageDownloadFileOptions(
            accessLevel: StorageAccessLevel.private,
          ),
          onProgress: (progress) {
            // safePrint('Fraction completed: ${progress.fractionCompleted}');
          },
        ).result;

        return result.localFile.path;
      } on StorageException catch (e) {
        safePrint(e.message);
        return null;
      }
    }
    else{
      // web implementation
      try{
        final localFile = '$saveAs.$fileExtension';
        final downloadUrl = await Amplify.Storage.getUrl(
          key: imageKey,
          options: const StorageGetUrlOptions(
            accessLevel: StorageAccessLevel.private,
            pluginOptions: S3GetUrlPluginOptions(
              validateObjectExistence: true,
              expiresIn: Duration(days: 1),
            ),
          ),
        ).result;

        final response = await http.get(downloadUrl.url);

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', localFile)
            ..click();
          html.Url.revokeObjectUrl(url);
        }
        return localFile;
      }
      on StorageException catch (e) {
        safePrint(e.message);
        return null;
      }
    }
  }

  Future<Map<String, String>> createMultipleDownloadLinks(List<String> imageKeys, String prefix) async {
    print('Creating download links');
    final Map<String, String> downloadLinks = {};
    for (final imageKey in imageKeys) {
      final actualKey = '$prefix/$imageKey';
      final downloadLink = await getImageUrl(actualKey);
      if (downloadLink != null) {
        downloadLinks[imageKey] = downloadLink;
      }
    }
    return downloadLinks;
  }
}
