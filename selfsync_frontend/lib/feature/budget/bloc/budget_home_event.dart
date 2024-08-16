part of 'budget_home_bloc.dart';

@immutable
sealed class BudgetHomeEvent extends Equatable {}

final class ShowBudgetHome extends BudgetHomeEvent {
  final int? year;
  final int? month;
  ShowBudgetHome(this.year, this.month);
  @override
  List<Object> get props => [];
}

final class ShowBudgetSummary extends BudgetHomeEvent {
  final int year;
  ShowBudgetSummary(this.year);
  @override
  List<Object> get props => [];
}

final class CreateNewBudgetEntry extends BudgetHomeEvent {
  final BudgetModel budgetModel;
  CreateNewBudgetEntry(this.budgetModel);
  @override
  List<Object> get props => [budgetModel];
}

final class UpdateBudgetEntry extends BudgetHomeEvent {
  final BudgetModel budgetModel;
  UpdateBudgetEntry(this.budgetModel);
  @override
  List<Object> get props => [budgetModel];
}

final class DeleteBudgetEntry extends BudgetHomeEvent {
  final BudgetModel budgetModel;
  DeleteBudgetEntry(this.budgetModel);
  @override
  List<Object> get props => [budgetModel];
}

final class BudgetInternetConnected extends BudgetHomeEvent {
  BudgetInternetConnected();
  @override
  List<Object> get props => [];
}

final class BudgetQuery extends BudgetHomeEvent {
  final String query;
  BudgetQuery(this.query);
  @override
  List<Object> get props => [query];
}