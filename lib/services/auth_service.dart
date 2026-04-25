import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_application_4/core/log/log.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/v1'; // 
  static const String _tokenKey = 'authToken';
  static const String _userKey = 'authUser';

  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> register(String username, String email, String password) async {
    Map<String,dynamic> payload={
          "name": username,
          "email": email,
          "password": password,
        };
        Logger.logDeveloper("final paylad while register user $payload");
    try {
      final response = await _dio.post(
        '/auth/register',
        data: payload,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
       Logger.logDeveloper("respone while register user $response");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<String?> login(String email, String password) async {
     Logger.logDeveloper("email $email, password $password in auth service");
    Map<String,dynamic> payload= {
          "email": email,
          "password": password,
        };
        Logger.logDeveloper("final payload  while login $payload");
    try {
      final response = await _dio.post(
        '/auth/login',
        data:payload,
        options: Options(headers: {"Content-Type": "application/json"}),
      );
      Logger.logDeveloper("respone while login user $response");
      if (response.statusCode == 200 &&
          response.data['token'] != null &&
          response.data['user'] != null) {
        final token = response.data['token'] as String;
        final userJson = response.data['user'];

        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: jsonEncode(userJson));

        return token;
      }
      return null;
    } catch (e) {
      Logger.logDeveloper("error in login $e");
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Get token error: $e');
      return null;
    }
  }
  bool validateToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return false;

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );

    final exp = payload['exp'];
    if (exp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now < exp; // valid if current time is before expiry
  } catch (e) {
    return false;
  }
}

  Future<User?> getUser() async {
    try {
      final userStr = await _storage.read(key: _userKey);
      if (userStr != null) {
        return User.fromJson(jsonDecode(userStr));
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}