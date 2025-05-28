// lib/providers/expense_provider.dart
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<Expense> _expenseBox;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  ExpenseProvider(this._expenseBox) {
    _loadExpenses();
  }

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadExpenses() async {
    try {
      _isLoading = true;
      notifyListeners();

      _expenses = _expenseBox.values.toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load expenses';
      if (kDebugMode) print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseBox.add(expense);
      _expenses = _expenseBox.values.toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add expense';
      notifyListeners();
    }
  }

  Future<void> updateExpense(int key, Expense expense) async {
    try {
      await _expenseBox.put(key, expense);
      _expenses = _expenseBox.values.toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update expense';
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int key) async {
    try {
      await _expenseBox.delete(key);
      _expenses = _expenseBox.values.toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete expense';
      notifyListeners();
    }
  }
}
