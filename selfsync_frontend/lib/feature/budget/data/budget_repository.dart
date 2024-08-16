import 'dart:convert';

import 'package:selfsync_frontend/common/my_custom_cache.dart';
import 'package:selfsync_frontend/feature/budget/data/budget_provider.dart';
import 'package:selfsync_frontend/feature/budget/model/budget_model.dart';
import 'package:selfsync_frontend/main.dart';

import '../../../common/eventbus_events.dart';

class BudgetRepository {
  MyCustomCache budgetCache = MyCustomCache(
    cacheKey: 'all_budgets',
    cacheDuration: 5 * 365 * 24 * 60, // 5 hours -- basically never expires
    dirPrefix: 'budgets',
  );

  final MyCustomCache deletedBudgetsCache = MyCustomCache(
    cacheKey: 'deleted_budgets',
    cacheDuration: 5 * 365 * 24 * 60, // 5 years -- basically never expires
    dirPrefix: 'budgets',
  );

  int selectedYear;
  int selectedMonth;
  final BudgetProvider budgetProvider;
  BudgetRepository(
      {required this.budgetProvider,
      required this.selectedYear,
      required this.selectedMonth});

  List<BudgetModel> budgetList = [];
  //getter for the budget list
  List<BudgetModel> get getBudgetList => budgetList;
  //getter for the selected year
  int get getSelectedYear => selectedYear;
  //getter for the selected month
  int get getSelectedMonth => selectedMonth;

  set setSelectedMonth(m) {
    selectedMonth = m;
  }

  set setSelectedYear(y) {
    selectedYear = y;
  }

  Future<bool> syncBudgets() async {
    await budgetCache.invalidateCacheIfFileDoesNotExist();
    await deletedBudgetsCache.invalidateCacheIfFileDoesNotExist();
    bool changed = false;
    bool cacheValid = await budgetCache.isCacheValid();
    if (cacheValid) {
      String? cacheData = await budgetCache.readCache();
      if (cacheData != null) {
        try {
          List<BudgetModel> cachedBudgets = (jsonDecode(cacheData) as List)
              .map((e) => BudgetModel.fromJson(e))
              .toList();
          budgetList = cachedBudgets;
        } catch (e) {
          print("Error Syncing Budgets: $e");
          await budgetCache.invalidateCache();
        }
      }
    }

    if (budgetList.isNotEmpty) {
      List<BudgetModel> tmpBudgetList = List.from(budgetList);
      for (BudgetModel budget in tmpBudgetList) {
        if (budget.isLocal) {
          bool success = await budgetProvider.syncBudget(budget);
          if (success) {
            budget.isLocal = false;
            changed = true;
          }
        }
      }
      budgetList = tmpBudgetList;
      // Save todos to the cache
      await budgetCache.writeCache(jsonEncode(budgetList));
    }
    syncDeletedBudgets();
    return changed;
  }

  Future<void> syncDeletedBudgets() async {
    List<String> failedDeletes = [];
    List<String> deletedBudgetIds = [];
    await deletedBudgetsCache.invalidateCacheIfFileDoesNotExist();
    bool cacheValid = await deletedBudgetsCache.isCacheValid();
    if (cacheValid) {
      String? cacheData = await deletedBudgetsCache.readCache();
      if (cacheData != null) {
        try {
          deletedBudgetIds =
              (jsonDecode(cacheData) as List).map((e) => e.toString()).toList();
        } catch (e) {
          print("Error Syncing Deleted Budgets: $e");
          await deletedBudgetsCache.invalidateCache(); // cache is invalid
        }

        for (String id in deletedBudgetIds) {
          bool success = await budgetProvider.deleteBudget(id);
          if (!success) {
            failedDeletes.add(id);
          }
        }
      }
    }
    await deletedBudgetsCache.writeCache(jsonEncode(failedDeletes));
  }

  Future<List<BudgetModel>> fetchBudget({int? year, int? month}) async {
    await syncDeletedBudgets();
    await syncBudgets();
    if (year != null) {
      selectedYear = year;
    }
    if (month != null) {
      selectedMonth = month;
    }

    String? networkResponse = await budgetProvider.getBudgets(
        year: selectedYear, month: selectedMonth);
    List<BudgetModel> serverBudgets = [];
    if (networkResponse != null) {
      serverBudgets = (jsonDecode(networkResponse) as List)
          .map((e) => BudgetModel.fromJson(e))
          .toList();
      // Save todos to the cache
      await budgetCache.writeCache(jsonEncode(serverBudgets));
      budgetList = serverBudgets;
    }
    return budgetList;
  }

  Future<void> addBudgetEntry(BudgetModel budget) async {
    budget.isLocal = true;
    budgetList.add(budget);
    await budgetCache.writeCache(jsonEncode(budgetList));
    syncBudgets().then((value) => {
          if (value)
            {
              eventBus.fire(BudgetUpdatedEvent()),
              print("Budget Updated Event Fired")
            }
        });
  }

  Future<void> updateBudgetEntry(BudgetModel budget) async {
    int index = budgetList.indexWhere((element) => element.id == budget.id);
    if (index != -1) {
      budget.isLocal = true;
      budgetList[index] = budget;
      await budgetCache.writeCache(jsonEncode(budgetList));
      syncBudgets().then((value) => {
            if (value)
              {
                eventBus.fire(BudgetUpdatedEvent()),
                print("Budget Updated Event Fired")
              }
          });
    }
  }

  Future<void> deleteBudgetEntry(BudgetModel budget) async {
    budgetList.removeWhere((element) => element.id == budget.id);
    await budgetCache.writeCache(jsonEncode(budgetList));
    // Save the deleted todo to the cache
    //read the deleted todos from the cache
    List<String> deletedBudgetIds = [];
    String? deletedBudgetIdsJson = await deletedBudgetsCache.readCache();
    if (deletedBudgetIdsJson != null && deletedBudgetIdsJson.isNotEmpty) {
      deletedBudgetIds = (jsonDecode(deletedBudgetIdsJson) as List)
          .map((e) => e.toString())
          .toList();
    }
    deletedBudgetIds.add(budget.id);
    await deletedBudgetsCache.writeCache(jsonEncode(deletedBudgetIds));
    syncDeletedBudgets();
  }
}
