import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

/// Used for both adding a new expense and editing an existing one.
class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;
  late String _category;
  late DateTime _date;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _title = TextEditingController(text: e?.title ?? '');
    _amount = TextEditingController(
        text: e == null ? '' : e.amount.toStringAsFixed(2));
    _note = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? kCategories.first;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ExpenseProvider>();
    final expense = Expense(
      id: widget.expense?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      amount: double.parse(_amount.text.trim()),
      category: _category,
      date: _date,
      note: _note.text.trim(),
    );
    if (_isEdit) {
      await provider.update(expense);
    } else {
      await provider.add(expense);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Expense updated' : 'Expense added')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit expense' : 'Add expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      labelText: 'Title', prefixIcon: Icon(Icons.title)),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      prefixIcon: Icon(Icons.currency_rupee)),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    if (n == null) return 'Enter a valid amount';
                    if (n <= 0) return 'Amount must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                      labelText: 'Category', prefixIcon: Icon(Icons.category)),
                  items: kCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today)),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes)),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(_isEdit ? 'Update' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
