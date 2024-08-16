import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCustomCache {
  SharedPreferences? prefs;
  Directory? appDir;
  final int cacheDuration; // in minutes
  final String cacheKey;
  final String dirPrefix;
  final String defaultPrefix = 'selfsync';
  String cachePath = 'cache.json'; // this is a cache
  MyCustomCache(
      {required this.cacheKey,
      required this.cacheDuration,
      required this.dirPrefix}){
        cachePath = '$cacheKey.json';
      }
  Future<void> initialize() async {
    // Initialize shared preferences and app directory
    prefs ??= await SharedPreferences.getInstance();
    if (!kIsWeb) {
      appDir ??= await getApplicationDocumentsDirectory();
    }
  }

  Future<String?> readCache() async {
    await initialize();
    if (!kIsWeb) {
      if (!File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath')
          .existsSync()) {
        return null;
      }
      return File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath')
          .readAsStringSync();
    } else {
      return prefs?.getString('$defaultPrefix/$dirPrefix/$cachePath');
    }
  }

  Future<void> writeCache(String data) async {
    await initialize();
    //create the directory if it doesn't exist
    if (!kIsWeb) {
      Directory('${appDir?.path}/$defaultPrefix/$dirPrefix').createSync(recursive: true);
    }
    if (!kIsWeb) {
      File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath')
          .writeAsStringSync(data);
    } else {
      prefs?.setString('$defaultPrefix/$dirPrefix/$cachePath', data);
    }
    prefs?.setInt(cacheKey, (DateTime.now().millisecondsSinceEpoch)+cacheDuration*60*1000); // cache duration in minutes
  }

  Future<bool> isCacheValid() async {
    await initialize();
    int? lastCacheTime = prefs?.getInt(cacheKey); //
    if (lastCacheTime == null || lastCacheTime == -1) {
      return false;
    }
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int cacheTimeDifference = currentTime - lastCacheTime;
    if (cacheTimeDifference > cacheDuration * 60 * 1000) {
      return false;
    }
    return true;
  }

  Future<void> invalidateCache() async {
    await initialize();
    prefs?.setInt(cacheKey, -1);

    //also delete the cache file if it exists
    if (!kIsWeb) {
      if (File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath')
          .existsSync()) {
        File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath').deleteSync();
      }
    }
  }

  // invalidate the cache if file does not exist
  Future<void> invalidateCacheIfFileDoesNotExist() async {
    await initialize();
    if (!kIsWeb) {
      if (!File('${appDir?.path}/$defaultPrefix/$dirPrefix/$cachePath')
          .existsSync()) {
        prefs?.setInt(cacheKey, -1);
      }
    }
  }
}
