import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/constants.dart';
import 'package:selfsync_frontend/feature/notes/cubit/add_note_view_cubit.dart';
import 'package:path/path.dart' as path;

import '../model/notes_model.dart';

class NoteAddOrEdit extends StatefulWidget {
  final NoteItem note;
  final bool editable;
  final Function(List<dynamic>) onSave;
  final Function() onCancel;
  const NoteAddOrEdit({super.key, required this.note, required this.editable, required this.onSave, required this.onCancel});

  @override
  State<NoteAddOrEdit> createState() => _NoteAddOrEditState();
}

class _NoteAddOrEditState extends State<NoteAddOrEdit> {
  final String moduleName = 'notes';
  late AddNoteViewCubit addViewCubit;
  late TextEditingController titleController;
  late TextEditingController contentController;

  bool isEditing = false;
  String createdAt = '';
  String updatedAt = '';
  late NoteItem note;
  List<String> deletedImages = [];
  bool changed = false;
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
    titleController.text = widget.note.title;
    contentController.text = widget.note.content;
    createdAt = DateFormat.yMMMd().format(widget.note.createdAt);
    updatedAt = DateFormat.yMMMd().format(widget.note.updatedAt);
    isEditing = widget.editable;
    addViewCubit = AddNoteViewCubit();
    note = NoteItem.copy(
        widget.note); // copy the note to avoid changing the original note
    addViewCubit.refreshUI(note);
  }

  //dispose text controllers
  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
      ),
      body: SingleChildScrollView(
        child: BlocProvider(
          create: (context) => addViewCubit,
          child: BlocBuilder<AddNoteViewCubit, AddNoteViewCubitState>(
            builder: (context, state) {
              if (state is AddNoteViewLoaded) {
                // print('State: $state');
                note = state.note;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          enabled: isEditing,
                          minLines: 1,
                          maxLines: 3,
                          clipBehavior: Clip.antiAlias,
                          controller: titleController,
                          onChanged: isEditing
                              ? (value) {
                                  note.title = value;
                                  changed = true;
                                }
                              : null,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                            labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.purple,
                                decoration: TextDecoration.none),
                          )),
                    ),
                    //Date of creation and last edit, they should be in column
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        const Icon(Icons.create),
                        const SizedBox(width: 10),
                        Text(createdAt,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                decoration: TextDecoration.none))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        const Icon(Icons.update),
                        const SizedBox(width: 10),
                        Text(updatedAt,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                decoration: TextDecoration.none))
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          enabled: isEditing,
                          minLines: 5,
                          maxLines: null,
                          clipBehavior: Clip.antiAlias,
                          controller: contentController,
                          onChanged: isEditing
                              ? (value) {
                                  note.content = value;
                                  changed = true;
                                }
                              : null,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                              decoration: TextDecoration.none),
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                            labelStyle: TextStyle(
                                fontSize: 20,
                                color: Colors.purple,
                                decoration: TextDecoration.none),
                          )),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Images',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                    ),
                    // print('State: $state');
                    ResponsiveGridList(
                        shrinkWrap: true,
                        desiredItemWidth: 100,
                        minSpacing: 10,
                        children: note.imageKeysToUrls.entries.map((entry) {
                          final image = entry.value;
                          var imageKey = entry.key;
                          return InkWell(
                            onLongPress: () {
                              if (isEditing) {
                                // show dialog to delete image
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Delete Image'),
                                        content: const Text(
                                            'Are you sure you want to delete this image?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop('Yes');
                                            },
                                            child: const Text('Yes'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop('No');
                                            },
                                            child: const Text('No'),
                                          )
                                        ],
                                      );
                                    }).then((value) async {
                                  if (value == 'Yes') {
                                    note.imageKeysToUrls.remove(imageKey);
                                    changed = true;
                                    if (!isLocalPath(image)) {
                                      deletedImages.add(
                                          "$moduleName/${note.id}/$imageKey"
                                      ); // we will delete the image from the server, local images are not deleted, as they are not uploaded
                                    }
                                    context
                                        .read<AddNoteViewCubit>()
                                        .refreshUI(note);
                                  }
                                });
                              }
                            },
                            child: InstaImageViewer(
                              child: isLocalPath(image)
                                  ? kIsWeb
                                      ? Image.network(image)
                                      : Image.file(File(image))
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: image,
                                      placeholder: (context, url) =>
                                          const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                            ),
                          );
                        }).toList()),
                    //add image button here big and centered, this is for adding image from camera
                    if (!kIsWeb &&
                        (Platform.isAndroid || Platform.isIOS) &&
                        isEditing)
                      Center(
                        child: SizedBox(
                            height: 100,
                            width: 100,
                            child: IconButton(
                              onPressed: () {
                                final ImagePicker picker = ImagePicker();
                                picker
                                    .pickImage(source: ImageSource.camera)
                                    .then((image) {
                                  if (image == null) return;
                                  Map<String, String> imageKeysToUrlMap = {};
                                  imageKeysToUrlMap.addAll(note
                                      .imageKeysToUrls); // copy the existing images
                                  // create unique key for the image
                                  // save the image path
                                  final ext = path.extension(image.path);
                                  final key = '${generateUniqueId()}$ext';
                                  imageKeysToUrlMap[key] = image.path;
                                  changed = true;
                                  context.read<AddNoteViewCubit>().refreshUI(
                                      note.copyWith(
                                          imageKeysToUrls: imageKeysToUrlMap));
                                });
                              },
                              icon: const Icon(Icons.add_a_photo),
                              iconSize: 60,
                            )),
                      ),
                    if (isEditing) // add image button here big and centered, this is for adding image from gallery
                      Center(
                        child: IconButton(
                          onPressed: () {
                            final ImagePicker picker = ImagePicker();
                            picker.pickMultiImage().then((value) {
                              Map<String, String> imageKeysToUrlMap = {};
                              imageKeysToUrlMap.addAll(note
                                  .imageKeysToUrls); // copy the existing images
                              for (final image in value) {
                                // create unique key for the image
                                // save the image path
                                final ext = path.extension(image.path);
                                final key = '${generateUniqueId()}$ext';
                                imageKeysToUrlMap[key] = image.path;
                              }
                              changed = true; // update the UI
                              context.read<AddNoteViewCubit>().refreshUI(
                                  note.copyWith(
                                      imageKeysToUrls: imageKeysToUrlMap));
                            });
                          },
                          icon: const Icon(Icons.open_in_browser),
                          iconSize: 60,
                        ),
                      )
                  ],
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: LoadingAnimationWidget.discreteCircle(
                          color: AppColors.borderColor, size: 30)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'SaveNoteButton',
            onPressed: () {
              if (changed) {
                print('NoteAddOrEdit: Saving note');
                widget.onSave([note, deletedImages]);
              }
              else {
                widget.onCancel();
              }
            },
            child: const Icon(Icons.save),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: 'CancelNoteButton',
            onPressed: () {
              widget.onCancel();
            },
            child: const Icon(Icons.cancel),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
