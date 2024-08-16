part of 'add_budget_cubit.dart';

@immutable
sealed class AddBudgetState extends Equatable{}

final class AddBudgetLoading extends AddBudgetState {
  AddBudgetLoading();
  @override
  List<Object> get props => [];
}

final class AddBudgetLoaded extends AddBudgetState {
  final BudgetModel budget;
  AddBudgetLoaded(this.budget);
  @override
  List<Object> get props => [budget];
}
