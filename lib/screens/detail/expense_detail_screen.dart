import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import '../add_expense/add_edit_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;
  const ExpenseDetailScreen({super.key, required this.expenseId});

  Future<void> _confirmDelete(BuildContext context, Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('"${e.title}" will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(90, 40)),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await context.read<ExpenseProvider>().delete(e.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Expense deleted')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final expense = provider.findById(expenseId);

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense')),
        body: const Center(child: Text('This expense no longer exists.')),
      );
    }

    final e = expense;
    final scheme = Theme.of(context).colorScheme;
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense details'),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => AddEditExpenseScreen(expense: e))),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, e),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 38,
              backgroundColor: scheme.primaryContainer,
              child: Icon(categoryIcon(e.category),
                  size: 38, color: scheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(money.format(e.amount),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _row(Icons.title, 'Title', e.title),
          _row(Icons.category, 'Category', e.category),
          _row(Icons.calendar_today, 'Date',
              DateFormat('EEEE, dd MMM yyyy').format(e.date)),
          _row(Icons.notes, 'Note', e.note.isEmpty ? '—' : e.note),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontSize: 13)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
