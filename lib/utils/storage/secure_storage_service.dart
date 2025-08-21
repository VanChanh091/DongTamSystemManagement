import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  //============================TOKEN=================================
  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: "auth_token");
  }

  //============================ROLE=================================
  Future<void> saveRole(String token) async {
    await _storage.write(key: "user_role", value: token);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: "user_role");
  }

  Future<void> deleteRole() async {
    await _storage.delete(key: "user_role");
  }

  //============================PERMISSION=================================
  Future<void> savePermission(String token) async {
    await _storage.write(key: "user_permission", value: token);
  }

  Future<String?> getPermission() async {
    return await _storage.read(key: "user_permission");
  }

  Future<void> deletePermission() async {
    await _storage.delete(key: "user_permission");
  }
}
