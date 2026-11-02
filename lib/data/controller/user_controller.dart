import "dart:convert";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:dongtam/utils/storage/secure_storage_service.dart";
import "package:get/get.dart";

class UserController extends GetxController {
  final SecureStorageService storage = SecureStorageService();

  RxInt userId = 0.obs;
  RxString role = "".obs;
  RxString department = "".obs;
  RxList<String> permissions = <String>[].obs;

  Future<void> loadUserData() async {
    try {
      String? storedUserId = await storage.getUserId();
      String? storedRole = await storage.getRole();
      String? storedDepartment = await storage.getDepartment();
      String? storedPermissions = await storage.getPermission();

      if (storedUserId != null) userId.value = int.parse(storedUserId);
      if (storedRole != null) role.value = storedRole;
      if (storedDepartment != null) department.value = storedDepartment;

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
    if (role.value == "admin") return true;
    return permissions.contains(permission);
  }

  bool hasAnyPermission({required List<String> permissions}) {
    if (role.value == "admin") return true;
    return permissions.any((p) => permissions.contains(p));
  }

  bool hasAnyRole({required List<String> roles}) {
    return roles.contains(role.value);
  }

  bool canAccess({
    List<String>? departments,
    List<String>? managerDept,
    List<String>? permissions,
    List<String>? roles,
    bool requireDept = false,
  }) {
    final isManager = role.value == "manager";

    // Admin luôn có toàn quyền
    if (role.value == "admin") return true;

    // Kiểm tra giới hạn Role
    if (roles != null && roles.isNotEmpty && !roles.contains(role.value)) {
      return false;
    }

    final userDept = department.value.toLowerCase();
    final isBelongToDept =
        departments != null && departments.any((d) => d.toLowerCase() == userDept);

    //manager được chỉ định có thể xem chéo
    if (isManager && managerDept != null) {
      final isAllowed = managerDept.any((d) => d.toLowerCase() == userDept);
      if (isAllowed) return true;
    }

    // Chặn nếu bắt buộc phải thuộc phòng ban sở tại
    if (requireDept && !isBelongToDept) return false;

    // Manager của đúng phòng ban -> Toàn quyền trong phòng ban đó
    if (isManager) {
      // Manager phòng sở tại -> Toàn quyền trong phòng ban mình
      if (isBelongToDept) return true;

      // Manager phòng khác -> Nếu không bắt buộc phòng sở tại thì được xem chéo
      if (!requireDept) return true;
    }

    // Nếu không yêu cầu permission cụ thể, chỉ cần thuộc phòng ban là được
    if ((permissions == null || permissions.isEmpty) && isBelongToDept) return true;

    // Kiểm tra permission (Áp dụng cho cả User nội bộ và Người xem chéo)
    if (permissions != null && permissions.isNotEmpty) {
      return permissions.any((p) => this.permissions.contains(p));
    }

    return false;
  }

  void clearUser() {
    userId.value = 0;
    role.value = "";
    department.value = "";
    permissions.clear();
  }
}
