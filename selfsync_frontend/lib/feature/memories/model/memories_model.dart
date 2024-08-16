import 'package:flutter/foundation.dart';
import 'package:selfsync_frontend/common/common_functions.dart';

class MemoriesModel {
  String id;
  String title;
  String? description;
  DateTime? startDate;
  DateTime? endDate; // can be null
  Map<String,String> imageKeysToUrlMap; // (imageKey, imageUrl)
  bool isLocal;

  MemoriesModel(
      {required this.id,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.imageKeysToUrlMap,
      this.isLocal = true
      });

  factory MemoriesModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['title'] == null) {
      throw Exception(
          'Malformed MemoriesModel: $json, id and title are required.');
    }
    DateTime? startDate;
    DateTime? endDate;

    if (json['startDate'] != null) {
      startDate = DateTime.fromMillisecondsSinceEpoch(int.parse(json['startDate']));
    }
    if (json['endDate'] != null) {
      endDate = DateTime.fromMillisecondsSinceEpoch(int.parse(json['endDate']));
    }
    Map<String, String> imageKeys = {};
    if (json['imageKeys'] != null) {
      imageKeys = Map<String, String>.from(json['imageKeys']);
    }
    String description = '';
    if (json['description'] != null) {
      description = json['description'];
    }

    return MemoriesModel(
        id: json['id'],
        title: json['title'],
        description: description,
        startDate: startDate,
        endDate: endDate,
        imageKeysToUrlMap: imageKeys,
        isLocal: json['isLocal'] ?? false
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate?.millisecondsSinceEpoch.toString(),
      'endDate': endDate?.millisecondsSinceEpoch.toString(),
      'imageKeys': imageKeysToUrlMap,
      'isLocal': isLocal
    };
  }

  static MemoriesModel empty() => MemoriesModel(
      id: generateUniqueId(),
      title: '',
      description: '',
      startDate: null,
      endDate: null,
      imageKeysToUrlMap: {},
      isLocal: true
      );
  
  //create deep copy of the memory model

  MemoriesModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, String>? imageKeysToUrlMap,
    Map<String, String>? imageCaptions,
    bool? isLocal
  }) {
    return MemoriesModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageKeysToUrlMap: imageKeysToUrlMap ?? Map.from(this.imageKeysToUrlMap), // creates deep copy
      isLocal: isLocal ?? this.isLocal
    );
  }

  @override
  String toString() {
    return 'MemoriesModel{isLocal: $isLocal ,id: $id, title: $title, description: $description, startDate: $startDate, endDate: $endDate, imageKeys: $imageKeysToUrlMap}';
  }

  // compare two memories, do not compare the isLocal field
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MemoriesModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        listEquals(other.imageKeysToUrlMap.keys.toList(), imageKeysToUrlMap.keys.toList());
  }
}
