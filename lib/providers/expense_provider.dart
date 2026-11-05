import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _items = [];
  String? _email;
  String _query = '';
  String _category = 'All';
  bool _loading = false;

  bool get loading => _loading;
  String get category => _category;
  int get totalCount => _items.length;

  List<Expense> get filtered {
    final q = _query.trim().toLowerCase();
    return _items.where((e) {
      final matchesCategory = _category == 'All' || e.category == _category;
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.note.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Expense? findById(String id) {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  double get filteredTotal => filtered.fold(0.0, (sum, e) => sum + e.amount);

  double get monthTotal {
    final now = DateTime.now();
    return _items
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  String get _key => 'expenses_$_email';

  Future<void> load(String email) async {
    _email = email;
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) {
      _items = [];
    } else {
      _items = (jsonDecode(raw) as List)
          .map((e) => Expense.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    _sort();
    _loading = false;
    notifyListeners();
  }

  void clear() {
    _items = [];
    _email = null;
    _query = '';
    _category = 'All';
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  Future<void> add(Expense e) async {
    _items.add(e);
    await _persist();
  }

  Future<void> update(Expense e) async {
    final i = _items.indexWhere((x) => x.id == e.id);
    if (i != -1) _items[i] = e;
    await _persist();
  }

  Future<void> delete(String id) async {
    _items.removeWhere((x) => x.id == id);
    await _persist();
  }

  void _sort() => _items.sort((a, b) => b.date.compareTo(a.date));

  Future<void> _persist() async {
    _sort();
    notifyListeners();
    if (_email == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_items.map((e) => e.toMap()).toList()));
  }
}
