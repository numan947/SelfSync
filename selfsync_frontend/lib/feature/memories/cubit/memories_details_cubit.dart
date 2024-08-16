import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/service/storage_service.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';
import 'package:selfsync_frontend/main.dart';

import '../../../common/eventbus_events.dart';

part 'memories_details_state.dart';

class MemoriesDetailsCubit extends Cubit<MemoriesDetailsState> {
  static const String moduleName = 'memories';
  MemoriesModel memory;

  final StorageService storageService = StorageService();
  MemoriesDetailsCubit(this.memory) : super(MemoriesDetailsLoading());
  void showMemoryDetails() {
    // filter out the local images
    final List<String> keysToDownload = memory.imageKeysToUrlMap.keys.toList().where((element) => memory.imageKeysToUrlMap[element]!=null && !isLocalPath(memory.imageKeysToUrlMap[element]!)).toList();
    // print(keysToDownload);
    storageService.createMultipleDownloadLinks(keysToDownload, "$moduleName/${memory.id}").then((value) {
      memory.imageKeysToUrlMap.addAll(value);
      eventBus.fire(MemoriesImagesLoadedEvent());
    });
    emit(MemoriesDetailsLoaded(memory));
  }

  void updatedMemoryDetails(MemoriesModel updatedMemory) {
    emit(MemoriesDetailsLoading());
    memory = updatedMemory; // update the memory
    emit(MemoriesDetailsLoaded(updatedMemory));
  }

  void reloadMemoryDetails() {
    emit(MemoriesDetailsLoading());
    emit(MemoriesDetailsLoaded(memory));
  }

  void tryReloadingImages() {
    // check which images are not loaded and reload them
    final List<String> keysToReload = memory.imageKeysToUrlMap.keys.toList().where((element) => memory.imageKeysToUrlMap[element]!=null && !isLocalPath(memory.imageKeysToUrlMap[element]!)).toList(); // this is okay as if the images' urls are not null, they're already cached
      
    if (keysToReload.isNotEmpty) {
      storageService.createMultipleDownloadLinks(keysToReload, "$moduleName/${memory.id}").then((value) {
        memory.imageKeysToUrlMap.addAll(value);
        eventBus.fire(MemoriesImagesLoadedEvent());
      });
    }
    // no need to emit the state as the images are already loaded
  }
}
