class SpaceNewsModel{
  final int id;
  final String title;
  final String url;
  final String image_url;
  final String news_site;
  final String summary;
  final String published_at;
  final String updated_at;
  bool isFavorite = false;

  SpaceNewsModel({
    required this.id,
    required this.title,
    required this.url,
    required this.image_url,
    required this.news_site,
    required this.summary,
    required this.published_at,
    required this.updated_at,
  });

  factory SpaceNewsModel.fromJson(Map<String, dynamic> json) {
    return SpaceNewsModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      image_url: json['image_url'],
      news_site: json['news_site'],
      summary: json['summary'],
      published_at: json['published_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': image_url,
      'news_site': news_site,
      'summary': summary,
      'published_at': published_at,
      'updated_at': updated_at,
    };
  }

  // setter and getter for isFavorite
  bool get getIsFavorite => isFavorite;
  set setIsFavorite(bool value) => isFavorite = value;

  @override
  String toString() {
    return 'SpaceNewsModel{id: $id, title: $title, url: $url, image_url: $image_url, news_site: $news_site, summary: $summary, published_at: $published_at, updated_at: $updated_at}';
  }
}