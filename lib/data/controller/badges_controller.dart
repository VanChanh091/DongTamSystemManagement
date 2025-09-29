import 'package:dongtam/service/admin_service.dart';
import 'package:get/get.dart';

class BadgesController extends GetxController {
  RxInt numberBadges = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingApprovals();
  }

  // Hàm gọi API để lấy số đơn chờ duyệt
  Future<void> fetchPendingApprovals() async {
    try {
      final orders = await AdminService().getOrderByPendingStatus();
      numberBadges.value = orders.length;
    } catch (e) {
      numberBadges.value = 0;
    }
  }
}
