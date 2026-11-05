import 'package:flutter/material.dart';

class AppTheme {
  static const Color seed = Color(0xFF00897B);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}

IconData categoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Travel':
      return Icons.directions_bus;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Bills':
      return Icons.receipt_long;
    case 'Education':
      return Icons.school;
    case 'Health':
      return Icons.favorite;
    case 'Entertainment':
      return Icons.movie;
    default:
      return Icons.category;
  }
}
