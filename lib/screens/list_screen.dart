import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All The Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromARGB(255, 226, 180, 43),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.go('/add'),
            tooltip: 'Add Expense',
          ),
          IconButton(
            icon: const Icon(
              Icons.insert_chart,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'View Charts',
          ),
          IconButton(
            icon: const Icon(
              Icons.file_download,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => _exportToExcel(state.expenses, context),
            tooltip: 'Export to Excel',
          ),
        ],
        centerTitle: true,
        leading: Icon(
          Icons.money,
          color: Color.fromARGB(255, 226, 180, 43),
          size: 30,
        ),

        backgroundColor: Colors.blue[900],
      ),
      body: _buildBody(state, context, ref),
    );
  }

  Widget _buildBody(ExpenseState state, BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error!}'));
    }

    if (state.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.money_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No expenses yet.\nTap + to add your first expense!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Add Expense',
                style: TextStyle(
                  color: Color.fromARGB(255, 226, 180, 43),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
      child: ListView.builder(
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          final expense = state.expenses[index];
          final categoryColors = {
            'Food': Colors.green[100],
            'Transport': Colors.blue[100],
            'Entertainment': Colors.purple[100],
            'Utilities': Colors.orange[100],
            'Other': Colors.grey[100],
          };

          return Dismissible(
            key: Key(expense.hiveKey.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss:
                (_) => _confirmDelete(context, expense.hiveKey, ref),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.amber[400]!, width: 2),
              ),
              color: categoryColors[expense.category] ?? Colors.grey[100],
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  expense.description,
                  style: const TextStyle(
                    color: Color.fromARGB(
                      255,
                      14,
                      77,
                      172,
                    ), // Text color for the title
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  '\$${expense.amount.toStringAsFixed(2)} • ${expense.category}',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 231, 28, 28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM dd').format(expense.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 231, 28, 28),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      _getCategoryIcon(expense.category),
                      color: const Color.fromARGB(255, 231, 28, 28),
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {
                  if (expense.hiveKey != null) {
                    context.go('/edit/${expense.hiveKey}');
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Utilities':
        return Icons.bolt;
      default:
        return Icons.category;
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    int? hiveKey,
    WidgetRef ref,
  ) async {
    if (hiveKey == null) return false;

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Expense'),
                content: const Text(
                  'Are you sure you want to delete this expense?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(expenseProvider.notifier).deleteExpense(hiveKey);
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
        ) ??
        false;
  }

  Future<void> _exportToExcel(
    List<Expense> expenses,
    BuildContext context,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Expenses'];

      // Set column widths
      sheet.setColWidth(0, 30);
      sheet.setColWidth(1, 15);
      sheet.setColWidth(2, 20);
      sheet.setColWidth(3, 15);

      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: "FFD700",
        fontColorHex: "000000",
        horizontalAlign: HorizontalAlign.Center,
      );

      sheet.appendRow(['Description', 'Amount (\$)', 'Category', 'Date']);

      for (var i = 0; i < 4; i++) {
        sheet
            .cell(CellIndex.indexByString('${String.fromCharCode(65 + i)}1'))
            .cellStyle = headerStyle;
      }

      for (final expense in expenses) {
        sheet.appendRow([
          expense.description,
          expense.amount.toStringAsFixed(2),
          expense.category,
          DateFormat('yyyy-MM-dd').format(expense.date),
        ]);
      }

      final fileBytes = excel.save();
      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate Excel file')),
        );
        return;
      }

      final fileName =
          'Expense_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        // ✅ Web: Use AnchorElement to download
        final blob = html.Blob([fileBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", fileName)
              ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('File downloaded: $fileName')));
      } else {
        // ✅ Mobile/Desktop: Save and open
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to $fileName'),
              action: SnackBarAction(
                label: 'OPEN',
                textColor: Colors.amber,
                onPressed: () async {
                  try {
                    await OpenFile.open(filePath);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cannot open file: $e')),
                    );
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Excel export error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
