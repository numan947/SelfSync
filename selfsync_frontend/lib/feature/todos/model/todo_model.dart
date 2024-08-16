import 'package:selfsync_frontend/common/common_functions.dart';

class Todo{
  String id;
  String title;
  DateTime dateAdded;
  DateTime dueDate;
  bool completed;
  bool isLocal;

  Todo({
    required this.id,
    required this.title,
    required this.dateAdded,
    required this.dueDate,
    required this.completed,
    required this.isLocal,
  });

  // empty
  static Todo empty() => Todo(
    id: generateUniqueId(),
    title: '',
    dateAdded: DateTime.now(),
    dueDate: DateTime.now(),
    completed: false,
    isLocal: true,
  );

  Todo copyWith({
    String? id,
    String? title,
    DateTime? dateAdded,
    DateTime? dueDate,
    bool? completed,
    bool? isLocal,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      dateAdded: dateAdded ?? this.dateAdded,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Todo &&
      other.id == id &&
      other.title == title &&
      other.dateAdded == dateAdded &&
      other.dueDate == dueDate &&
      other.completed == completed;
  }

  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        dateAdded = DateTime.fromMillisecondsSinceEpoch(int.parse(json['dateAdded'])),
        dueDate = DateTime.fromMillisecondsSinceEpoch(int.parse(json['dueDate'])),
        completed = json['completed'] ?? false,
        isLocal = json['isLocal'] ?? false;
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateAdded': dateAdded.millisecondsSinceEpoch.toString(),
        'dueDate': dueDate.millisecondsSinceEpoch.toString(),
        'completed': completed,
        'isLocal': isLocal,
      };

  @override
  String toString() {
    return 'Todo {id: $id, title: $title, dateAdded: $dateAdded, dueDate: $dueDate, completed: $completed, isLocal: $isLocal}';
  }
}