import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class ApiAuthRepository implements IAuthRepository {
  UserModel? _currentUser;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/auth/login', body: {
      'email': email.trim(),
      'password': password,
    });

    if (response is Map<String, dynamic> && response.containsKey('token')) {
      final token = response['token'] as String;
      ApiClient.token = token;
      final userData = response['user'] as Map<String, dynamic>;
      _currentUser = UserModel.fromJson(userData);

      // Persist token + user to survive browser refresh
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));

      return _currentUser!;
    }

    throw Exception('Invalid response format from login API');
  }

  @override
  Future<UserModel> loginAsRole(UserRole role) async {
    String email = 'ahmed.kamal@company.com';
    if (role == UserRole.admin) email = 'yahia@company.com';
    if (role == UserRole.manager) email = 'mohamed@company.com';

    return await login(email: email, password: 'password123');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.post('/auth/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Already loaded in memory
    if (_currentUser != null) return _currentUser;

    // Try restoring from SharedPreferences (browser refresh)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);

    if (token != null && token.isNotEmpty && userJson != null) {
      ApiClient.token = token;
      _currentUser = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      return _currentUser;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    ApiClient.token = null;
    _currentUser = null;

    // Clear persisted session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
