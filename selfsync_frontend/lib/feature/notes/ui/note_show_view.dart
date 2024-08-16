import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/constants.dart';
import 'package:selfsync_frontend/common/service/storage_service.dart';

import '../model/notes_model.dart';

class NoteShowView extends StatelessWidget {
  final String moduleName = 'notes';
  final NoteItem note;
  const NoteShowView({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          margin: const EdgeInsets.all(20),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SelectableText(note.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(
                height: 2,
              ),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.create),
                const SizedBox(width: 10),
                SelectableText(DateFormat.yMMMd().format(note.createdAt),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.none))
              ]),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.update),
                const SizedBox(width: 10),
                SelectableText(DateFormat.yMMMd().format(note.updatedAt),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.none))
              ]),
              const SizedBox(height: 5),
              if (note.content.isNotEmpty)
                const Divider(
                  height: 2,
                ),
              if (note.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          backgroundBlendMode: BlendMode.srcOver,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                              offset: Offset(0.0, 0.0),
                            )
                          ],
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: SelectableText(note.content,
                            style: const TextStyle(fontSize: 18))),
                  ),
                ),
              if (note.imageKeysToUrls.isNotEmpty)
                const Divider(
                  height: 2,
                ),
              if (note.imageKeysToUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ResponsiveGridList(
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      shrinkWrap: true,
                      desiredItemWidth: 150,
                      minSpacing: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      children: note.imageKeysToUrls.entries.map((entry) {
                        final image = entry.value;
                        final imageKey = entry.key;
                        return Card(
                          shadowColor: Colors.green[300],
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: (image == null || image == '')
                          ? LoadingAnimationWidget.hexagonDots(color: AppColors.contentColorYellow, size: 40)
                          :InkWell(
                              child: isLocalPath(image)
                                  ? kIsWeb
                                      ? Image.network(image)
                                      : Image.file(File(image))
                                  : CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: image,
                                      placeholder: (context, url) => SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: LoadingAnimationWidget.hexagonDots(color: AppColors.contentColorYellow, size: 40)),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Stack(
                                        children: [
                                          SizedBox(
                                            width: 300,
                                            height: 300,
                                            child: PhotoView(
                                              imageProvider: (isLocalPath(image)
                                                  ? kIsWeb
                                                      ? NetworkImage(image)
                                                      : FileImage(File(image))
                                                  : CachedNetworkImageProvider(
                                                      image)) as ImageProvider<
                                                  Object>,
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop('Download');
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
                                    );
                                  },
                                ).then((value) {
                                  if (value != null) {
                                    if (value == 'Download') {
                                      StorageService.downloadFile("$moduleName/${note.id}/$imageKey", 'notes')
                                          .then((value) => {
                                                if (value != null)
                                                  {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Downloaded at: $value'),
                                                        duration:
                                                            const Duration(
                                                                seconds: 2),
                                                        backgroundColor:
                                                            Colors.green[300],
                                                        elevation: 5,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                    )
                                                  }
                                                else
                                                  {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: const Text(
                                                              'Download failed'),
                                                          backgroundColor:
                                                              Colors.red[300],
                                                          duration:
                                                              const Duration(
                                                                  seconds: 2),
                                                          elevation: 5,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                    )
                                                  }
                                              });
                                    }
                                  }
                                });
                              }),
                        );
                      }).toList()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
