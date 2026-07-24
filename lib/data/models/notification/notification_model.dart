import 'package:dongtam/data/models/notification/user_notification_model.dart';

class NotificationModel {
  final int notificationId;

  final String title;
  final String type;
  final String targetType;

  final int senderId;
  final String senderName;
  final String senderDept;

  final Map<String, dynamic> payload;

  final DateTime? createdAt;

  final bool isRead; //temp field
  final int userNotifyId;
  final List<UserNotificationModel>? userNotifications;

  NotificationModel({
    required this.notificationId,
    required this.title,
    required this.type,
    required this.targetType,
    required this.senderId,
    required this.senderName,
    required this.senderDept,
    required this.payload,
    this.createdAt,
    required this.isRead,
    required this.userNotifyId,
    this.userNotifications,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json["notificationId"] ?? 0,
      title: json["title"] ?? "",
      type: json["type"] ?? "",
      targetType: json["targetType"] ?? "",
      senderId: json["senderId"] ?? 0,
      senderName: json["senderName"] ?? "",
      senderDept: json["senderDept"] ?? "",
      payload: Map<String, dynamic>.from(json["payload"] ?? {}),
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,
      isRead: json["isRead"] ?? false,
      userNotifyId: json["userNotifyId"] ?? 0,
      userNotifications:
          json["userNotifications"] != null
              ? List<UserNotificationModel>.from(
                json["userNotifications"].map((x) => UserNotificationModel.fromJson(x)),
              )
              : null,
    );
  }
}
