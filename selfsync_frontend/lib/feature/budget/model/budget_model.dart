import 'package:selfsync_frontend/common/common_functions.dart';

class BudgetModel{
  String id;
  String entryTitle;
  double amount;
  int dateDay;
  int dateMonth;
  int dateYear;
  bool isLocal;

  BudgetModel({
    required this.id,
    required this.entryTitle,
    required this.amount,
//    required this.category,
    required this.dateDay,
    required this.dateMonth,
    required this.dateYear,
    this.isLocal=false
  });


  // create empty BudgetModel
  factory BudgetModel.empty() {
    DateTime dd = DateTime.now();
    int day = dd.day;
    int month = dd.month;
    int year = dd.year;
    return BudgetModel(
      id: generateUniqueId(),
      entryTitle: '',
      amount: 0.0,
//      category: '',
      dateDay: day,
      dateMonth: month,
      dateYear: year,
      isLocal: true
    );
  }

// copy with 
  BudgetModel copyWith({
    String? id,
    String? entryTitle,
    double? amount,
//    String? category,
    int? dateDay,
    int? dateMonth,
    int? dateYear,
    bool? isLocal
  }) {
    return BudgetModel(
      id: id ?? this.id,
      entryTitle: entryTitle ?? this.entryTitle,
      amount: amount ?? this.amount,
//      category: category ?? this.category,
      dateDay: dateDay ?? this.dateDay,
      dateMonth: dateMonth ?? this.dateMonth,
      dateYear: dateYear ?? this.dateYear,
      isLocal: isLocal ?? this.isLocal
    );
  }


  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') ||
        !json.containsKey('entryTitle') ||
        !json.containsKey('amount') ||
//        !json.containsKey('category') ||
        !json.containsKey('dateDay') ||
        !json.containsKey('dateMonth') ||
        !json.containsKey('dateYear')) {
      throw const FormatException(
          "Missing required fields in BudgetModel JSON");
    }
    if (!json.containsKey('isLocal')) {
      json['isLocal'] = false;
    }
    return BudgetModel(
      id: json['id'],
      entryTitle: json['entryTitle'],
      amount: double.parse(json['amount']),
//      category: json['category'],
      dateDay: int.parse(json['dateDay']),
      dateMonth: int.parse(json['dateMonth']),
      dateYear: int.parse(json['dateYear']),
      isLocal: json['isLocal']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entryTitle': entryTitle,
      'amount': amount.toString(),
//      'category': category,
      'dateDay': dateDay.toString(),
      'dateMonth': dateMonth.toString(),
      'dateYear': dateYear.toString(),
      'isLocal': isLocal
    };
  }

  @override
  String toString() {
    return 'BudgetModel{id: $id, entryTitle: $entryTitle, amount: $amount, dateDay: $dateDay, dateMonth: $dateMonth, dateYear: $dateYear, isLocal: $isLocal}';
  }
  
}