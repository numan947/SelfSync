import 'package:selfsync_frontend/common/common_functions.dart';

class NoteItem{
  String id; // Unique identifier
  String title; // Title of the note
  String content; // Content of the note
  DateTime createdAt; // Date and time the note was created
  DateTime updatedAt; // Date and time the note was last updated
  Map<String, String> imageKeysToUrls;
  bool localOnly;
  
  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.imageKeysToUrls,
    required this.localOnly,
  });


  // create a copy of the note item from another note item
  factory NoteItem.copy(NoteItem note) {
    return NoteItem(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
      imageKeysToUrls: Map.from(note.imageKeysToUrls),
      localOnly: note.localOnly,
    );
  }

  //copy with
  NoteItem copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? imageKeysToUrls,
    bool? localOnly,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageKeysToUrls: imageKeysToUrls ?? this.imageKeysToUrls,
      localOnly: localOnly ?? this.localOnly,
    );
  }
  
  // Empty note item for creating new notes
  factory NoteItem.empty() {
    return NoteItem(
      //create temporary unique id
      id: generateUniqueId(),
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageKeysToUrls: {},
      localOnly: true,
    );
  }
  factory NoteItem.fromJson(Map<String, dynamic> json) {
    if (json['images'] == null) {
      json['images'] = [];
    }
    if (json['imageKeys'] == null) {
      json['imageKeys'] = [];
    }

    if (json['localOnly'] == null) {
      json['localOnly'] = false;
    }

    // fix dtype issue
    if (json['createdAt'] is String) {
      json['createdAt'] = int.parse(json['createdAt']);
    }
    if (json['updatedAt'] is String) {
      json['updatedAt'] = int.parse(json['updatedAt']);
    }

    return NoteItem(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
      localOnly: json['localOnly'],
      imageKeysToUrls: Map<String, String>.from(json['imageKeysToUrls']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'localOnly': localOnly,
      'imageKeysToUrls': imageKeysToUrls,
    };
  }

  // String representation of the note item
  @override
  String toString() {
    return 'NoteItem{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, imageKeysToUrls: $imageKeysToUrls, localOnly: $localOnly}';
  }
}