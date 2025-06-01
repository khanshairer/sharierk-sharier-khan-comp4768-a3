import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import 'package:go_router/go_router.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddEditScreen({this.expenseId, super.key});

  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final expense =
        widget.expenseId != null
            ? ref
                .read(expenseProvider)
                .expenses
                .firstWhere((e) => e.hiveKey.toString() == widget.expenseId)
            : null;

    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );
    _dateController = TextEditingController(
      text: DateFormat('MMM dd, yyyy').format(expense?.date ?? DateTime.now()),
    );
    _selectedCategory = expense?.category ?? 'Food';
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.go('/'),
            tooltip: 'Add Expense',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.insert_chart,
              color: Color.fromARGB(255, 226, 180, 43),
            ),
            onPressed: () => context.go('/see_charts'),
            tooltip: 'View Charts',
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        leading: Icon(
          Icons.build,
          color: const Color.fromARGB(255, 226, 180, 43),
          size: 30,
        ),
        title: Text(
          widget.expenseId == null ? 'Add Expense' : 'Edit Expense',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 226, 180, 43),
            fontSize: 24,
            letterSpacing: 0.6,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(
                    Icons.description,
                    color: Color.fromARGB(255, 226, 180, 43),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Color.fromARGB(255, 226, 180, 43),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be positive';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                borderRadius: BorderRadius.circular(10),
                value: _selectedCategory,
                items:
                    const [
                      'Food',
                      'Transport',
                      'Entertainment',
                      'Utilities',
                      'Other',
                    ].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(
                    Icons.category,
                    color: Color.fromARGB(255, 226, 180, 43),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 226, 180, 43),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Save Expense',
                  style: TextStyle(
                    color: Color.fromARGB(255, 226, 180, 43),
                    fontSize: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('MMM dd, yyyy').format(pickedDate);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        hiveKey: widget.expenseId != null ? int.parse(widget.expenseId!) : null,
      );

      if (widget.expenseId != null) {
        ref
            .read(expenseProvider.notifier)
            .updateExpense(int.parse(widget.expenseId!), expense);
      } else {
        ref.read(expenseProvider.notifier).addExpense(expense);
      }

      context.go('/');
    }
  }
}
