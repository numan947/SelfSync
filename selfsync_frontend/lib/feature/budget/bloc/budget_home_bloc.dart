import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfsync_frontend/feature/budget/data/budget_repository.dart';

import '../../../common/eventbus_events.dart';
import '../../../main.dart';
import '../model/budget_model.dart';

part 'budget_home_event.dart';
part 'budget_home_state.dart';

class BudgetHomeBloc extends Bloc<BudgetHomeEvent, BudgetHomeState> {
  final BudgetRepository budgetRepository;
  BudgetHomeBloc(this.budgetRepository) : super(BudgetHomeLoading()) {
    on<ShowBudgetHome>(_onShowBudgetHome);
    on<ShowBudgetSummary>(_onShowBudgetSummary);
    on<CreateNewBudgetEntry>(_onCreateNewBudgetEntry);
    on<UpdateBudgetEntry>(_onUpdateBudgetEntry);
    on<DeleteBudgetEntry>(_onDeleteBudgetEntry);
    on<BudgetInternetConnected>(_onBudgetInternetConnected);
    on<BudgetQuery>(_onBudgetQuery);
  }

  Future<FutureOr<void>> _onShowBudgetHome(
      ShowBudgetHome event, Emitter<BudgetHomeState> emit) async {
    emit(BudgetHomeLoading());
    print('ShowBudgetHome event: ${event.year}, ${event.month}');
    bool changed = false;
    if (event.year != null && event.month != null) {
      budgetRepository.setSelectedYear = event.year!;
      budgetRepository.setSelectedMonth = event.month!;
      changed = true;
    }
    if (budgetRepository.getBudgetList.isEmpty || changed) {
      await budgetRepository.fetchBudget(
          year: budgetRepository.getSelectedYear,
          month: budgetRepository.getSelectedMonth);
    }
    List<BudgetModel> budgetList = budgetRepository.getBudgetList;
    // filter the budget list by selected year and month
    if (budgetRepository.getSelectedMonth == 0) {
      print('Filtering by year');
      budgetList = budgetList
          .where(
              (element) => element.dateYear == budgetRepository.getSelectedYear)
          .toList();
    } else {
      budgetList = budgetList
          .where((element) =>
              element.dateYear == budgetRepository.getSelectedYear &&
              element.dateMonth == budgetRepository.getSelectedMonth)
          .toList();
    }

    budgetList.sort((a, b) => b.dateYear.compareTo(a.dateYear) == 0
        ? b.dateMonth.compareTo(a.dateMonth) == 0
            ? b.dateDay.compareTo(a.dateDay)
            : b.dateMonth.compareTo(a.dateMonth)
        : b.dateYear.compareTo(a.dateYear));
    emit(BudgetHomeLoaded(
        budgetList: budgetList,
        selectedYear: budgetRepository.getSelectedYear,
        selectedMonth: budgetRepository.getSelectedMonth,
        bottomSheetIndex: 0));
  }

  Future<FutureOr<void>> _onShowBudgetSummary(
      ShowBudgetSummary event, Emitter<BudgetHomeState> emit) async {
    emit(BudgetHomeLoading());
    String? networkResponse = await budgetRepository.budgetProvider
        .getBudgets(year: event.year, month: 0);
    // print(networkResponse);
    if (networkResponse == null) {
      emit(BudgetSummaryError());
    } else {
      List<BudgetModel> budgetList = [];
      jsonDecode(networkResponse).forEach((element) {
        BudgetModel budgetModel = BudgetModel.fromJson(element);
        budgetList.add(budgetModel);
      });
      emit(BudgetSummaryLoaded(
          budgetList: budgetList,
          selectedYear: event.year,
          bottomSheetIndex: 1));
    }
  }

