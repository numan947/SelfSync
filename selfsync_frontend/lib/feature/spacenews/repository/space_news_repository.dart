import 'dart:convert';

import 'package:selfsync_frontend/feature/spacenews/repository/space_news_provider.dart';

import '../model/spacenews_model.dart';

class SpaceNewsRepository {
  final SpaceNewsProvider _spaceNewsProvider;
  SpaceNewsRepository(this._spaceNewsProvider);

  Future<List<SpaceNewsModel>> getArticles(int newsItemCount) async {
    List<SpaceNewsModel> articles = [];
    String? rsp = await _spaceNewsProvider.loadArticles(newsItemCount);
    if (rsp != null) {
      Map<String, dynamic> decoded = jsonDecode(rsp);
      for (var article in decoded['results']) {
        articles.add(SpaceNewsModel.fromJson(article));
      }
    }
    return articles;
  }

  Future<List<SpaceNewsModel>> getBlogs(int newsItemCount)async {
    List<SpaceNewsModel> blogs = [];
    String? rsp = await _spaceNewsProvider.loadBlogs(newsItemCount);
    if (rsp != null) {
      Map<String, dynamic> decoded = jsonDecode(rsp);
      for (var blog in decoded['results']) {
        blogs.add(SpaceNewsModel.fromJson(blog));
      }
    }
    return blogs;
  }

 Future<List<SpaceNewsModel>> getReports(int newsItemCount) async {
    List<SpaceNewsModel> reports = [];
    String? rsp = await _spaceNewsProvider.loadReports(newsItemCount);
    if (rsp != null) {
      Map<String, dynamic> decoded = jsonDecode(rsp);
      for (var report in decoded['results']) {
        reports.add(SpaceNewsModel.fromJson(report));
      }
    }
    return reports;
 }


}
