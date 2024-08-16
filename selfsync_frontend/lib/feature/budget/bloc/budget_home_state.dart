part of 'budget_home_bloc.dart';

@immutable
sealed class BudgetHomeState extends Equatable{}

final class BudgetHomeLoading extends BudgetHomeState {
  BudgetHomeLoading();
  @override
  List<Object> get props => [];
}
final class BudgetHomeLoaded extends BudgetHomeState {
  final List<BudgetModel> budgetList;
  final int selectedYear;
  final int selectedMonth;
  final int bottomSheetIndex;
  BudgetHomeLoaded({required this.budgetList, required this.selectedYear, required this.selectedMonth, required this.bottomSheetIndex});
  @override
  List<Object> get props => [budgetList, selectedYear, selectedMonth, bottomSheetIndex];
}

final class BudgetSummaryLoaded extends BudgetHomeState {
  final List<BudgetModel> budgetList;
  final int selectedYear;
  final int bottomSheetIndex;
  BudgetSummaryLoaded({required this.budgetList, required this.selectedYear, required this.bottomSheetIndex});
  @override
  List<Object> get props => [budgetList, selectedYear, bottomSheetIndex];
}

final class BudgetSummaryError extends BudgetHomeState {
  final int bottomSheetIndex = 1;
  BudgetSummaryError();
  @override
  List<Object> get props => [];
}

final class BudgetHomeError extends BudgetHomeState {
  final int bottomSheetIndex = 0;
  BudgetHomeError();
  @override
  List<Object> get props => [];
}