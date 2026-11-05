import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  static const _usersKey = 'users';
  static const _sessionKey = 'session_email';

  late SharedPreferences _prefs;
  List<AppUser> _users = [];
  AppUser? _current;

  AppUser? get currentUser => _current;
  bool get isLoggedIn => _current != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_usersKey);
    if (raw != null) {
      _users = (jsonDecode(raw) as List)
          .map((e) => AppUser.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    final email = _prefs.getString(_sessionKey);
    if (email != null) {
      for (final u in _users) {
        if (u.email == email) _current = u;
      }
    }
  }

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> _saveUsers() async {
    await _prefs.setString(
        _usersKey, jsonEncode(_users.map((u) => u.toMap()).toList()));
  }

  /// Returns an error message, or null on success.
  Future<String?> register(String name, String email, String password) async {
    final e = email.trim().toLowerCase();
    if (_users.any((u) => u.email == e)) {
      return 'An account with this email already exists.';
    }
    final user =
        AppUser(name: name.trim(), email: e, passwordHash: _hash(password));
    _users.add(user);
    await _saveUsers();
    _current = user;
    await _prefs.setString(_sessionKey, e);
    notifyListeners();
    return null;
  }

  /// Returns an error message, or null on success.
  Future<String?> login(String email, String password) async {
    final e = email.trim().toLowerCase();
    for (final u in _users) {
      if (u.email == e) {
        if (u.passwordHash == _hash(password)) {
          _current = u;
          await _prefs.setString(_sessionKey, e);
          notifyListeners();
          return null;
        }
        return 'Incorrect password.';
      }
    }
    return 'No account found for this email.';
  }

  Future<void> logout() async {
    _current = null;
    await _prefs.remove(_sessionKey);
    notifyListeners();
  }
}
