import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/eventbus_events.dart';
import 'package:selfsync_frontend/feature/budget/cubit/add_budget_cubit.dart';
import 'package:selfsync_frontend/feature/budget/model/budget_model.dart';
import 'package:selfsync_frontend/feature/budget/ui/budget_summary_view.dart';
import 'package:selfsync_frontend/feature/budget/ui/budget_list_view.dart';
import 'package:selfsync_frontend/main.dart';

import '../bloc/budget_home_bloc.dart';

class BudgetHome extends StatefulWidget {
  const BudgetHome({super.key});

  @override
  State<BudgetHome> createState() => _BudgetHomeState();
}

class _BudgetHomeState extends State<BudgetHome> {
  late TextEditingController entryTitleController;
  late TextEditingController amountController;
  late StreamSubscription _budgetUpdateSubscription;
  late StreamSubscription _internetConnectionSubscription;
  BudgetHomeState currentState = BudgetHomeLoading();
  int prevYear = DateTime.now().year;
  int prevMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    context.read<BudgetHomeBloc>().add(ShowBudgetHome(null, null));
    entryTitleController = TextEditingController();
    amountController = TextEditingController();
    _budgetUpdateSubscription = eventBus.on<BudgetUpdatedEvent>().listen((event) { 
      if (mounted && currentState is BudgetHomeLoaded) {
        context.read<BudgetHomeBloc>().add(ShowBudgetHome(null, null));
      }
    });