  Future<FutureOr<void>> _onCreateNewBudgetEntry(
      CreateNewBudgetEntry event, Emitter<BudgetHomeState> emit) async {
    emit(BudgetHomeLoading());
    await budgetRepository.addBudgetEntry(event.budgetModel);
    List<BudgetModel> budgetList = budgetRepository.getBudgetList;
// filter the budget list by selected year and month
    if (budgetRepository.getSelectedMonth == 0) {
      budgetList = budgetList
          .where(
              (element) => element.dateYear == budgetRepository.getSelectedYear)
          .toList();
    } else {
      budgetList = budgetList
          .where((element) =>
              element.dateYear == budgetRepository.getSelectedYear &&
              element.dateMonth == budgetRepository.getSelectedMonth)
          .toList();
    }
    // sort the budget list by date, descending => budget dates are the date, month, year of the budget, 3 integers => dateDay, dateMonth, dateYear
    budgetList.sort((a, b) => b.dateYear.compareTo(a.dateYear) == 0
        ? b.dateMonth.compareTo(a.dateMonth) == 0
            ? b.dateDay.compareTo(a.dateDay)
            : b.dateMonth.compareTo(a.dateMonth)
        : b.dateYear.compareTo(a.dateYear));

    emit(BudgetHomeLoaded(
        budgetList: budgetList,
        selectedYear: budgetRepository.getSelectedYear,
        selectedMonth: budgetRepository.getSelectedMonth,
        bottomSheetIndex: 0));
  }

  Future<FutureOr<void>> _onUpdateBudgetEntry(
      UpdateBudgetEntry event, Emitter<BudgetHomeState> emit) async {
    emit(BudgetHomeLoading());
    await budgetRepository.updateBudgetEntry(event.budgetModel);
    List<BudgetModel> budgetList = budgetRepository.getBudgetList;
// filter the budget list by selected year and month
    if (budgetRepository.getSelectedMonth == 0) {
      budgetList = budgetList
          .where(
              (element) => element.dateYear == budgetRepository.getSelectedYear)
          .toList();
    } else {
      budgetList = budgetList
          .where((element) =>
              element.dateYear == budgetRepository.getSelectedYear &&
              element.dateMonth == budgetRepository.getSelectedMonth)
          .toList();
    }

    budgetList.sort((a, b) => b.dateYear.compareTo(a.dateYear) == 0
        ? b.dateMonth.compareTo(a.dateMonth) == 0
            ? b.dateDay.compareTo(a.dateDay)
            : b.dateMonth.compareTo(a.dateMonth)
        : b.dateYear.compareTo(a.dateYear));
    emit(BudgetHomeLoaded(
        budgetList: budgetList,
        selectedYear: budgetRepository.getSelectedYear,
        selectedMonth: budgetRepository.getSelectedMonth,
        bottomSheetIndex: 0));
  }

  Future<FutureOr<void>> _onDeleteBudgetEntry(
      DeleteBudgetEntry event, Emitter<BudgetHomeState> emit) async {
    emit(BudgetHomeLoading());
    await budgetRepository.deleteBudgetEntry(event.budgetModel);
    List<BudgetModel> budgetList = budgetRepository.getBudgetList;
    budgetList.sort((a, b) => b.dateYear.compareTo(a.dateYear) == 0
        ? b.dateMonth.compareTo(a.dateMonth) == 0
            ? b.dateDay.compareTo(a.dateDay)
            : b.dateMonth.compareTo(a.dateMonth)
        : b.dateYear.compareTo(a.dateYear));
    emit(BudgetHomeLoaded(
        budgetList: budgetList,
        selectedYear: budgetRepository.getSelectedYear,
        selectedMonth: budgetRepository.getSelectedMonth,
        bottomSheetIndex: 0));
  }

  FutureOr<void> _onBudgetInternetConnected(
      BudgetInternetConnected event, Emitter<BudgetHomeState> emit) {
    budgetRepository.syncBudgets().then((value) {
      if (value) {
        eventBus.fire(BudgetUpdatedEvent());
      }
    });
  }

  FutureOr<void> _onBudgetQuery(
      BudgetQuery event, Emitter<BudgetHomeState> emit) {
    List<BudgetModel> budgetList = budgetRepository.getBudgetList;
    // filter the budget list by selected year and month
    if (budgetRepository.getSelectedMonth == 0) {
      budgetList = budgetList
          .where(
              (element) => element.dateYear == budgetRepository.getSelectedYear)
          .toList();
    } else {
      budgetList = budgetList
          .where((element) =>
              element.dateYear == budgetRepository.getSelectedYear &&
              element.dateMonth == budgetRepository.getSelectedMonth)
          .toList();
    }
    List<BudgetModel> filteredBudgetList = budgetList
        .where((element) => element.entryTitle
            .toLowerCase()
            .contains(event.query.toLowerCase()))
        .toList();
    emit(BudgetHomeLoaded(
        budgetList: filteredBudgetList,
        selectedYear: budgetRepository.getSelectedYear,
        selectedMonth: budgetRepository.getSelectedMonth,
        bottomSheetIndex: 0));
  }
}
