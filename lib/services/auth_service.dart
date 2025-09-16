import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {

  static bool _isAuthenticated = false;
  static String? _currentUser;
  static DateTime? _loginTime;

  static final Map<String, String> _users = {
    'admin': _hashPassword('fish123'),
    'operator': _hashPassword('op123'),
    'supervisor': _hashPassword('super123'),
  };

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool authenticate(String username, String password) {
    final hashedPassword = _hashPassword(password);

    if (_users.containsKey(username) && _users[username] == hashedPassword) {
      _isAuthenticated = true;
      _currentUser = username;
      _loginTime = DateTime.now();
      return true;
    }

    return false;
  }

  static bool get isAuthenticated => _isAuthenticated;

  static String? get currentUser => _currentUser;

  static DateTime? get loginTime => _loginTime;

  static void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    _loginTime = null;
  }

  static bool isSessionValid() {
    if (!_isAuthenticated || _loginTime == null) {
      return false;
    }

    final now = DateTime.now();
    final sessionDuration = now.difference(_loginTime!);

    return sessionDuration.inHours < 8;
  }

  static void extendSession() {
    if (_isAuthenticated) {
      _loginTime = DateTime.now();
    }
  }

  static String getUserRole(String username) {
    switch (username) {
      case 'admin':
        return 'Administrator';
      case 'supervisor':
        return 'Supervisor';
      case 'operator':
        return 'Operator';
      default:
        return 'User';
    }
  }

  static bool hasPermission(String permission) {
    if (!_isAuthenticated || _currentUser == null) {
      return false;
    }

    switch (_currentUser) {
      case 'admin':
        return true;
      case 'supervisor':
        return ['read', 'write', 'export'].contains(permission);
      case 'operator':
        return ['read', 'write'].contains(permission);
      default:
        return permission == 'read';
    }
  }

  static Map<String, bool> getCurrentUserPermissions() {
    return {
      'read': hasPermission('read'),
      'write': hasPermission('write'),
      'delete': hasPermission('delete'),
      'export': hasPermission('export'),
      'admin': hasPermission('admin'),
    };
  }

  static String getSessionInfo() {
    if (!_isAuthenticated) {
      return 'Not authenticated';
    }

    final duration = DateTime.now().difference(_loginTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return 'User: $_currentUser\n'
           'Role: ${getUserRole(_currentUser!)}\n'
           'Session time: ${hours}h ${minutes}m\n'
           'Valid: ${isSessionValid()}';
  }

  static bool changePassword(String username, String oldPassword, String newPassword) {
    if (!_users.containsKey(username)) {
      return false;
    }

    final oldHash = _hashPassword(oldPassword);
    if (_users[username] != oldHash) {
      return false;
    }

    if (newPassword.length < 6) {
      return false;
    }

    _users[username] = _hashPassword(newPassword);
    return true;
  }

  static List<String> getAvailableUsers() {
    return _users.keys.toList();
  }

  static Map<String, dynamic> getAuthStats() {
    return {
      'isAuthenticated': _isAuthenticated,
      'currentUser': _currentUser,
      'userRole': _currentUser != null ? getUserRole(_currentUser!) : null,
      'loginTime': _loginTime?.toIso8601String(),
      'sessionValid': isSessionValid(),
      'permissions': getCurrentUserPermissions(),
      'totalUsers': _users.length,
    };
  }
}