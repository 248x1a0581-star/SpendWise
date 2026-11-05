import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in anytime.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(90, 40)),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final expenses = context.read<ExpenseProvider>();
    await context.read<AuthProvider>().logout();
    expenses.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final count = context.watch<ExpenseProvider>().totalCount;
    final scheme = Theme.of(context).colorScheme;
    final initial =
        (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primary,
              child: Text(initial,
                  style: TextStyle(fontSize: 36, color: scheme.onPrimary)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user?.name ?? '',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Center(child: Text(user?.email ?? '')),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Total expenses recorded'),
              trailing: Text('$count',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
