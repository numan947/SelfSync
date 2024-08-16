import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';
import 'package:http/http.dart' as http;

class SpaceNewsProvider {
  static const spaceAPIBaseURL = 'https://api.spaceflightnewsapi.net/v4';
  static const articlesPath = '/articles';
  static const blogsPath = '/blogs';
  static const reportsPath = '/reports';
  SharedPreferences? prefs;
  Future<void> initialize() async {
    prefs ??= await SharedPreferences.getInstance();
  }

  Future<String?> loadFromInternet(String fetchUrl) async {
    await initialize();
    if (prefs?.containsKey(fetchUrl) == true) {
      int? lastCacheTime = prefs?.getInt(fetchUrl);
      if (lastCacheTime != null &&
          lastCacheTime > DateTime.now().millisecondsSinceEpoch) {
            String? res = prefs?.getString("BODY$fetchUrl");
            if(res != null){
              return res;
            }
      }
    }
    // if the fetchUrl is not in the cache or the cache is invalid, fetch the data
    http.Response r = await http.get(Uri.parse(fetchUrl));
    if (r.statusCode == HttpStatus.ok) {
      prefs?.setString("BODY$fetchUrl", r.body);
      prefs?.setInt(
          fetchUrl,
          (DateTime.now().millisecondsSinceEpoch) + (86400000~/2)); // cache duration for 24 hours
      return r.body;
    } else {
      return null;
    }
  }

  Future<String?> loadArticles(int newsItemCount) async {
    String fetchUrl = '$spaceAPIBaseURL$articlesPath?limit=$newsItemCount';
    return await loadFromInternet(fetchUrl);
  }

  Future<String?> loadBlogs(int newsItemCount) async {
    String fetchUrl = '$spaceAPIBaseURL$blogsPath?limit=$newsItemCount';
    return await loadFromInternet(fetchUrl);
  }

  Future<String?> loadReports(int newsItemCount) async {
    String fetchUrl = '$spaceAPIBaseURL$reportsPath?limit=$newsItemCount';
    return await loadFromInternet(fetchUrl);
  }
}
