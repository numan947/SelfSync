import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:selfsync_frontend/common/service/storage_service.dart';
import 'package:selfsync_frontend/feature/memories/cubit/slide_show_cubit.dart';
import 'package:selfsync_frontend/feature/memories/model/memories_model.dart';
import 'package:selfsync_frontend/main.dart';
import 'package:path/path.dart' as path;
import '../../../common/common_functions.dart';
import '../../../common/eventbus_events.dart';
import '../cubit/memories_details_cubit.dart';

class MemoriesDetailsView extends StatefulWidget {
  const MemoriesDetailsView({super.key});
  @override
  State<MemoriesDetailsView> createState() => _MemoriesDetailsViewState();
}

class _MemoriesDetailsViewState extends State<MemoriesDetailsView> {
  late StreamSubscription
      _internetConnectionSubscription; // for retrying to load the images if the internet connection is back
  late StreamSubscription
      _memoriesSubscription; // for loading the images from the internet

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool changed =
      false; // this is for checking if the memory details have been changed
  static String moduleName = 'memories';
  List<String> deletedImageKeys = [];

  @override
  void initState() {
    super.initState();
    context.read<MemoriesDetailsCubit>().showMemoryDetails();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _memoriesSubscription =
          eventBus.on<MemoriesImagesLoadedEvent>().listen((event) {
        if (mounted) {
          context.read<MemoriesDetailsCubit>().reloadMemoryDetails();
        }
      });
      _internetConnectionSubscription =
          eventBus.on<InternetConnectedEvent>().listen((event) {
        if (mounted) {
          context.read<MemoriesDetailsCubit>().tryReloadingImages();
        }
      });
    });

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _memoriesSubscription.cancel();
    _internetConnectionSubscription.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoriesDetailsCubit, MemoriesDetailsState>(
      builder: (context, state) {
        if (state is MemoriesDetailsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is MemoriesDetailsLoaded) {
          final memory = (state).memory;
          return PopScope(
            canPop: false,
            onPopInvoked: (pop) {
              if (changed) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Save Changes?'),
                      content: const Text('Do you want to save the changes?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.pop();
                            context.pop();
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            //TODO: ACTIVE BUG IN FRAMEWORK, MAY BE FIX LATER? THIS IS PRETY WEIRD!
                            context.pop([memory, deletedImageKeys]);
                            context.pop();
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                context.pop();
              }
            },
            child: Scaffold(
              floatingActionButton: changed
                  ? FloatingActionButton(
                      onPressed: () {
                        context.pop([memory, deletedImageKeys]);
                      },
                      child: const Icon(Icons.save),
                    )
                  : null,
              appBar: AppBar(
                  title: Text(memory.title,
                      style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk', overflow: TextOverflow.ellipsis,)),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: () {
                        context
                            .read<MemoriesDetailsCubit>()
                            .showMemoryDetails();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ]),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.purple, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 233, 191, 240),
                          blurRadius: 10,
                          spreadRadius: 5,
                          offset: Offset(5, 5),
                        ),
                      ],
                      shape: BoxShape.rectangle,
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Tooltip(
                              message: 'Edit Title',
                              child: IconButton(
                                  onPressed: () {
                                    _titleController.text = memory.title;
                                    // show dialog with the text field to edit the title
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Edit Title'),
                                            content: TextField(
                                                controller: _titleController,
                                                maxLines: 3,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Title',
                                                  border: OutlineInputBorder(),
                                                  hintStyle: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      decoration:
                                                          TextDecoration.none),
                                                  labelStyle: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.purple,
                                                      decoration:
                                                          TextDecoration.none),
                                                )),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop('Ok');
                                                  },
                                                  child: const Text('Ok')),
                                            ],
                                          );
                                        }).then((value) {
                                      if (value == 'Ok') {
                                        if (_titleController.text.isNotEmpty) {
                                          changed = true;
                                          context
                                              .read<MemoriesDetailsCubit>()
                                              .updatedMemoryDetails(
                                                  memory.copyWith(
                                                      title: _titleController
                                                          .text));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content:
                                                Text('Title cannot be empty'),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit_document)),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: SelectableText(memory.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          color: Colors.black,
                          thickness: 2,
                        ),
                        Row(
                          children: [
                            Tooltip(
                              message: 'Edit Description',
                              child: IconButton(
                                  onPressed: () {
                                    _descriptionController.text =
                                        memory.description!;
                                    // show dialog with the text field to edit the description
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Edit Description'),
                                            content: TextField(
                                                controller:
                                                    _descriptionController,
                                                maxLines: 10,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Description',
                                                  border: OutlineInputBorder(),
                                                  hintStyle: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      decoration:
                                                          TextDecoration.none),
                                                  labelStyle: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.purple,
                                                      decoration:
                                                          TextDecoration.none),
                                                )),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel')),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop('Ok');
                                                  },
                                                  child: const Text('Ok')),
                                            ],
                                          );
                                        }).then((value) {
                                      if (value == 'Ok') {
                                        changed = true;
                                        context
                                            .read<MemoriesDetailsCubit>()
                                            .updatedMemoryDetails(
                                                memory.copyWith(
                                                    description:
                                                        _descriptionController
                                                            .text));
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.edit)),
                            ),
                            if (memory.description != null &&
                                memory.description!.isNotEmpty)
                              const SizedBox(
                                width: 5,
                              ),
                            if (memory.description != null &&
                                memory.description!.isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 217, 247, 244),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: SelectableText(
                                    memory.description ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'Change Start Date',
                              child: IconButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1980),
                                            lastDate: DateTime(2100))
                                        .then((value) {
                                      if (value != null) {
                                        changed = true;
                                        context
                                            .read<MemoriesDetailsCubit>()
                                            .updatedMemoryDetails(memory
                                                .copyWith(startDate: value));
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.data_exploration)),
                            ),
                            const SizedBox(width: 5),
                            Text(memory.startDate != null
                                ? DateFormat.yMMMd().format(memory.startDate!)
                                : ''),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Tooltip(
                              message: 'Change End Date',
                              child: IconButton(
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1980),
                                            lastDate: DateTime(2100))
                                        .then((value) {
                                      if (value != null) {
                                        changed = true;
                                        context
                                            .read<MemoriesDetailsCubit>()
                                            .updatedMemoryDetails(memory
                                                .copyWith(endDate: value));
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.explore_sharp)),
                            ),
                            const SizedBox(width: 5),
                            Text(memory.endDate != null
                                ? DateFormat.yMMMd().format(memory.endDate!)
                                : ''),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                          thickness: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!kIsWeb &&
                                (Platform.isAndroid || Platform.isIOS))
                              Tooltip(
                                message: 'Capture Image',
                                child: IconButton(
                                  onPressed: () {
                                    final ImagePicker picker = ImagePicker();
                                    picker
                                        .pickImage(source: ImageSource.camera)
                                        .then((image) {
                                      if (image == null) {
                                        return; // user cancelled the image capture
                                      }
                                      // just save the image path for now
                                      Map<String, String> imageKeysToUrlMap =
                                          {};
                                      imageKeysToUrlMap.addAll(memory
                                          .imageKeysToUrlMap); // copy the existing images
                                      // create unique key for the image
                                      // save the image path
                                      final ext = path.extension(image.path);
                                      final key = '${generateUniqueId()}$ext';
                                      imageKeysToUrlMap[key] = image.path;
                                      changed = true;
                                      context
                                          .read<MemoriesDetailsCubit>()
                                          .updatedMemoryDetails(memory.copyWith(
                                              imageKeysToUrlMap:
                                                  imageKeysToUrlMap));
                                    });
                                  },
                                  icon: const Icon(Icons.add_a_photo),
                                  iconSize: 60,
                                ),
                              ), // add image button here big and centered, this is for adding image from gallery

                            if (!kIsWeb &&
                                (Platform.isAndroid || Platform.isIOS))
                              const SizedBox(width: 10),
                            Tooltip(
                              message: 'Open Gallery',
                              child: IconButton(
                                onPressed: () {
                                  final ImagePicker picker = ImagePicker();
                                  picker.pickMultiImage().then((value) {
                                    // just save the image path for now
                                    Map<String, String> imageKeysToUrlMap = {};
                                    imageKeysToUrlMap.addAll(memory
                                        .imageKeysToUrlMap); // copy the existing images
                                    for (final image in value) {
                                      // create unique key for the image
                                      // save the image path
                                      final ext = path.extension(image.path);
                                      final key = '${generateUniqueId()}$ext';
                                      imageKeysToUrlMap[key] = image.path;
                                    }
                                    changed = true;
                                    context
                                        .read<MemoriesDetailsCubit>()
                                        .updatedMemoryDetails(memory.copyWith(
                                            imageKeysToUrlMap:
                                                imageKeysToUrlMap));
                                  });
                                },
                                icon: const Icon(Icons.photo_library_outlined),
                                iconSize: 60,
                              ),
                            ),
                            if (memory.imageKeysToUrlMap.isNotEmpty)
                              const SizedBox(width: 10),
                            if (memory.imageKeysToUrlMap.isNotEmpty)
                              Tooltip(
                                message: 'Number of Images',
                                child: Row(
                                  children: [
                                    const Icon(Icons.image, size: 60),
                                    const SizedBox(width: 5),
                                    Text('${memory.imageKeysToUrlMap.length}',
                                        style: const TextStyle(fontSize: 20)),
                                  ],
                                ),
                              )
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          color: Colors.black,
                          thickness: 2,
                        ),
                        const SizedBox(height: 10),
                        ResponsiveGridList(
                          desiredItemWidth: 150,
                          minSpacing: 10,
                          // controller: ScrollController(),
                          physics: const NeverScrollableScrollPhysics(),
                          rowMainAxisAlignment: MainAxisAlignment.center,
                          shrinkWrap: true,
                          children:
                              memory.imageKeysToUrlMap.entries.map((entry) {
                            final imageKey = entry.key;
                            final imageUrl = entry.value;
                            // print('Image Key: $imageKey, Image Url: $imageUrl');
                            return Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.purple,
                                surfaceTintColor: Colors.teal[100],
                                child: InkWell(
                                    onTap: () {
                                      showSlideShowDialog(memory, imageKey);
                                    },
                                    onLongPress: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Delete Image?'),
                                            content: const Text(
                                                'Do you want to delete this image?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop('Yes');
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      ).then((value) {
                                        if (value == 'Yes') {
                                          changed = true;
                                          memory.imageKeysToUrlMap
                                              .remove(imageKey);
                                          if (!isLocalPath(imageUrl)) {
                                            deletedImageKeys.add(
                                                "$moduleName/${memory.id}/$imageKey");
                                          }
                                          context
                                              .read<MemoriesDetailsCubit>()
                                              .updatedMemoryDetails(memory);
                                        }
                                      });
                                    },
                                    child: imageUrl == ''
                                        ? LoadingAnimationWidget.dotsTriangle(
                                            color: const Color(0xFFEA3799),
                                            size: 30,
                                          )
                                        : isLocalPath(imageUrl)
                                            ? kIsWeb
                                                ? Image.network(imageUrl)
                                                : Image.file(File(imageUrl))
                                            : CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl: imageUrl,
                                                placeholder: (context, url) => SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: LoadingAnimationWidget
                                                        .dotsTriangle(
                                                            color: const Color(
                                                                0xFFEA3799),
                                                            size: 30)),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              )));
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return const Center(
          child: Text('Error loading the memory'),
        );
      },
    );
  }

  Future<void> showSlideShowDialog(MemoriesModel mem, String currentKey) async {
    final imageKeys = mem.imageKeysToUrlMap.keys.toList();
    int currentIndex = imageKeys.indexOf(currentKey);

    final slideShowCubit = SlideShowCubit();
    slideShowCubit.refreshUI(currentIndex);

    showGeneralDialog(
      context: context,
      transitionDuration: const Duration(milliseconds: 150),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, a1, a2, child) {
        return Transform.scale(
          scale: a1.value,
          child: BlocProvider(
            create: (context) => slideShowCubit,
            child: AlertDialog(
              content: GestureDetector(
                // make it nautral to swipe left or right to change the image, onHorizontalDragEnd
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity != null) {
                    //do nothing
                  }
                  if (details.primaryVelocity! > 0) {
                    // User swiped Left
                    if (currentIndex > 0) {
                      currentIndex--;
                      slideShowCubit.refreshUI(currentIndex);
                    }
                  } else if (details.primaryVelocity! < 0) {
                    // User swiped Right
                    if (currentIndex < imageKeys.length - 1) {
                      currentIndex++;
                      slideShowCubit.refreshUI(currentIndex);
                    }
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: min(MediaQuery.of(context).size.height,
                          MediaQuery.of(context).size.width),
                      width: min(MediaQuery.of(context).size.height,
                          MediaQuery.of(context).size.width),
                      child: BlocBuilder<SlideShowCubit, SlideShowState>(
                        builder: (context, state) {
                          currentIndex =
                              (state as SlideShowLoaded).currentIndex;
                          final currentKey = imageKeys[currentIndex];
                          return PhotoView(
                            imageProvider: (isLocalPath(
                                        mem.imageKeysToUrlMap[currentKey]!)
                                    ? kIsWeb
                                        ? NetworkImage(
                                            mem.imageKeysToUrlMap[currentKey]!)
                                        : FileImage(File(
                                            mem.imageKeysToUrlMap[currentKey]!))
                                    : CachedNetworkImageProvider(
                                        mem.imageKeysToUrlMap[currentKey]!))
                                as ImageProvider<Object>,
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded),
                              onPressed: () {
                                if (currentIndex > 0) {
                                  currentIndex--;
                                  slideShowCubit.refreshUI(currentIndex);
                                }
                              },
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                if (currentIndex < imageKeys.length - 1) {
                                  currentIndex++;
                                  slideShowCubit.refreshUI(currentIndex);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    StorageService.downloadFile(
                            "$moduleName/${mem.id}/$currentKey", moduleName)
                        .then((value) {
                      if (value != null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Downloaded at $value'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Download Failed'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3)));
                      }
                    });
                  },
                  child: const Text('Download'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
