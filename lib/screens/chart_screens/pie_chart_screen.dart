import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../add_edit_screen.dart';

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
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChartInfo(context),
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
                            touchCallback: (event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse?.touchedSection == null) {
                                  touchedIndex = null;
                                } else {
                                  touchedIndex =
                                      pieTouchResponse!
                                          .touchedSection!
                                          .touchedSectionIndex;
                                }
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 60,
                          sections:
                              chartData.map((data) {
                                final isTouched = touchedIndex == data.index;
                                final double radius = isTouched ? 32 : 24;
                                return PieChartSectionData(
                                  color:
                                      categoryColors[data.index %
                                          categoryColors.length],
                                  value: data.amount,
                                  title:
                                      data.percentage > 0.1
                                          ? '${(data.percentage * 100).toStringAsFixed(0)}%'
                                          : '',
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
                    if (touchedIndex != null)
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

    for (final expense in expenses) {
      categoryMap.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
      total += expense.amount;
    }

    return categoryMap.entries.toList().asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return CategoryData(
          index,
          category.key,
          category.value,
          total > 0 ? category.value / total : 0,
        );
      }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
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
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEditScreen()),
                ),
            child: const Text('Add your first expense'),
          ),
        ],
      ),
    );
  }

  void _showChartInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chart Information'),
            content: const Text(
              'This pie chart shows your spending distribution across categories.\n\n'
              '• Tap sections to see details\n'
              '• Colors represent different categories\n'
              '• Larger slices indicate higher spending',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
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
