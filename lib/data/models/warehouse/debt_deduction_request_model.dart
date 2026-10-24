import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/data/models/user/user_user_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class DebtDeductionRequestModel {
  final int requestId;
  final double amountRequested;
  final String paymentMethod;
  final String requestedBy;
  final String? approvedBy;
  final String? rejectReason;
  final bool isUrgent;
  final String status;
  final DateTime? createdAt;
  final double currentDebt;

  //FK
  final String customerId;
  final CustomerModel? Customer;

  final int userId;
  final UserUserModel? User;

  DebtDeductionRequestModel({
    required this.requestId,
    required this.amountRequested,
    required this.paymentMethod,
    required this.requestedBy,
    this.approvedBy,
    this.rejectReason,
    required this.isUrgent,
    required this.status,
    this.createdAt,
    this.currentDebt = 0,

    //FK
    required this.customerId,
    required this.Customer,
    required this.userId,
    required this.User,
  });

  factory DebtDeductionRequestModel.fromJson(Map<String, dynamic> json) {
    return DebtDeductionRequestModel(
      requestId: toInt(json["requestId"]),
      amountRequested: toDouble(json["amountRequested"]),
      paymentMethod: json["paymentMethod"] ?? "",
      requestedBy: json["requestedBy"] ?? "",
      approvedBy: json["approvedBy"] ?? "",
      rejectReason: json["rejectReason"] ?? "",
      isUrgent: json["isUrgent"] ?? false,
      status: json["status"] ?? "",
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,
      currentDebt: toDouble(json["currentDebt"]),

      //FK
      customerId: json["customerId"] ?? "",
      Customer: json["Customer"] != null ? CustomerModel.fromJson(json["Customer"]) : null,
      userId: toInt(json["userId"]),
      User: json["User"] != null ? UserUserModel.fromJson(json["User"]) : null,
    );
  }
}
