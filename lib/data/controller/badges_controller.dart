import 'package:dongtam/service/admin_service.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:get/get.dart';

class BadgesController extends GetxController {
  RxInt numberBadges = 0.obs;
  RxInt numberPlanningStop = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingApprovals();
    fetchPlanningStop();
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

  Future<void> fetchPlanningStop() async {
    try {
      final result = await PlanningService().getPlanningStop();
      numberPlanningStop.value = (result["totalPlannings"] ?? 0) as int;
    } catch (e) {
      numberPlanningStop.value = 0;
    }
  }
}
