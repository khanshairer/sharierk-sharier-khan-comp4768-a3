import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';

/// Represents the state of the expense list with loading and error indicators.
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  ExpenseState({this.expenses = const [], this.isLoading = false, this.error});

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Manages state and business logic for the list of expenses.
class ExpenseProvider extends StateNotifier<ExpenseState> {
  final Box<Expense> box;

  ExpenseProvider(this.box) : super(ExpenseState()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      final expenses = box.values.toList();
      state = state.copyWith(expenses: expenses, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load expenses: ${e.toString()}',
      );
      if (kDebugMode) print(e);
    }
  }

  Future<void> addExpense(Expense expense) async {
    state = state.copyWith(isLoading: true);
    try {
      final key = await box.add(expense); // Get auto-generated key
      final newExpense = expense.copyWith(hiveKey: key); // Update with key
      await box.put(key, newExpense); // Store with key
      state = state.copyWith(expenses: box.values.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add expense: ${e.toString()}',
      );
      if (kDebugMode) print(e);
    }
  }

  Future<void> updateExpense(int key, Expense expense) async {
    state = state.copyWith(isLoading: true);
    try {
      final updatedExpense = expense.copyWith(
        hiveKey: key,
      ); // Ensure key is preserved
      await box.put(key, updatedExpense);
      state = state.copyWith(expenses: box.values.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update expense: ${e.toString()}',
      );
      if (kDebugMode) print(e);
    }
  }

  Future<void> deleteExpense(int key) async {
    state = state.copyWith(isLoading: true);
    try {
      await box.delete(key);
      state = state.copyWith(expenses: box.values.toList(), isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete expense: ${e.toString()}',
      );
      if (kDebugMode) print(e);
    }
  }

  Future<void> clearAllExpenses() async {
    state = state.copyWith(isLoading: true);
    try {
      await box.clear();
      state = state.copyWith(expenses: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear expenses: ${e.toString()}',
      );
      if (kDebugMode) print(e);
    }
  }
}

/// Provides the Hive box for storing `Expense` items
final expenseBoxProvider = FutureProvider<Box<Expense>>((ref) async {
  await Hive.openBox<Expense>('expenses');
  return Hive.box<Expense>('expenses');
});

/// Provides the state management for expenses using a `StateNotifierProvider`
final expenseProvider = StateNotifierProvider<ExpenseProvider, ExpenseState>((
  ref,
) {
  final box = ref
      .watch(expenseBoxProvider)
      .maybeWhen(
        data: (b) => b,
        orElse: () => throw Exception('Hive box not yet loaded'),
      );
  return ExpenseProvider(box);
});