    _internetConnectionSubscription = eventBus.on<InternetConnectedEvent>().listen((event) {
      if (mounted) {
        context.read<BudgetHomeBloc>().add(BudgetInternetConnected());
      }
    });
  }

  @override
  void dispose() {
    entryTitleController.dispose();
    amountController.dispose();
    _budgetUpdateSubscription.cancel();
    _internetConnectionSubscription.cancel();
    super.dispose();
  }

  void onBudgetClicked(BudgetModel budget) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(budget.entryTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Amount: \$${budget.amount}',
                  style: const TextStyle(fontSize: 20)),
              Text(
                  'Date: ${monthToName(budget.dateMonth)} ${budget.dateDay}, ${budget.dateYear}',
                  style: const TextStyle(fontSize: 20)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void onBudgetDeleted(BudgetModel budget) {
    // show dialog to confirm delete
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop('delete');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value == 'delete') {
        if (budget.isLocal) {
          // cannot delete local entry
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cannot delete local entry!'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          context.read<BudgetHomeBloc>().add(DeleteBudgetEntry(budget));
        }
      }
    });
  }

  void onBudgetUpdated(BudgetModel budget) {
    addOrEditBudget(context, budget).then((model) {
      if (model != null) {
        context.read<BudgetHomeBloc>().add(UpdateBudgetEntry(model));
      }
    });
  }

  void onTimeFrameChanged(int year, int month) {
    context.read<BudgetHomeBloc>().add(ShowBudgetHome( year, month));
  }

  void onBudgetQuery(String query) {
    context.read<BudgetHomeBloc>().add(BudgetQuery(query));
  }

  void onSummaryYearChanged(int year) {
    context.read<BudgetHomeBloc>().add(ShowBudgetSummary(year));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetHomeBloc, BudgetHomeState>(
      builder: (context, state) {
        currentState = state;
        if (state is BudgetHomeLoaded || state is BudgetSummaryLoaded || state is BudgetSummaryError || state is BudgetHomeError) {
          int selectedYear = state is BudgetHomeLoaded
              ? state.selectedYear
              : state is BudgetSummaryLoaded
                  ? state.selectedYear
                  : prevYear;
          prevYear = selectedYear;
          int bottomSheetIndex = state is BudgetHomeLoaded
              ? state.bottomSheetIndex
              : state is BudgetSummaryLoaded
                  ? state.bottomSheetIndex
                  : state is BudgetSummaryError
                      ? 1
                      : state is BudgetHomeError
                          ? 0
                          : 0;
          int selectedMonth = state is BudgetHomeLoaded ? state.selectedMonth : prevMonth;
          prevMonth = selectedMonth;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Personal Finance', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
              centerTitle: true,
              actions: [
                if (state is BudgetHomeLoaded)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<BudgetHomeBloc>().add(ShowBudgetHome(prevYear, prevMonth));
                  },
                ),
              ],
            ),
            body: state is BudgetHomeLoaded
                ? BudgetListView(
                    selectedYear: state.selectedYear,
                    selectedMonth: state.selectedMonth,
                    budgetList: state.budgetList,
                    onBudgetDeleted: onBudgetDeleted,
                    onBudgetUpdated: onBudgetUpdated,
                    onTimeFrameChanged: onTimeFrameChanged,
                    onBudgetQuery: onBudgetQuery,
                    onBudgetClicked: onBudgetClicked,
                  )
                : state is BudgetSummaryLoaded
                    ? BudgetSummaryView(
                        onSummaryYearChanged: onSummaryYearChanged,
                        budgetList: state.budgetList,
                        selectedYear: state.selectedYear,
                    )
                    : state is BudgetSummaryError || state is BudgetHomeError
                        ? const Center(child: Text('Error loading data'))
                        : const Center(child: Text('No data')),
            bottomNavigationBar: BottomNavigationBar(
              iconSize: 26,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.balance),
                  label: 'Finance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_outlined),
                  label: 'Summary',
                ),
              ],
              currentIndex: bottomSheetIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (index) {
                if (index == 0) {
                  context.read<BudgetHomeBloc>().add(ShowBudgetHome(null, null));
                } else {
                  context.read<BudgetHomeBloc>().add(ShowBudgetSummary(selectedYear));
                }
              },
            ),
            floatingActionButton: bottomSheetIndex == 1? null: FloatingActionButton(
              heroTag: 'AddNewEntry',
              onPressed: () {
                BudgetModel ee = BudgetModel.empty();
                addOrEditBudget(context, ee).then((value) {
                  if (value != null) {
                    context.read<BudgetHomeBloc>().add(CreateNewBudgetEntry(value));
                  }
                });
              },
              child: const Icon(Icons.add, size: 30),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Please Wait...', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'SpaceGrotesk')),
            centerTitle: true,
          ),
          body: Center(
            child: LoadingAnimationWidget.halfTriangleDot(color: Colors.amber[800]!, size: 50),
          ),
        );
      },
    );
  }

  Future<BudgetModel?> addOrEditBudget(
      BuildContext context, BudgetModel model) async {
    entryTitleController.text = model.entryTitle;
    amountController.text = model.amount.toString();
    final cubitController = AddBudgetCubit();
    cubitController.refreshUI(model);

    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (context) => cubitController,
          child: AlertDialog(
            title: const Center(child: Text('Add New Entry')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: entryTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Entry Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.isNotEmpty) double.parse(text);
                        return newValue;
                      } catch (e) {
                        return oldValue;
                      }
                    }),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount (\$)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("Date: "),
                    const SizedBox(width: 10),
                    TextButton.icon(
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime(2100),
                                  initialDate: DateTime.now())
                              .then((value) {
                            if (value != null) {
                              model = model.copyWith(
                                dateDay: value.day,
                                dateMonth: value.month,
                                dateYear: value.year,
                              );
                              cubitController.refreshUI(model);
                            }
                          });
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: BlocBuilder<AddBudgetCubit, AddBudgetState>(
                          builder: (context, state) {
                            if (state is AddBudgetLoaded) {
                              final dateString =
                                  '${monthToName(state.budget.dateMonth)} ${state.budget.dateDay}, ${state.budget.dateYear}';
                              return Text(dateString);
                            }
                            return const Text('');
                          },
                        )),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (entryTitleController.text.isEmpty ||
                      amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Title and Amount cannot be empty!'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        showCloseIcon: true,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                  Navigator.of(context).pop(model.copyWith(
                    entryTitle: entryTitleController.text,
                    amount: double.parse(amountController.text),
                  ));
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
