import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/service/badge/badge_service.dart';
import 'package:dongtam/socket/socket_service.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:get/get.dart';

class BadgesController extends GetxController {
  final UserController _userController = Get.find<UserController>();

  //admin order
  RxInt numberPendingApproval = 0.obs;
  RxInt numberOrderPendingPlanning = 0.obs;
  RxInt numberOrderReject = 0.obs;
  RxInt numberPlanningStop = 0.obs;
  RxInt numberPaperWaiting = 0.obs;
  RxInt numberBoxWaiting = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Theo dõi role: Nếu role thay đổi, tự động refresh badge
    ever(_userController.role, (role) {
      if (role.isNotEmpty) {
        refreshAllBadges();
      } else {
        clearAllBadge();
      }
    });
  }

  void initSocketAfterLogin(int userId) async {
    await refreshAllBadges();

    //init socket
    final socketService = SocketService();
    await socketService.connectSocket();

    //join rom
    socketService.joinUserRoom(userId);

    //register listener
    socketService.on("updateBadgeCount", (data) {
      if (data['type'] == "REJECTED_ORDER") {
        int oldCount = numberOrderReject.value;
        numberOrderReject.value = data['count'] ?? 0;

        AppLogger.i("✅ Cập nhật Badge thành công: $oldCount -> ${numberOrderReject.value}");
      }
    });
  }

  Future<void> refreshAllBadges() async {
    final List<Future<void>> tasks = [];

    // badge cho duyệt đơn
    if (_userController.hasAnyRole(roles: ['admin', 'manager'])) {
      tasks.add(fetchPendingApprovals());
    } else {
      numberPendingApproval.value = 0;
    }

    // badge cho đơn dừng sản xuất và chờ lên kế hoạch
    if (_userController.hasPermission(permission: "plan")) {
      tasks.add(fetchPlanningStop());
      tasks.add(fetchOrderPendingPlanning());
    } else {
      numberPlanningStop.value = 0;
      numberOrderPendingPlanning.value = 0;
    }

    // badge cho giấy tấm và thùng chờ kiểm
    if (_userController.hasPermission(permission: "QC")) {
      tasks.add(fetchPaperWaitingCheck());
      tasks.add(fetchBoxWaitingCheck());
    } else {
      numberPaperWaiting.value = 0;
      numberBoxWaiting.value = 0;
    }

    // badge cho đơn bị từ chối
    if (_userController.hasPermission(permission: "sale")) {
      tasks.add(fetchOrderReject());
    } else {
      numberPendingApproval.value = 0;
    }

    if (tasks.isNotEmpty) {
      try {
        await Future.wait(tasks);
        AppLogger.i("✅ Success: All badge counts synchronized successfully.");
      } catch (e) {
        AppLogger.e("❌ Malfunction: Failed to execute collective badge refresh.", error: e);
      }
    }
  }

  //helper
  Future<void> fetchBadgeCount({
    required RxInt badgeCount,
    required Future<int> Function() fetcher,
  }) async {
    try {
      final result = await fetcher();
      badgeCount.value = result;
    } catch (e) {
      badgeCount.value = 0;
    }
  }

  // Hàm gọi API để lấy số đơn chờ duyệt
  Future<void> fetchPendingApprovals() async {
    await fetchBadgeCount(
      badgeCount: numberPendingApproval,
      fetcher: () => BadgeService().countOrderPending(),
    );
  }

  // Hàm gọi API để lấy đơn dừng sản xuất
  Future<void> fetchPlanningStop() async {
    await fetchBadgeCount(
      badgeCount: numberPlanningStop,
      fetcher: () => BadgeService().countPlanningStop(),
    );
  }

  // Hàm gọi API để lấy đơn chờ lên kế hoạch
  Future<void> fetchOrderPendingPlanning() async {
    await fetchBadgeCount(
      badgeCount: numberOrderPendingPlanning,
      fetcher: () => BadgeService().countOrderPendingPlanning(),
    );
  }

  // Hàm gọi API để lấy đơn chờ kiểm
  Future<void> fetchPaperWaitingCheck() async {
    await fetchBadgeCount(
      badgeCount: numberPaperWaiting,
      fetcher: () => BadgeService().countWaitingCheckPaper(),
    );
  }

  Future<void> fetchBoxWaitingCheck() async {
    await fetchBadgeCount(
      badgeCount: numberBoxWaiting,
      fetcher: () => BadgeService().countWaitingCheckBox(),
    );
  }

  // Hàm gọi API để lấy đơn bị từ chối
  Future<void> fetchOrderReject() async {
    await fetchBadgeCount(
      badgeCount: numberOrderReject,
      fetcher: () => BadgeService().countOrderRejected(),
    );
  }

  void clearAllBadge() {
    numberPendingApproval.value = 0;
    numberOrderPendingPlanning.value = 0;
    numberPlanningStop.value = 0;
    numberPaperWaiting.value = 0;
    numberBoxWaiting.value = 0;
    numberOrderReject.value = 0;
  }
}
