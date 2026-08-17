import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class OutboundHistoryModel {
  final int outboundId;
  final DateTime dateOutbound;
  final String outboundSlipCode;

  final double totalPriceOrder;
  final double? totalPriceVAT;
  final double totalPricePayment;
  final int totalOutboundQty;

  final double? paidAmount;
  final double? remainingAmount;

  final String outboundBy;
  final String? updatedBy;

  final DateTime? dueDate;
  final String status;

  final double? writeOffAmount;

  //FK
  final List<OutboundDetailModel>? detail;

  final String customerId;
  final CustomerModel? customer;

  OutboundHistoryModel({
    required this.outboundId,
    required this.dateOutbound,
    required this.outboundSlipCode,

    required this.totalPriceOrder,
    this.totalPriceVAT,
    required this.totalPricePayment,
    required this.totalOutboundQty,

    this.paidAmount,
    this.remainingAmount,

    required this.outboundBy,
    this.updatedBy,

    this.dueDate,
    required this.status,

    this.writeOffAmount,

    required this.customerId,
    this.customer,
    this.detail,
  });

  factory OutboundHistoryModel.fromJson(Map<String, dynamic> json) {
    return OutboundHistoryModel(
      outboundId: json["outboundId"],
      dateOutbound: DateTime.parse(json["dateOutbound"]),
      outboundSlipCode: json["outboundSlipCode"] ?? "",
      totalPriceOrder: toDouble(json["totalPriceOrder"]),
      totalPriceVAT: toDouble(json["totalPriceVAT"]),
      totalPricePayment: toDouble(json["totalPricePayment"]),
      totalOutboundQty: json["totalOutboundQty"] ?? 0,
      dueDate: json["dueDate"] != null ? DateTime.parse(json["dueDate"]) : null,
      paidAmount: toDouble(json["paidAmount"]),
      remainingAmount: toDouble(json["remainingAmount"]),
      outboundBy: json["outboundBy"] ?? "",
      status: json["status"] ?? "",
      writeOffAmount: toDouble(json["writeOffAmount"]),

      detail:
          json["detail"] != null
              ? List<OutboundDetailModel>.from(
                json["detail"].map((x) => OutboundDetailModel.fromJson(x)),
              )
              : [],
      customerId: json["customerId"] ?? "",
      customer: json["customer"] != null ? CustomerModel.fromJson(json["customer"]) : null,
    );
  }
}
