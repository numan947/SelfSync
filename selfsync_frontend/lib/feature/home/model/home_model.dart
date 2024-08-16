class HomeModel {
  final int noteCount;
  final int totalImagesInNotes;
  final int todoCount;
  final int completedTodoCount;
  final int monthlyCost;
  final int yearlyCost;
  final int totalMemories;
  final int totalMemoryImages;


  HomeModel({
    required this.noteCount,
    required this.totalImagesInNotes,
    required this.todoCount,
    required this.completedTodoCount,
    required this.monthlyCost,
    required this.yearlyCost,
    required this.totalMemories,
    required this.totalMemoryImages,
  });


  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      noteCount: int.parse(json['noteCount']),
      totalImagesInNotes: int.parse(json['totalImagesInNotes']),
      todoCount: int.parse(json['todoCount']),
      completedTodoCount: int.parse(json['completedTodoCount']),
      monthlyCost: int.parse(json['monthlyCost']),
      yearlyCost: int.parse(json['yearlyCost']),
      totalMemories: int.parse(json['totalMemories']),
      totalMemoryImages: int.parse(json['totalMemoryImages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noteCount': noteCount.toString(),
      'totalImagesInNotes': totalImagesInNotes.toString(),
      'todoCount': todoCount.toString(),
      'completedTodoCount': completedTodoCount.toString(),
      'monthlyCost': monthlyCost.toString(),
      'yearlyCost': yearlyCost.toString(),
      'totalMemories': totalMemories.toString(),
      'totalMemoryImages': totalMemoryImages.toString(),
    };
  }

  static HomeModel empty() {
    return HomeModel(
      noteCount: 0,
      totalImagesInNotes: 0,
      todoCount: 0,
      completedTodoCount: 0,
      monthlyCost: 0,
      yearlyCost: 0,
      totalMemories: 0,
      totalMemoryImages: 0,
    );
  }

  @override
  String toString() {
    return 'HomeModel(noteCount: $noteCount, totalImagesInNotes: $totalImagesInNotes, todoCount: $todoCount, completedTodoCount: $completedTodoCount, monthlyCost: $monthlyCost, yearlyCost: $yearlyCost, totalMemories: $totalMemories, totalMemoryImages: $totalMemoryImages)';
  }


}