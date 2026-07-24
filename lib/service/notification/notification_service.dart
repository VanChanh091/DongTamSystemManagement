import "package:dio/dio.dart";
import "package:dongtam/data/models/notification/notification_model.dart";
import "package:dongtam/utils/handleError/dio_client.dart";
import "package:dongtam/utils/helper/helper_service.dart";

class NotificationService {
  final Dio dioService = DioClient().dio;

  //===============================NOTIFICATION==============================
  Future<List<NotificationModel>> getMyNofitications() async {
    return await HelperService().fetchingData(
      endpoint: "notification",
      queryParameters: const {},
      fromJson: (json) => NotificationModel.fromJson(json),
    );
  }

  Future<bool> confirmRequestChanging({required int notificationId}) {
    return HelperService().updateItem(
      endpoint: "notification",
      queryParameters: {"notificationId": notificationId},
    );
  }

  //===============================ORDER==============================
  Future<bool> requestChangeInfoOrder({
    required int receiverId,
    required String orderId,
    required String requestType,
    required DateTime? newDeliveryDate,
    required String reason,
  }) {
    return HelperService().addItem(
      endpoint: "notification/order",
      queryParameters: {"receiverId": receiverId},
      body: {
        "orderId": orderId,
        "requestType": requestType,
        "newDeliveryDate": newDeliveryDate?.toIso8601String(),
        "reason": reason,
      },
    );
  }

  //===============================PLANNING==============================
  Future<bool> handleRequestChanging({required int notificationId, required String action}) {
    return HelperService().addItem(
      endpoint: "notification/planning",
      queryParameters: {"notificationId": notificationId, "action": action},
    );
  }
}
