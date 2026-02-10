import 'dart:convert';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:dongtam/utils/storage/secure_storage_service.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final SecureStorageService storage = SecureStorageService();

  RxInt userId = 0.obs;
  RxString role = "".obs;
  RxList<String> permissions = <String>[].obs;

  Future<void> loadUserData() async {
    try {
      String? storedUserId = await storage.getUserId();
      String? storedRole = await storage.getRole();
      String? storedPermissions = await storage.getPermission();

      if (storedUserId != null) {
        userId.value = int.parse(storedUserId);
      }

      if (storedRole != null) {
        role.value = storedRole;
      }

      if (storedPermissions != null) {
        permissions.value = List<String>.from(jsonDecode(storedPermissions));
      } else {
        permissions.clear();
      }
    } catch (e, s) {
      AppLogger.e("Error loading user data", error: e, stackTrace: s);
    }
  }

  bool hasPermission({required String permission}) {
    if (role.value == "admin" || role.value == "manager") {
      return true;
    }
    return permissions.contains(permission);
  }

  bool hasAnyPermission({required List<String> permission}) {
    if (role.value == "admin" || role.value == "manager") {
      return true;
    }
    return permissions.any((p) => permission.contains(p));
  }

  bool hasAnyRole({required List<String> roles}) {
    final result = roles.contains(role.value);
    return result;
  }

  void clearUser() {
    userId.value = 0;
    role.value = "";
    permissions.clear();
  }
}
