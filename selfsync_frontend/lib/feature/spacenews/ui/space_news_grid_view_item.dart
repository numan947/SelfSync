import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/constants.dart';
import 'package:selfsync_frontend/feature/spacenews/model/spacenews_model.dart';

class SpaceNewsGridViewItem extends StatelessWidget {
  final SpaceNewsModel news;
  final Function(SpaceNewsModel m) onTap;
  const SpaceNewsGridViewItem(
      {super.key,
      required this.news,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shadowColor: Colors.purple,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          onTap(news);
        },
        child: Padding(
          padding: const EdgeInsets.all(13.0),
          child: Column(
            children: [
              Text(
                utf8.decode(
                  news.title.runes.toList(),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "Source: ${utf8.decode(news.news_site.runes.toList())}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.contentColorOrange),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Colors.purple,
                thickness: 2,
              ),
              CachedNetworkImage(
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),  
                imageUrl: news.image_url,
                placeholder: (context, url) =>
                    LoadingAnimationWidget.beat(color: Colors.red, size: 20),
                fadeInCurve: Curves.easeIn,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const Divider(
                color: Colors.purple,
                thickness: 2,
              ),
              Text(
                utf8.decode(
                  news.summary.runes.toList(),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const Divider(
                color: Colors.purple,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Date: ${DateFormat.yMMMd().format(DateTime.parse(news.published_at))}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
