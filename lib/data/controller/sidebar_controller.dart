import "package:get/get.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:shared_preferences/shared_preferences.dart";

class SidebarController extends GetxController {
  var selectedIndex = 0.obs;
  var selectedDepartment = 'sales'.obs;
  var pinnedItemIds = <String>[].obs; //danh sách chức năng được ghim

  @override
  void onInit() {
    super.onInit();
    loadPinnedItems();
  }

  // Hàm đọc dữ liệu bất đồng bộ từ thiết bị
  Future<void> loadPinnedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? storedPins = prefs.getStringList('pinned_menus');
      if (storedPins != null) {
        pinnedItemIds.assignAll(storedPins);
      }
    } catch (e) {
      AppLogger.e("Lỗi đọc SharedPreferences: $e");
    }
  }

  void changePage({required int index}) {
    selectedIndex.value = index; // Cập nhật trang
  }

  void reset() {
    selectedIndex.value = 0;
    selectedDepartment.value = 'sales';
  }

  void changeDepartment(String deptKey) {
    selectedDepartment.value = deptKey;
  }

  // Toggle ghim/bỏ ghim không giới hạn
  Future<void> togglePin(String id) async {
    if (pinnedItemIds.contains(id)) {
      pinnedItemIds.remove(id);
    } else {
      pinnedItemIds.add(id);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      // SharedPreferences lưu danh sách dạng mảng chuỗi (List<String>)
      await prefs.setStringList('pinned_menus', pinnedItemIds.toList());
    } catch (e) {
      AppLogger.e("Lỗi ghi SharedPreferences: $e");
    }
  }

  bool isPinned(String id) {
    return pinnedItemIds.contains(id);
  }
}
