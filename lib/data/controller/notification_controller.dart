import "package:dongtam/data/models/notification/notification_model.dart";
import "package:dongtam/service/notification/notification_service.dart";
import "package:dongtam/socket/socket_service.dart";
import "package:dongtam/utils/handleError/show_snack_bar.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class NotificationController extends GetxController {
  final _socketService = SocketService();

  var notifications = <NotificationModel>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    reInitialize();
  }

  Future<void> fetchOldNotifications() async {
    try {
      isLoading.value = true;

      final result = await NotificationService().getMyNofitications();

      //Gán vào biến hệ thống để Obx kích hoạt vẽ lại UI
      notifications.assignAll(result);

      // Cập nhật lại số đếm quả chuông
      unreadCount.value = notifications.where((n) => !n.isRead).length;
    } catch (e) {
      AppLogger.e("❌ Lỗi tải thông báo", error: e);
    } finally {
      isLoading.value = false;
    }
  }

  //lắng nghe sự kiện socket từ BE
  void listenToGlobalMeshNetwork() {
    // AppLogger.i("📡 [FE DEBUG] Tai nghe Socket 'new-notification' đang mở 24/7...");

    // SocketService().listenAny((event, data) {
    //   print("🦻 [SOCKET FE ON_ANY] Máy nhận được sự kiện: '$event' | Data: $data");
    // });

    _socketService.on('new-notification', (data) {
      // print("\n==================== 📥 NHẬN ĐƯỢC TIN REAL-TIME! ====================");
      // print("Dữ liệu thô từ Backend gửi sang: $data");
      // print("======================================================================\n");

      try {
        final newNotif = NotificationModel.fromJson(data);
        notifications.insert(0, newNotif);
        _updateUnreadCount();

        showNotificationBanner(title: "Bạn có thông báo mới", message: newNotif.title);
      } catch (e) {
        AppLogger.e("❌ Lỗi parse JSON tại Flutter: $e");
      }
    });
  }

  // Xử lý tác vụ từ thông báo
  Future<void> executeAction({
    required BuildContext context,
    required NotificationModel notif,
    required String action,
    required String type,
  }) async {
    try {
      bool isSuccess = false;

      if (type == "order") {
        //confirm
        isSuccess = await NotificationService().confirmRequestChanging(
          notificationId: notif.notificationId,
        );
      } else if (type == "planning") {
        //approved or rejected
        isSuccess = await NotificationService().handleRequestChanging(
          notificationId: notif.notificationId,
          action: action,
        );
      }

      if (isSuccess) {
        // Giả lập xử lý local tạm thời để UI mượt mà trước khi BE kịp sync về
        notifications.removeWhere((n) => n.notificationId == notif.notificationId);
        _updateUnreadCount();

        if (context.mounted) {
          showSnackBarSuccess(context, "Đã ghi nhận phản hồi tác vụ");
        }
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBarError(context, "Không thể xử lý tác vụ, vui lòng thử lại");
      }
    }
  }

  void _updateUnreadCount() {
    // debugPrint("🔔 [FE DEBUG] Số lượng thông báo chưa đọc: ${unreadCount.value}");
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> reInitialize() async {
    notifications.clear();
    unreadCount.value = 0;

    listenToGlobalMeshNetwork(); // Kích hoạt nghe Socket real-time
    await fetchOldNotifications(); // Lấy dữ liệu cũ từ API
  }
}
