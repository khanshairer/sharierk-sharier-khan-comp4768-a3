import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/add'),
          ),
          IconButton(
            icon: const Icon(Icons.insert_chart),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'View Charts',
          ),
        ],
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
      return const Center(
        child: Text(
          'No expenses yet.\nTap + to add your first expense!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(expenseProvider.notifier).loadExpenses(),
      child: ListView.builder(
        itemCount: state.expenses.length,
        itemBuilder: (context, index) {
          final expense = state.expenses[index];
          return Dismissible(
            key: Key(expense.hiveKey.toString()),
            background: Container(color: Colors.red),
            confirmDismiss:
                (_) => _confirmDelete(context, expense.hiveKey, ref),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(expense.description),
                subtitle: Text(
                  '\$${expense.amount.toStringAsFixed(2)} • ${expense.category}',
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  DateFormat('MMM dd').format(expense.date),
                  style: const TextStyle(fontSize: 14),
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
              ),
        ) ??
        false;
  }
}
