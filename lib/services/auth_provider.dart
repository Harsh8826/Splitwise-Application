import 'package:flutter/material.dart';
import 'package:flutter_application_4/core/log/log.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../screens/account_screen.dart';
class AuthProvider extends ChangeNotifier {
  AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadToken();
  }


  Future<void> _loadToken() async {
    _token = await _authService.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    Logger.logDeveloper("email $email, password $password in auth provider");
    _isLoading = true;
    notifyListeners();
    String? result = await _authService.login(email, password);
    _token = result;
    _isLoading = false;
    notifyListeners();
    return _token != null;
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    notifyListeners();
  }
  Future<bool> register(String username, String email, String password) async {
    try {
      // Create a mock user object
     bool result = await _authService.register(username,email, password);
     bool  _token = result;
    _isLoading = false;
    notifyListeners();
    return _token;
      // Save it to local storage
      // await _storage.write(key: 'user', value: json.encode(user));

      // return true;
    } catch (e) {
      print('Error in AuthService.register: $e');
      return false;
    }
  }
   Future<bool> tryAutoLogin() async {
  final storedToken = await _storage.read(key: 'authToken');
  if (storedToken == null) return false;

  // Optional: check with backend before using it
  final isValid = await _authService.validateToken(storedToken);
  if (!isValid) {
    await _storage.delete(key: 'authToken');
    return false;
  }

  _token = storedToken;
  notifyListeners();
  return true;
}

}
