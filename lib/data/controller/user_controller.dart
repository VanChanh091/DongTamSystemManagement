import 'dart:convert';
import 'package:dongtam/utils/logger/app_logger.dart';
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

      // Log tổng quan một lần
      AppLogger.i(
        "User data loaded → role: $role, permissions: ${permissions.length}",
      );
    } catch (e, s) {
      AppLogger.e("Error loading user data", error: e, stackTrace: s);
    }
  }

  bool hasPermission(String permission) {
    if (role.value == "admin" || role.value == "manager") {
      AppLogger.i("hasPermission: role=${role.value} => FULL ACCESS");
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
    final result = roles.contains(role.value);
    return result;
  }

  void clearUser() {
    role.value = "";
    permissions.clear();
    AppLogger.i("User cleared");
  }
}
