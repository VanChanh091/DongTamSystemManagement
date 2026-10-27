import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";

class PaymentAllocationModel {
  final int allocationId;
  final double amountAllocation;
  final String paymentMethod;
  final DateTime? createdAt;

  //association
  final int outboundId;
  final OutboundHistoryModel? outbound;

  PaymentAllocationModel({
    required this.allocationId,
    required this.amountAllocation,
    required this.paymentMethod,
    this.createdAt,

    //association
    required this.outboundId,
    this.outbound,
  });

  factory PaymentAllocationModel.fromJson(Map<String, dynamic> json) {
    return PaymentAllocationModel(
      allocationId: json["allocationId"] ?? 0,
      amountAllocation: toDouble(json["amountAllocation"]),
      paymentMethod: json["paymentMethod"] ?? "",
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"].toString()) : null,

      //association
      outboundId: json["outboundId"] ?? 0,
      outbound: json["outbound"] != null ? OutboundHistoryModel.fromJson(json["outbound"]) : null,
    );
  }
}
