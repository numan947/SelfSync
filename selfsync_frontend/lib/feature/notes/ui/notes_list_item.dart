
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selfsync_frontend/feature/notes/model/notes_model.dart';

class NotesListItem extends StatelessWidget {
  final NoteItem note;
  final Function onTap;
  final Function onDelete;

  const NotesListItem({super.key, required this.onTap, required this.note, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              note.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.blueGrey),
            ),
            subtitle: Column(children: [
              Row(children: [
                const Icon(Icons.create),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat.yMMMd().format(note.createdAt),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              ]),
              const SizedBox(
                height: 5,
              ),
              Row(children: [
                const Icon(Icons.update),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat.yMMMd().format(note.updatedAt),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )
              ]),
              const SizedBox(
                height: 5,
              ),
              Row(children: [
                const Icon(Icons.image),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  note.imageKeysToUrls.length.toString(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (note.localOnly)
                  const SizedBox(
                    width: 10,
                  ),
                if (note.localOnly)
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.red,
                  ),
                if (!note.localOnly)
                  const SizedBox(
                    width: 10,
                  ),
                if (!note.localOnly)
                  const Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                  )
              ]),
            ]),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: note.localOnly? Colors.grey:Colors.red),
              onPressed: () {
                // local notes should not be deleted
                if (!note.localOnly) {
                  onDelete();
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot delete local notes'),
                    ),
                  );
                }
              },
            ),
            onTap: () => onTap(),
            onLongPress: (){
              if (!note.localOnly) {
                onDelete();
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot delete local notes'),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
