

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/home/data/home_repository.dart';
import 'package:selfsync_frontend/feature/home/model/home_model.dart';

part 'home_view_event.dart';
part 'home_view_state.dart';

class HomeViewBloc extends Bloc<HomeViewEvent, HomeViewState> {
  final HomeRepository _homeRepository;
  HomeViewBloc(this._homeRepository) : super(HomeViewDataLoading()) {
    on<LoadHomeViewData>(_onLoadHomeViewData);
  }

  Future<FutureOr<void>> _onLoadHomeViewData(LoadHomeViewData event, Emitter<HomeViewState> emit) async {
    emit(HomeViewDataLoading());
    HomeModel homedata = await _homeRepository.getHomeData();
    emit(HomeViewDataLoaded(homedata));
  }
}
