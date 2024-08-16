import 'dart:convert';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/common/my_custom_cache.dart';
import 'package:selfsync_frontend/feature/notes/data/notes_provider.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

import '../../../main.dart';

class NotesRepository {
  static const String moduleName = 'notes';
  final MyCustomCache notesCache = MyCustomCache(
    cacheKey: 'all_notes',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years
    dirPrefix: 'notes',
  );

  final MyCustomCache deletedNotesCache = MyCustomCache(
    cacheKey: 'deleted_notes',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years
    dirPrefix: 'notes',
  );

  final MyCustomCache deletedImagesCache = MyCustomCache(
    cacheKey: 'deleted_images',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years
    dirPrefix: 'notes',
  ); // contains the keys of the images that have been deleted

  final NotesProvider _notesProvider;
  List<NoteItem> notes = [];

  NotesRepository(this._notesProvider);

  List<NoteItem> get getNotes => notes; // get notes from the repository

  Future<List<NoteItem>> fetchNotes() async {
    await syncDeletedNotes();
    await syncNotes();
    String? networkResponse = await _notesProvider.getNotes();
    List<NoteItem> serverNotes = [];
    try {
      if (networkResponse != null) {
        List<dynamic> tmp = jsonDecode(networkResponse) as List;
        for (var note in tmp) {
          serverNotes.add(NoteItem(
              id: note['id'],
              title: note['title'],
              content: note['content'],
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(note['createdAt'])),
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                  int.parse(note['updatedAt'])),
              imageKeysToUrls: Map<String, String>.from(
                  {for (var key in note['imageKeys']) key: ''}),
              localOnly: false));
        }
        // Save notes to the cache
        await notesCache.writeCache(jsonEncode(serverNotes));
        notes = serverNotes;
      }
    } catch (e) {
      print('Error fetching notes: $e');
    }
    return notes;
  }

  Future<void> addNote(NoteItem newNote) async {
    // create or update note
    newNote.localOnly = true;
    notes.add(newNote);
    //now save the note to the cache
    await notesCache.writeCache(jsonEncode(notes));

    //sync the notes
    syncNotes().then((value) => {
          if (value)
            {print('Notes updated'), eventBus.fire(NotesUpdatedEvent())}
        });
  }

  Future<void> updateNote(NoteItem note) async {
    note.localOnly = true;
    // find the note by id and update it
    notes = notes.map((e) => e.id == note.id ? note : e).toList();
    // Save note to the cache
    await notesCache.writeCache(jsonEncode(notes));
    syncNotes().then((value) => {
          if (value) {eventBus.fire(NotesUpdatedEvent())}
        });
  }

  Future<void> deleteNote(NoteItem note) async {
    // Delete note from the server
    notes.removeWhere((element) => element.id == note.id);
    await notesCache.writeCache(jsonEncode(notes));
    syncDeleteNotes(note);
  }

  Future<void> syncDeleteNotes(NoteItem note) async {
    String? deletedNotesString = await deletedNotesCache.readCache();
    List<String> deletedNotesIds = [];
    if (deletedNotesString != null && deletedNotesString.isNotEmpty) {
      deletedNotesIds = List<String>.from(jsonDecode(deletedNotesString));
    }
    deletedNotesIds.add(note.id); // add the note id to the list
    await deletedNotesCache
        .writeCache(jsonEncode(deletedNotesIds)); // join the ids by ;

    // add the images to the deleted images cache

    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }
    for (var imageKey in note.imageKeysToUrls.keys) {
      final actualKey = "$moduleName/${note.id}/$imageKey";
      deletedImages.add(actualKey);
    }
    await deletedImagesCache
        .writeCache(jsonEncode(deletedImages)); // join the ids by ;

    //sync the deleted note
    syncDeletedNotes();
  }

  Future<bool> syncNotes() async {
    print('Syncing notes');
    //clear the cache if file does not exist
    await notesCache.invalidateCacheIfFileDoesNotExist();
    await deletedNotesCache.invalidateCacheIfFileDoesNotExist();
    await deletedImagesCache.invalidateCacheIfFileDoesNotExist();
    bool changed = false;

    List<NoteItem> localNotes = [];
    // Fetch notes from the cache
    bool cacheValid = await notesCache.isCacheValid();
    if (cacheValid) {
      String? cachedNotes = await notesCache.readCache();
      if (cachedNotes != null && cachedNotes.isNotEmpty) {
        try {
          jsonDecode(cachedNotes).forEach((nt) {
            localNotes.add(NoteItem.fromJson(nt));
          });
        } catch (e) {
          // invalidate the cache
          await notesCache.invalidateCache();
        }
      }
    }
    // Check if there are any notes in the cache that needs to be synced, on success update the isLocal flag to false
    if (localNotes.isNotEmpty) {
      List<NoteItem> tmpNotes = List.from(localNotes);
      for (var note in tmpNotes) {
        if (note.localOnly) {
          bool hasLocalImages = false;
          // first try to sync the images
          for (var imageKey in note.imageKeysToUrls.keys) {
            if (isLocalPath(note.imageKeysToUrls[imageKey] ?? '')) {
              final actualKey = "$moduleName/${note.id}/$imageKey";
              // the image has not been uploaded yet
              String? imageUrl = await _notesProvider.uploadImage(
                  actualKey,
                  note.imageKeysToUrls[imageKey] ??
                      ''); // this will not be called for '', as it means the image has been uploaded
              if (imageUrl != null) {
                note.imageKeysToUrls[imageKey] =
                    ''; // '' means the image has been uploaded
              } else {
                hasLocalImages = true;
              }
            }
          }
          if (hasLocalImages) {
            //skip uploading the note if there are local images
            continue;
          }
          bool success = await _notesProvider.syncNotes(note);
          if (success) {
            note.localOnly = false;
            changed = true;
          }
        }
      }
      localNotes = tmpNotes;
    }

    notes = localNotes;

    //sync deleted notes
    syncDeletedNotes();
    return changed;
  }

  Future<void> syncDeletedNotes() async {
    //read the deleted notes from the cache
    List<String> deletedNoteIds = [];
    String? deletedNotesString = await deletedNotesCache.readCache();
    if (deletedNotesString != null && deletedNotesString.isNotEmpty) {
      deletedNoteIds = List<String>.from(jsonDecode(deletedNotesString));
    }

    //read the deleted images from the cache
    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }

    // failed to sync the deleted notes
    List<String> failedNotes = [];
    //sync the deleted notes
    for (var noteId in deletedNoteIds) {
      bool success = await _notesProvider.deleteNotes(noteId);
      if (!success) {
        //remove the note from the deleted notes
        failedNotes.add(noteId);
      }
    }

    // failed to sync the deleted images
    List<String> failedImages = [];
    //sync the deleted images
    for (var image in deletedImages) {
      bool success = await _notesProvider.deleteImage(image);
      if (!success) {
        //remove the image from the deleted images
        failedImages.add(image);
      }
    }

    //save the failed notes to the deleted notes cache
    await deletedNotesCache.writeCache(jsonEncode(failedNotes));
    await deletedImagesCache.writeCache(jsonEncode(failedImages));
  }

  Future<void> deleteImages(List<String> deletedImagesKeys) async {
    // add the images to the deleted images cache
    List<String> deletedImages = [];
    String? deletedImagesString = await deletedImagesCache.readCache();
    if (deletedImagesString != null && deletedImagesString.isNotEmpty) {
      deletedImages = List<String>.from(jsonDecode(deletedImagesString));
    }
    deletedImages.addAll(deletedImagesKeys);
    await deletedImagesCache
        .writeCache(jsonEncode(deletedImages)); // join the ids by ;
  }
}
