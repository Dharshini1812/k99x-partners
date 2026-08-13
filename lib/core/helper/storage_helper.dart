import 'dart:convert';

import 'package:dealer/features/login/data/model/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _userKey = 'user';
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _isLoggedInKey = 'isLoggedIn';

  Future<void> saveLogin({
    required UserData user,
    required String password,
  }) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );

    await _storage.write(
      key: _usernameKey,
      value: user.username,
    );

    await _storage.write(
      key: _passwordKey,
      value: password,
    );

    await _storage.write(
      key: _isLoggedInKey,
      value: 'true',
    );
  }

  Future<UserData?> getUser() async {
    final userString = await _storage.read(key: _userKey);

    if (userString == null || userString.isEmpty) {
      return null;
    }

    return UserData.fromJson(jsonDecode(userString));
  }

  Future<String?> getUsername() async {
    return _storage.read(key: _usernameKey);
  }

  Future<String?> getPassword() async {
    return _storage.read(key: _passwordKey);
  }

  Future<int?> getUserId() async {
    final user = await getUser();
    return user?.userId;
  }

  Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: _isLoggedInKey);
    return value == 'true';
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
