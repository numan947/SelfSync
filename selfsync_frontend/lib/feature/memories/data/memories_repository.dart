import 'dart:convert';

import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/my_custom_cache.dart';
import 'package:selfsync_frontend/feature/memories/data/memories_provider.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';

import '../../../main.dart';

class MemoriesRepository {
  static const String moduleName = 'memories';
  final MyCustomCache memoryCache = MyCustomCache(
    cacheKey: 'all_memories',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years -- basically never expires
    dirPrefix: 'memories',
  );

  final MyCustomCache deletedMemoriesCache = MyCustomCache(
    cacheKey: 'deleted_memories',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years -- basically never expires
    dirPrefix: 'memories',
  );
  final MyCustomCache deletedImagesCache = MyCustomCache(
    cacheKey: 'deleted_images',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years -- basically never expires
    dirPrefix: 'memories',
  ); // contains the keys of the images that have been deleted

  // only keep the memories in the repository, deleted memories will be stored in the cache and read from the cache before syncing
  List<MemoriesModel> memories = [];

  late final MemoriesProvider memoriesProvider;
  MemoriesRepository(this.memoriesProvider);

  //getter for the memories
  List<MemoriesModel> get getMemories =>
      memories; // get memories from the repository

  Future<List<MemoriesModel>> fetchMemories() async {
    await syncDeletedMemories();
    await syncMemories();
    String? networkResponse = await memoriesProvider.getMemories();
    List<MemoriesModel> serverMemories = [];
    if (networkResponse != null) {
      serverMemories = (jsonDecode(networkResponse) as List)
          .map((e) => MemoriesModel.fromJson(e))
          .toList();
      // Save memories to the cache
      await memoryCache.writeCache(jsonEncode(serverMemories));
      memories = serverMemories;
    }
    return memories;
  }

  Future<bool> syncMemories() async {
    print('Syncing memories');
    //clear the cache if file does not exist
    await memoryCache.invalidateCacheIfFileDoesNotExist();
    await deletedMemoriesCache.invalidateCacheIfFileDoesNotExist();
    await deletedImagesCache.invalidateCacheIfFileDoesNotExist();
    bool changed = false;

    List<MemoriesModel> localMemories = [];
    // Fetch memories from the cache
    bool cacheValid = await memoryCache.isCacheValid();
    if (cacheValid) {
      String? cachedMemories = await memoryCache.readCache();
      if (cachedMemories != null && cachedMemories.isNotEmpty) {
        try {
          jsonDecode(cachedMemories).forEach((memory) {
            localMemories.add(MemoriesModel.fromJson(memory));
          });
        } catch (e) {
          // invalidate the cache
          await memoryCache.invalidateCache();
        }
      }
    }
    // Check if there are any memories in the cache that needs to be synced, on success update the isLocal flag to false
    if (localMemories.isNotEmpty) {
      List<MemoriesModel> tmpMemories = List.from(localMemories);
      for (var memory in tmpMemories) {
        if (memory.isLocal) {
          bool hasLocalImages = false;
          // first try to sync the images
          for (var imageKey in memory.imageKeysToUrlMap.keys) {
            if (isLocalPath(memory.imageKeysToUrlMap[imageKey] ?? '')) {
              final actualKey = "$moduleName/${memory.id}/$imageKey";
              // the image has not been uploaded yet
              String? imageUrl = await memoriesProvider.uploadImage(
                  actualKey,
                  memory.imageKeysToUrlMap[imageKey] ??
                      ''); // this will not be called for '', as it means the image has been uploaded
              if (imageUrl != null) {
                memory.imageKeysToUrlMap[imageKey] = ''; // '' means the image has been uploaded
              }else{
                hasLocalImages = true;
              }
            }
          }
          if (hasLocalImages) {
            //skip the memory if there are local images
            continue;
          }
          bool success = await memoriesProvider.syncMemories(memory);
          if (success) {
            memory.isLocal = false;
            changed = true;
          }
        }
      }
      localMemories = tmpMemories;
    }

    memories = localMemories;

    //sync deleted memories
    syncDeletedMemories();
    return changed;
  }

  Future<void> addMemories(MemoriesModel memory) async {
    // create or update memory
    memory.isLocal = true;
    memories.add(memory);
    //now save the memory to the cache
    await memoryCache.writeCache(jsonEncode(memories));

    //sync the memories
    syncMemories().then((value) => {
          if (value)
            {print('Memories updated'), eventBus.fire(MemoriesUpdatedEvent())}
        });
  }

  Future<void> updateMemory(MemoriesModel memory) async {
    memory.isLocal = true;
    // find the memory by id and update it
    memories = memories.map((e) => e.id == memory.id ? memory : e).toList();
    // Save memories to the cache
    await memoryCache.writeCache(jsonEncode(memories));
    syncMemories().then((value) => {
          if (value) {eventBus.fire(MemoriesUpdatedEvent())}
        });
  }

  Future <void> deleteMemories(MemoriesModel memory) async {
    // Delete memory from the server
    memories.removeWhere((element) => element.id == memory.id);
    await memoryCache.writeCache(jsonEncode(memories));
    syncDeleteMemories(memory);
  }
  
  Future<void> syncDeleteMemories(MemoriesModel memory)async{
    String? deletedMemoriesString = await deletedMemoriesCache.readCache();
    List<String> deletedMemoriesIds = [];
    if (deletedMemoriesString != null && deletedMemoriesString.isNotEmpty) {
      deletedMemoriesIds = List<String>.from(jsonDecode(deletedMemoriesString));
    }
    deletedMemoriesIds.add(memory.id); // add the memory id to the list
    await deletedMemoriesCache.writeCache(jsonEncode(deletedMemoriesIds)); // join the ids by ;

    // add the images to the deleted images cache

    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }
    for (var imageKey in memory.imageKeysToUrlMap.keys) {
      final actualKey = "$moduleName/${memory.id}/$imageKey";
      deletedImages.add(actualKey);
    }
    await deletedImagesCache.writeCache(jsonEncode(deletedImages)); // join the ids by ;

    //sync the deleted memories
    syncDeletedMemories();
  }


  Future<void> syncDeletedMemories() async {
    //read the deleted memories from the cache
    List<String> deletedMemoriesIds = [];
    String? deletedMemoriesString = await deletedMemoriesCache.readCache();
    if (deletedMemoriesString != null && deletedMemoriesString.isNotEmpty) {
      deletedMemoriesIds = List<String>.from(jsonDecode(deletedMemoriesString));
    }

    //read the deleted images from the cache
    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }


    // failed to sync the deleted memories
    List<String> failedMemories = [];
    //sync the deleted memories
    for (var memoryId in deletedMemoriesIds) {
      bool success = await memoriesProvider.deleteMemories(memoryId);
      if (!success) {
        //remove the memory from the deleted memories
        failedMemories.add(memoryId);
      }
    }

    // failed to sync the deleted images
    List<String> failedImages = [];
    //sync the deleted images
    for (var image in deletedImages) {
      bool success = await memoriesProvider.deleteImage(image);
      if (!success) {
        //remove the image from the deleted images
        failedImages.add(image);
      }
    }

    //remove the failed memories from the deleted memories cache
    await deletedMemoriesCache.writeCache(jsonEncode(failedMemories));
    await deletedImagesCache.writeCache(jsonEncode(failedImages));
  }

  Future <void> deleteImages(List<String> deletedImagesKeys) async {
    // add the images to the deleted images cache
    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }
    deletedImages.addAll(deletedImagesKeys);
    await deletedImagesCache.writeCache(jsonEncode(deletedImages)); // join the ids by ;
  }
}
