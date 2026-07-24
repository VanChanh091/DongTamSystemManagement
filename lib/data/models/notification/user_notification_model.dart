import 'package:dongtam/data/models/notification/notification_model.dart';

class UserNotificationModel {
  final int userNotifyId;

  final int receiverId;
  final String? receiverDept;
  final bool isRead;

  final int notificationId;
  final NotificationModel? notification;

  UserNotificationModel({
    required this.userNotifyId,
    required this.receiverId,
    required this.receiverDept,
    required this.isRead,
    required this.notificationId,
    this.notification,
  });

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationModel(
      userNotifyId: json["userNotifyId"] ?? 0,
      receiverId: json["receiverId"] ?? 0,
      receiverDept: json["receiverDept"] ?? "",
      isRead: json["isRead"] ?? false,
      notificationId: json["notificationId"] ?? 0,
      notification:
          json["NotificationModel"] != null
              ? NotificationModel.fromJson(json["NotificationModel"])
              : null,
    );
  }
}
