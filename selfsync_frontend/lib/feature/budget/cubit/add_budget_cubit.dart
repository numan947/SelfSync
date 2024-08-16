import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/budget_model.dart';

part 'add_budget_state.dart';

class AddBudgetCubit extends Cubit<AddBudgetState> {
  AddBudgetCubit() : super(AddBudgetLoading());

  void refreshUI(BudgetModel budget) {
    emit(AddBudgetLoading());
    emit(AddBudgetLoaded(budget));
  }
}
