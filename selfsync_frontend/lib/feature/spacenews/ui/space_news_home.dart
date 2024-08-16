import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/constants.dart';
import 'package:selfsync_frontend/feature/spacenews/ui/space_news_grid_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/space_home_bloc.dart';
import '../model/spacenews_model.dart';

class SpaceNewsHome extends StatefulWidget {
  const SpaceNewsHome({super.key});

  @override
  State<SpaceNewsHome> createState() => _SpaceNewsHomeState();
}

class _SpaceNewsHomeState extends State<SpaceNewsHome> {
  int newsItemCount = 20;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    context.read<SpaceHomeBloc>().add(LoadArticlesEvent(newsItemCount));
  }

  Future<void> _onNewsSelected(SpaceNewsModel news) async {
    await launchUrl(Uri.parse(news.url));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpaceHomeBloc, SpaceHomeState>(
      builder: (context, state) {
        selectedIndex = state is SpaceHomeLoaded ? state.selectedIndex : selectedIndex;
        newsItemCount = state is SpaceHomeLoaded ? state.newsItemCount : newsItemCount;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Space News',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
            centerTitle: true,
            actions: [
              DropdownButton(
                value: newsItemCount,
                selectedItemBuilder: (context) {
                  return const [
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('20',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('100',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('150',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('300',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                    Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('500',
                          style: TextStyle(color: AppColors.contentColorBlue)),
                    )),
                  ];
                },
                dropdownColor: AppColors.pageBackground,
                items: const [
                  DropdownMenuItem(
                      value: 20,
                      child: Text('20',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                  DropdownMenuItem(
                      value: 50,
                      child: Text('50',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                  DropdownMenuItem(
                      value: 100,
                      child: Text('100',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                  DropdownMenuItem(
                      value: 150,
                      child: Text('150',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                  DropdownMenuItem(
                      value: 300,
                      child: Text('300',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                  DropdownMenuItem(
                      value: 500,
                      child: Text('500',
                          style: TextStyle(color: AppColors.contentColorBlue))),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  newsItemCount = value;
                  if (selectedIndex == 0) {
                    context.read<SpaceHomeBloc>().add(LoadArticlesEvent(value));
                  } else if (selectedIndex == 1) {
                    context.read<SpaceHomeBloc>().add(LoadBlogsEvent(value));
                  } else {
                    context.read<SpaceHomeBloc>().add(LoadReportsEvent(value));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh,
                    color: AppColors.contentColorBlue),
                onPressed: () {
                  if (selectedIndex == 0) {
                    context
                        .read<SpaceHomeBloc>()
                        .add(LoadArticlesEvent(newsItemCount));
                  } else if (selectedIndex == 1) {
                    context
                        .read<SpaceHomeBloc>()
                        .add(LoadBlogsEvent(newsItemCount));
                  } else {
                    context
                        .read<SpaceHomeBloc>()
                        .add(LoadReportsEvent(newsItemCount));
                  }
                },
              )
            ],
          ),
          body: state is SpaceHomeLoading
              ? Center(child: LoadingAnimationWidget.bouncingBall(color: Colors.amber, size: 70))
              : state is SpaceHomeLoaded
                  ? SpaceNewsGridView(
                      allNews: state.results, onNewsSelected: _onNewsSelected)
                  : const Center(child: Text('Error')),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              selectedIndex = index;
              if (index == 0) {
                context
                    .read<SpaceHomeBloc>()
                    .add(LoadArticlesEvent(newsItemCount));
              } else if (index == 1) {
                context
                    .read<SpaceHomeBloc>()
                    .add(LoadBlogsEvent(newsItemCount));
              } else {
                context
                    .read<SpaceHomeBloc>()
                    .add(LoadReportsEvent(newsItemCount));
              }
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'Articles',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'Blogs',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.query_stats_outlined),
                label: 'Reports',
              ),
            ],
          ),
        );
      },
    );
  }
}
