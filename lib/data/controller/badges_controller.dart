import 'package:dongtam/service/admin/admin_service.dart';
import 'package:dongtam/service/order_service.dart';
import 'package:dongtam/service/planning_service.dart';
import 'package:dongtam/service/warehouse_service.dart';
import 'package:get/get.dart';

class BadgesController extends GetxController {
  //admin order
  RxInt numberBadges = 0.obs;

  //order pending planning
  RxInt numberOrderPending = 0.obs;

  //order reject
  RxInt numberOrderReject = 0.obs;

  //planning stop
  RxInt numberPlanningStop = 0.obs;

  //waiting check
  RxInt numberPaperWaiting = 0.obs;
  RxInt numberBoxWaiting = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // final userController = Get.find<UserController>();

    // ever(userController.role, (String r) {
    //   if (r.isNotEmpty) {
    //     refreshAllBadges();
    //   }
    // });

    // ever(userController.permissions, (List<String> p) {
    //   if (p.isNotEmpty) {
    //     refreshAllBadges();
    //   }
    // });

    // if (userController.role.value.isNotEmpty) {
    //   refreshAllBadges();
    // }

    refreshAllBadges();
  }

  Future<void> refreshAllBadges() async {
    await Future.wait([
      fetchPendingApprovals(),
      fetchPlanningStop(),
      fetchOrderPending(),
      fetchPaperWaitingCheck(),
      fetchBoxWaitingCheck(),
      fetchOrderReject(),
    ]);
  }

  // Hàm gọi API để lấy số đơn chờ duyệt
  Future<void> fetchPendingApprovals() async {
    await fetchBadgeCount(
      badgeCount: numberBadges,
      fetcher: () => AdminService().getOrderByPendingStatus(),
    );
  }

  Future<void> fetchPlanningStop() async {
    try {
      final result = await PlanningService().getPlanningStop();
      numberPlanningStop.value = (result["totalPlannings"] ?? 0) as int;
    } catch (e) {
      numberPlanningStop.value = 0;
    }
  }

  Future<void> fetchOrderReject() async {
    try {
      final result = await OrderService().countOrderRejected();
      numberOrderReject.value = result;
    } catch (e) {
      numberOrderReject.value = 0;
    }
  }

  Future<void> fetchOrderPending() async {
    await fetchBadgeCount(
      badgeCount: numberOrderPending,
      fetcher: () => PlanningService().getOrderAccept(),
    );
  }

  Future<void> fetchPaperWaitingCheck() async {
    await fetchBadgeCount(
      badgeCount: numberPaperWaiting,
      fetcher: () => WarehouseService().getPaperWaitingChecked(),
    );
  }

  Future<void> fetchBoxWaitingCheck() async {
    await fetchBadgeCount(
      badgeCount: numberBoxWaiting,
      fetcher: () => WarehouseService().getBoxWaitingChecked(),
    );
  }

  //helper
  Future<void> fetchBadgeCount<T>({
    required RxInt badgeCount,
    required Future<List<T>> Function() fetcher,
  }) async {
    try {
      final data = await fetcher();
      badgeCount.value = data.length; //list
    } catch (e) {
      badgeCount.value = 0;
    }
  }
}
