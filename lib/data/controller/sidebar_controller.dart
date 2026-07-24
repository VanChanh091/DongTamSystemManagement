import "package:get/get.dart";

class SidebarController extends GetxController {
  var selectedIndex = 0.obs;
  var activeMenuKey = "Dashboard".obs;

  // Map lưu trạng thái đóng/mở của các menu phòng ban/nhóm
  var expansionStates = <String, bool>{}.obs;

  void changePage({required int index, String? menuKey}) {
    selectedIndex.value = index;
    if (menuKey != null) {
      activeMenuKey.value = menuKey;
    }
  }

  void reset() {
    selectedIndex.value = 0;
    activeMenuKey.value = "Dashboard";
    expansionStates.clear();
  }

  /// Kiểm tra menu (phòng ban / nhóm) có đang mở không
  bool isExpanded(String key) => expansionStates[key] ?? false;

  /// Đổi trạng thái đóng/mở
  void toggleExpand(String key) {
    expansionStates[key] = !isExpanded(key);
  }

  /// Tự động mở các menu cha nếu menu con bên trong đang active
  void expandParentsForActiveKey(String activeKey) {
    if (activeKey.isEmpty) return;
    final parts = activeKey.split(' > ');
    if (parts.isNotEmpty) {
      final deptKey = "dept_${parts[0]}";
      if (!expansionStates.containsKey(deptKey)) {
        expansionStates[deptKey] = true;
      }
    }
    if (parts.length >= 3) {
      final groupKey = "group_${parts[0]}_${parts[1]}";
      if (!expansionStates.containsKey(groupKey)) {
        expansionStates[groupKey] = true;
      }
    }
  }
}
