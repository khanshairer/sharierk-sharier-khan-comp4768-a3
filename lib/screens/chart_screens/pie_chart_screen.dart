import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

class PieChartScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends ConsumerState<PieChartScreen> {
  static const List<Color> categoryColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
  ];

  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expenseProvider).expenses;
    final chartData = _processByCategory(expenses);
    final totalAmount = _getTotalAmount(chartData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending by Category'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Expense',
              onPressed: () => context.push('/add'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.insert_chart),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'Back to Charts',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(expenseProvider),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body:
          expenses.isEmpty
              ? _buildEmptyState(context)
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildTotalSpending(totalAmount),
                    const SizedBox(height: 20),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            enabled: true,
                            touchCallback: (
                              FlTouchEvent event,
                              PieTouchResponse? pieTouchResponse,
                            ) {
                              setState(() {
                                final touchedSection =
                                    pieTouchResponse?.touchedSection;
                                if (touchedSection == null ||
                                    touchedSection.touchedSectionIndex < 0 ||
                                    touchedSection.touchedSectionIndex >=
                                        chartData.length) {
                                  touchedIndex = null;
                                  return;
                                }
                                touchedIndex =
                                    touchedSection.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 50,
                          sections:
                              chartData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final data = entry.value;
                                final isTouched = touchedIndex == index;
                                final double radius = isTouched ? 30 : 25;

                                // Only show percentage if it's greater than 5%
                                final showPercentage = data.percentage > 0.05;
                                final percentageText =
                                    showPercentage
                                        ? '${(data.percentage * 100).toStringAsFixed(data.percentage > 0.1 ? 0 : 1)}%'
                                        : '';

                                return PieChartSectionData(
                                  color:
                                      categoryColors[index %
                                          categoryColors.length],
                                  value: data.amount,
                                  title: percentageText,
                                  radius: radius,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    if (touchedIndex != null &&
                        touchedIndex! >= 0 &&
                        touchedIndex! < chartData.length)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '${chartData[touchedIndex!].category}: \$${chartData[touchedIndex!].amount.toStringAsFixed(2)} (${(chartData[touchedIndex!].percentage * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    _buildLegend(chartData),
                  ],
                ),
              ),
    );
  }

  List<CategoryData> _processByCategory(List<Expense> expenses) {
    final categoryMap = <String, double>{};
    double total = 0;

    // Process all expenses
    for (final expense in expenses) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      total += expense.amount;
    }

    // Convert to sorted list with consistent indices
    final sortedEntries =
        categoryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      return CategoryData(
        index,
        category.key,
        category.value,
        total > 0 ? category.value / total : 0,
      );
    }).toList();
  }

  double _getTotalAmount(List<CategoryData> data) {
    return data.fold(0, (sum, item) => sum + item.amount);
  }

  Widget _buildTotalSpending(double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_money, size: 24),
            const SizedBox(width: 8),
            Text(
              'Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<CategoryData> data) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children:
          data.map((item) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColors[item.index % categoryColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(item.category, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '\$${item.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 50,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            'No expense data available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => context.push('/add'),
            child: const Text('Add your first expense'),
          ),
        ],
      ),
    );
  }
}

class CategoryData {
  final int index;
  final String category;
  final double amount;
  final double percentage;

  CategoryData(this.index, this.category, this.amount, this.percentage);
}
// This class is used to hold the processed data for each category in the pie chart.