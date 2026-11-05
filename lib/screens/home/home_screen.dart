import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/expense.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../theme/app_theme.dart';
import '../add_expense/add_edit_expense_screen.dart';
import '../detail/expense_detail_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = context.read<AuthProvider>().currentUser?.email;
      if (email != null) context.read<ExpenseProvider>().load(email);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().currentUser?.name ?? '';
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AddEditExpenseScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = provider.filtered;
          return Column(
            children: [
              _SummaryCard(
                greeting: 'Hello, ${name.split(' ').first}',
                monthTotal: money.format(provider.monthTotal),
                shownTotal: money.format(provider.filteredTotal),
                shownCount: items.length,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search expenses',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setQuery('');
                              setState(() {});
                            },
                          ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: ['All', ...kCategories].map((c) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: provider.category == c,
                        onSelected: (_) => provider.setCategory(c),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? _EmptyState(hasAny: provider.totalCount > 0)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: items.length,
                        itemBuilder: (context, i) =>
                            _ExpenseTile(expense: items[i], money: money),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String greeting;
  final String monthTotal;
  final String shownTotal;
  final int shownCount;

  const _SummaryCard({
    required this.greeting,
    required this.monthTotal,
    required this.shownTotal,
    required this.shownCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: TextStyle(color: scheme.onPrimary.withOpacity(0.9))),
          const SizedBox(height: 6),
          Text('Spent this month',
              style: TextStyle(color: scheme.onPrimary.withOpacity(0.8))),
          Text(monthTotal,
              style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Showing $shownCount item(s) • $shownTotal',
              style: TextStyle(color: scheme.onPrimary.withOpacity(0.85))),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final NumberFormat money;

  const _ExpenseTile({required this.expense, required this.money});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expenseId: expense.id))),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(categoryIcon(expense.category),
              color: scheme.onPrimaryContainer),
        ),
        title: Text(expense.title,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
            '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}'),
        trailing: Text(money.format(expense.amount),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasAny;
  const _EmptyState({required this.hasAny});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(hasAny ? Icons.search_off : Icons.receipt_long,
                size: 72, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              hasAny ? 'No matching expenses' : 'No expenses yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasAny
                  ? 'Try a different search or category.'
                  : 'Tap "Add expense" to record your first one.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
