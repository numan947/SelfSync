import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/spacenews/model/spacenews_model.dart';
import 'package:selfsync_frontend/feature/spacenews/repository/space_news_repository.dart';

part 'space_home_event.dart';
part 'space_home_state.dart';

class SpaceHomeBloc extends Bloc<SpaceHomeEvent, SpaceHomeState> {
  final SpaceNewsRepository repository;
  SpaceHomeBloc(this.repository) : super(SpaceHomeLoading()) {
    on<LoadArticlesEvent>(_onLoadArticles);
    on<LoadBlogsEvent>(_onLoadBlogs);
    on<LoadReportsEvent>(_onLoadReports);
  }

  Future<FutureOr<void>> _onLoadArticles(LoadArticlesEvent event, Emitter<SpaceHomeState> emit) async {
    emit(SpaceHomeLoading());
    List<SpaceNewsModel> articles = await repository.getArticles(event.newsItemCount);
    emit(SpaceHomeLoaded(articles, 0, event.newsItemCount));
  }

  Future<FutureOr<void>> _onLoadBlogs(LoadBlogsEvent event, Emitter<SpaceHomeState> emit) async {
    emit(SpaceHomeLoading());
    List<SpaceNewsModel> blogs = await repository.getBlogs(event.newsItemCount);
    emit(SpaceHomeLoaded(blogs, 1, event.newsItemCount));
  }

  Future<FutureOr<void>> _onLoadReports(LoadReportsEvent event, Emitter<SpaceHomeState> emit) async {
    emit(SpaceHomeLoading());
    List<SpaceNewsModel> reports = await repository.getReports(event.newsItemCount);
    emit(SpaceHomeLoaded(reports, 2, event.newsItemCount));
  }

}
