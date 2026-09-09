import 'dart:convert';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../storage/secure_storage.dart';

class AuthRepository {
  final ApiClient _api;
  final SecureStorage _storage;

  AuthRepository({required ApiClient api, required SecureStorage storage})
      : _api = api,
        _storage = storage;

  /// Login with email/password. Returns the authenticated [UserModel].
  /// Stores the Sanctum token in secure storage.
  Future<UserModel> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final response = await _api.post('/login', data: {
      'email': email,
      'password': password,
      'device_name': deviceName,
    });

    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveToken(token);
    await _storage.saveUserJson(jsonEncode(data['user']));

    return user;
  }

  /// Logout and delete the stored token.
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // Even if the server call fails, clear local state
    }
    await _storage.clearAll();
  }

  /// Get the currently authenticated user from the backend.
  Future<UserModel> getMe() async {
    final response = await _api.get('/me');
    final data = response.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveUserJson(jsonEncode(data['user']));

    return user;
  }

  /// Try to restore session from cached user data.
  Future<UserModel?> getCachedUser() async {
    final json = await _storage.getUserJson();
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Complete the employee profile for a newly registered user.
  Future<UserModel> completeProfile(Map<String, dynamic> data) async {
    await _api.post('/employee/complete-profile', data: data);
    return await getMe();
  }

  Future<Map<String, dynamic>> getEmployeeOptions() async {
    final response = await _api.get('/employee/options');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getEmployeeDirectory({String? search}) async {
    final response = await _api.get('/employee/directory', queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<UserModel> updateProfile(Map<String, dynamic> profile) async {
    final response = await _api.put('/employee/profile', data: profile);
    final data = response.data as Map<String, dynamic>;
    final rawUser = Map<String, dynamic>.from(data['user'] as Map);
    final user = UserModel.fromJson(rawUser);
    await _storage.saveUserJson(jsonEncode(rawUser));
    return user;
  }

  /// Check if a token exists in secure storage.
  Future<bool> hasToken() => _storage.hasToken();
}
