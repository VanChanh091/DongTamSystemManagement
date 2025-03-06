import 'package:get/get.dart';

class SidebarController extends GetxController {
  var selectedIndex = 0.obs; // Biến trạng thái

  void changePage(int index) {
    selectedIndex.value = index; // Cập nhật trang
  }
}
