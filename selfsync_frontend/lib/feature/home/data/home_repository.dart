import 'dart:convert';

import 'package:selfsync_frontend/common/my_custom_cache.dart';
import 'package:selfsync_frontend/feature/home/data/home_provider.dart';
import 'package:selfsync_frontend/feature/home/model/home_model.dart';

class HomeRepository {
  final MyCustomCache _cache = MyCustomCache(
    cacheKey: 'homeData',
    cacheDuration: 5*60*1000*3000, //basically never expires
    dirPrefix: 'homeData'
  );
  final HomeProvider _homeProvider;
  HomeRepository(this._homeProvider);
  Future<HomeModel> getHomeData() async {
    final homeData = await _homeProvider.getHomeData();
    if (homeData == null) {
      final cachedData = await _cache.readCache();
      if (cachedData != null) {
        return HomeModel.fromJson(jsonDecode(cachedData));
      }
      return HomeModel.empty();
    }else{
      await _cache.writeCache(homeData);
      return HomeModel.fromJson(jsonDecode(homeData));
    }
  }
}