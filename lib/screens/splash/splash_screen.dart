import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final loggedIn = context.read<AuthProvider>().isLoggedIn;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet,
                size: 90, color: scheme.onPrimary),
            const SizedBox(height: 16),
            Text(
              'SpendWise',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Track every rupee',
                style: TextStyle(color: scheme.onPrimary.withOpacity(0.85))),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: scheme.onPrimary),
          ],
        ),
      ),
    );
  }
}
