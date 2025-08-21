import 'dart:convert';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final SecureStorageService storage = SecureStorageService();
  RxString role = "".obs;
  RxList<String> permissions = <String>[].obs;

  Future<void> loadUserData() async {
    try {
      String? storedRole = await storage.getRole();
      String? storedPermissions = await storage.getPermission();

      if (storedRole != null) {
        role.value = storedRole;
      }

      if (storedPermissions != null) {
        permissions.value = List<String>.from(jsonDecode(storedPermissions));
      } else {
        permissions.clear();
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  bool hasPermission(String permission) {
    if (role.value == "admin" || role.value == "manager") {
      return true;
    }
    return permissions.contains(permission);
  }

  bool hasAnyPermission(List<String> permission) {
    if (role.value == "admin" || role.value == "manager") {
      return true;
    }
    return permissions.any((p) => permission.contains(p));
  }

  bool hasAnyRole(List<String> roles) {
    return roles.contains(role.value);
  }

  void clearUser() {
    role.value = "";
    permissions.clear();
  }
}
