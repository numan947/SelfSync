import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/common/ui/custom_search_bar.dart';

class BudgetListView extends StatelessWidget {
  final int selectedYear;
  final int selectedMonth;
  final List budgetList;
  final Function onBudgetDeleted;
  final Function onBudgetUpdated;
  final Function onTimeFrameChanged;
  final Function onBudgetQuery;
  final Function onBudgetClicked;

  const BudgetListView(
      {super.key,
      required this.selectedYear,
      required this.selectedMonth,
      required this.budgetList,
      required this.onBudgetDeleted,
      required this.onBudgetUpdated,
      required this.onTimeFrameChanged,
      required this.onBudgetQuery,
      required this.onBudgetClicked
      });

  @override
  Widget build(BuildContext context) {
    // calculate the total budget
    double totalBudget = 0;
    for (int i = 0; i < budgetList.length; i++) {
      totalBudget += budgetList[i].amount;
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          CustomSearchBar(onQuery: (query) {
            onBudgetQuery(query);
          }),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () {
                    var selectedDate = DateTime(selectedYear, selectedMonth);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(child: Text("Select Year")),
                          content: SizedBox(
                            // Need to use container to add size constraint.
                            width: 300,
                            height: 300,
                            child: YearPicker(
                              firstDate: DateTime(DateTime.now().year - 100, 1),
                              lastDate: DateTime(DateTime.now().year + 100, 1),
                              currentDate: selectedDate,
                              selectedDate: selectedDate,
                              onChanged: (DateTime dateTime) {
                                Navigator.pop(context, dateTime.year);
                              },
                            ),
                          ),
                        );
                      },
                    ).then((year) {
                      if (year == null) {
                        return;
                      }
                      onTimeFrameChanged(year, selectedMonth);
                    });
                  },
                  child: Text('Year: $selectedYear',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black))),
              DropdownButton<int>(
                elevation: 5,
                focusColor: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                alignment: Alignment.center,
                hint: const Text('Select Month'),
                icon: const Icon(Icons.calendar_month_outlined),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                value: selectedMonth,
                items: List.generate(13, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(monthToName(index)),
                  );
                }),
                onChanged: (int? value) {
                  //remove focus
                  FocusScope.of(context).unfocus();
                  if (value == null) {
                    return;
                  }
                  onTimeFrameChanged(selectedYear, value);
                },
              )
            ],
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final budgetDate = DateFormat('yyyy-MM-dd').format(
                    DateTime(budgetList[index].dateYear,
                        budgetList[index].dateMonth, budgetList[index].dateDay));
                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.indigoAccent,
                  margin: const EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  surfaceTintColor: Colors.indigoAccent,
                  child: ListTile(
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(budgetList[index].entryTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.
                          bold, color: Colors.black)),
                        ),
                        const SizedBox(width: 10),
                        if (budgetList[index].isLocal)
                          const Icon(Icons.cloud_off, color: Colors.redAccent),
                        if (!budgetList[index].isLocal)
                          const Icon(Icons.cloud_done, color: Colors.green),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Amount: \$${budgetList[index].amount.toStringAsFixed(2)}'),
                        const SizedBox(width: 10),
                        Text('Date: $budgetDate'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () {
                              onBudgetUpdated(budgetList[index]);
                            }),
                        IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {
                              onBudgetDeleted(budgetList[index]);
                            }),
                      ],
                    ),
                    onTap: () => onBudgetClicked(budgetList[index]),
                    onLongPress: () {
                      onBudgetDeleted(budgetList[index]);
                    },
                  ),
                );
              },
              itemCount: budgetList.length,
              shrinkWrap: true),
          //TOTAL
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text('Total: \$${totalBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
