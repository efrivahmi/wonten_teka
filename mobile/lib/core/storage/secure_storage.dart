import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage using the device's Keychain (iOS) / Keystore (Android).
/// Wraps flutter_secure_storage for Sanctum bearer token persistence.
class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_json';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  // ── Token ──────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── User Cache ─────────────────────────────────────────────────────────

  Future<void> saveUserJson(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  Future<String?> getUserJson() async {
    return _storage.read(key: _userKey);
  }

  // ── Generic Key-Value ──────────────────────────────────────────────────

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  // ── Clear All ──────────────────────────────────────────────────────────

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
