import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:get/get.dart';

class BadgesController extends GetxController {
  //admin order
  RxInt numberBadges = 0.obs;

  //order pending planning
  RxInt numberOrderPending = 0.obs;

  //planning stop
  RxInt numberPlanningStop = 0.obs;

  //waiting check
  RxInt numberPaperWaiting = 0.obs;
  RxInt numberBoxWaiting = 0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchPendingApprovals();
    fetchPlanningStop();
    fetchOrderPending();
    fetchPaperWaitingCheck();
    fetchBoxWaitingCheck();
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

  Future<void> fetchOrderPending() async {
    try {
      final orders = await PlanningService().getOrderAccept();
      numberOrderPending.value = orders.length;
    } catch (e) {
      numberOrderPending.value = 0;
    }
  }

  Future<void> fetchPaperWaitingCheck() async {
    try {
      final orderWaiting = await WarehouseService().getPaperWaitingChecked();
      numberPaperWaiting.value = orderWaiting.length;
    } catch (e) {
      numberPaperWaiting.value = 0;
    }
  }

  Future<void> fetchBoxWaitingCheck() async {
    try {
      final orderWaiting = await WarehouseService().getBoxWaitingChecked();
      numberBoxWaiting.value = orderWaiting.length;
    } catch (e) {
      numberBoxWaiting.value = 0;
    }
  }
}
