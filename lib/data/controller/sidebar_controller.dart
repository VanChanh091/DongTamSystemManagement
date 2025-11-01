import 'package:get/get.dart';

class SidebarController extends GetxController {
  var selectedIndex = 0.obs;

  void changePage({required int index}) {
    selectedIndex.value = index; // Cập nhật trang
  }

  void reset() {
    selectedIndex.value = 0;
  }
}
