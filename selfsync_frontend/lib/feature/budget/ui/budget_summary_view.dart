import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:selfsync_frontend/common/common_functions.dart';
import 'package:selfsync_frontend/feature/budget/model/budget_model.dart';

class BudgetSummaryView extends StatelessWidget {
  final void Function(int year) onSummaryYearChanged;
  final List<BudgetModel> budgetList;
  final int selectedYear;
  const BudgetSummaryView(
      {super.key,
      required this.onSummaryYearChanged,
      required this.budgetList,
      required this.selectedYear});

  @override
  Widget build(BuildContext context) {
    print('BudgetSummaryView: $selectedYear');
    print('BudgetSummaryView: ${budgetList.length}');

    // create summary by month
    final summaryByMonth = <int, double>{};
    for (int i = 1; i <= 12; i++) {
      summaryByMonth[i] = 0;
    }

    // calculate summary by month, don't compare year, as all years are same
    for (final budget in budgetList) {
      if (!summaryByMonth.keys.contains(budget.dateMonth)) {
        summaryByMonth[budget.dateMonth] = 0;
      }
      summaryByMonth[budget.dateMonth] =
          summaryByMonth[budget.dateMonth]! + budget.amount;
    }
    // average monthly cost
    final averageMonthlyCost = summaryByMonth.values.reduce((a, b) => a + b) /
        summaryByMonth.values.length;
    
    final maxAmount = 100+summaryByMonth.values.reduce((a, b) => a > b ? a : b);
    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= 12; i++) {
      barGroups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(

          width: 20,
          toY: summaryByMonth[i]!,
          fromY: 0,
          gradient: _barsGradient,
        )
      ],
      showingTooltipIndicators: [0]
      )
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
            onPressed: () {
              var selectedDate = DateTime(selectedYear);
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
                onSummaryYearChanged(year);
              });
            },
            child: Text('Year: $selectedYear',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue))),
        Text('Average monthly cost: \$${averageMonthlyCost.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        // show a bar chart


        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BarChart(
                  BarChartData(
                    barTouchData: barTouchData,
                    titlesData: titlesData,
                    borderData: borderData,
                    barGroups: barGroups,
                    gridData: const FlGridData(show: false),
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxAmount,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.cyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color.fromARGB(255, 0, 48, 73),
      fontWeight: FontWeight.bold,
      fontSize: 18,
      fontFamily: 'Raleway',
    );
    String text = '';
    text = monthToName(value.toInt());
    text = text.substring(0, 3);
    return SideTitleWidget(
      angle: 0.523599,
      axisSide: AxisSide.top,
      space: 5,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,

      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Colors.blue,
          Colors.green
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
  
}
