import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:selfsync_frontend/feature/spacenews/ui/space_news_grid_view_item.dart';

import '../model/spacenews_model.dart';

class SpaceNewsGridView extends StatelessWidget {
  final List<SpaceNewsModel> allNews;
  final Function(SpaceNewsModel) onNewsSelected;
  const SpaceNewsGridView({super.key, required this.allNews, required this.onNewsSelected});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridList(
      desiredItemWidth: 250, 
      minSpacing: 12,
      rowMainAxisAlignment: MainAxisAlignment.center,
      physics: const BouncingScrollPhysics(),
      children: allNews.map((news) {
      return SpaceNewsGridViewItem(news: news, onTap: onNewsSelected);
    }).toList());
  }
}