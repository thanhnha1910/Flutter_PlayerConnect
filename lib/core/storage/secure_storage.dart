import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorage(this._storage);
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userNameKey, value: name);
  }
  
  Future<Map<String, String?>> getUserData() async {
    return {
      'userId': await _storage.read(key: _userIdKey),
      'email': await _storage.read(key: _userEmailKey),
      'name': await _storage.read(key: _userNameKey),
    };
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}