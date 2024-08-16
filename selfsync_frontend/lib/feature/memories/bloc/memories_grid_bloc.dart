import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/memories/data/memories_repository.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';

import '../../../common/eventbus_events.dart';
import '../../../main.dart';

part 'memories_grid_event.dart';
part 'memories_grid_state.dart';

class MemoriesGridBloc extends Bloc<MemoriesGridEvent, MemoriesGridState> {
  late final MemoriesRepository _memoriesRepository;
  List<MemoriesModel> memories = [];

  MemoriesGridBloc(this._memoriesRepository) : super(MemoriesGridLoading()) {
    on<ShowMemoriesGrid>(_onShowMemoriesGrid);
    on<CreateNewMemory>(_onCreateNewMemory);
    on<MemoriesUpdated>(_onMemoriesUpdated);
    on<MemoriesDeleted>(_onMemoriesDeleted);
    on<UpdateMemory>(_onUpdateMemory);
    on<SyncRefreshMemories>(_syncRefreshMemories);
    on<SyncMemoriesInternet>(_syncMemoriesInternet);
    on<SearchMemories>(_onSearchMemories);
  }

  Future<FutureOr<void>> _onShowMemoriesGrid(
      ShowMemoriesGrid event, Emitter<MemoriesGridState> emit) async {
    emit(MemoriesGridLoading());
    memories = await _memoriesRepository.fetchMemories();
    emit(MemoriesGridLoaded(memories));
  }

  Future<FutureOr<void>> _onCreateNewMemory(
      CreateNewMemory event, Emitter<MemoriesGridState> emit) async {
    emit(MemoriesGridLoading());
    await _memoriesRepository.addMemories(event.memory);
    memories = _memoriesRepository.getMemories;
    emit(MemoriesGridLoaded(memories));
  }

  FutureOr<void> _onMemoriesUpdated(
      MemoriesUpdated event, Emitter<MemoriesGridState> emit) {
    // this means that the memories have been updated in the repository, we can just use the getter to get the updated memories
    emit(MemoriesGridLoading());
    memories = _memoriesRepository.getMemories;
    emit(MemoriesGridLoaded(memories));
  }

  Future<FutureOr<void>> _onMemoriesDeleted(
      MemoriesDeleted event, Emitter<MemoriesGridState> emit) async {
    emit(MemoriesGridLoading());
    await _memoriesRepository.deleteMemories(event.memory);
    memories = _memoriesRepository.getMemories;
    emit(MemoriesGridLoaded(memories));
  }

  Future<FutureOr<void>> _onUpdateMemory(
      UpdateMemory event, Emitter<MemoriesGridState> emit) async {
    emit(MemoriesGridLoading());
    await _memoriesRepository.deleteImages(event.deletedImagesKeys);
    await _memoriesRepository.updateMemory(event.memory);
    memories = _memoriesRepository.getMemories;
    emit(MemoriesGridLoaded(memories));
  }

  FutureOr<void> _syncRefreshMemories(
      SyncRefreshMemories event, Emitter<MemoriesGridState> emit) async {
    emit(MemoriesGridLoading());
    memories = await _memoriesRepository.fetchMemories();
    emit(MemoriesGridLoaded(memories));
  }

  FutureOr<void> _syncMemoriesInternet(
      SyncMemoriesInternet event, Emitter<MemoriesGridState> emit) {
    _memoriesRepository.syncMemories().then((value) => {
          if (value)
            {
              print('Internet Available! Memories Updated!!'),
              eventBus.fire(MemoriesUpdatedEvent())
            }
        });
  }

  FutureOr<void> _onSearchMemories(SearchMemories event, Emitter<MemoriesGridState> emit) {
    List<MemoriesModel> lst  = _memoriesRepository.getMemories;
    List<MemoriesModel> searchResults = lst.where((element) => element.title.toLowerCase().contains(event.query.toLowerCase())).toList();
    emit(MemoriesGridLoaded(searchResults));
  }
}
