import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/data/models/customer/customer_payment_model.dart";
import "package:dongtam/data/models/warehouse/payment/payment_receipt_model.dart";
import "package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart";

class CustomerModel {
  final String customerId;
  final String customerName;
  final String companyName;
  final String companyAddress;
  final String shippingAddress;
  final double? distance;
  final String mst;
  final String phone;
  final String cskh;
  final String? contactPerson;
  final String customerSource;
  final String? rateCustomer;
  final DateTime? createdAt;

  //FK
  final int? userId;
  final CustomerPaymentModel? payment;
  final List<OutboundHistoryModel>? outboundHistory;
  final List<PaymentReceiptModel>? PaymentReceipt;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.companyAddress,
    required this.shippingAddress,
    required this.customerSource,
    required this.mst,
    required this.phone,
    required this.cskh,
    this.contactPerson,
    this.distance,
    this.rateCustomer,
    this.createdAt,

    //FK
    this.userId,
    this.payment,
    this.outboundHistory,
    this.PaymentReceipt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json["customerId"] ?? "CUSTOM",
      customerName: json["customerName"] ?? "",
      companyName: json["companyName"] ?? "",
      companyAddress: json["companyAddress"] ?? "",
      shippingAddress: json["shippingAddress"] ?? "",
      distance: toDouble(json["distance"]),
      mst: json["mst"] ?? "",
      phone: json["phone"] ?? "",
      cskh: json["cskh"] ?? "",
      contactPerson: json["contactPerson"] ?? "",
      rateCustomer: json["rateCustomer"] ?? "",
      customerSource: json["customerSource"] ?? "",
      userId: json["userId"] ?? 0,
      createdAt:
          json["createdAt"] != null && json["createdAt"].toString().isNotEmpty
              ? DateTime.tryParse(json["createdAt"].toString())
              : null,
      payment: json["payment"] != null ? CustomerPaymentModel.fromJson(json["payment"]) : null,
      outboundHistory:
          json["OutboundHistory"] != null
              ? List<OutboundHistoryModel>.from(
                json["OutboundHistory"].map((x) => OutboundHistoryModel.fromJson(x)),
              )
              : [],
      PaymentReceipt:
          json["PaymentReceipt"] != null
              ? List<PaymentReceiptModel>.from(
                json["PaymentReceipt"].map((x) => PaymentReceiptModel.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "prefix": customerId,
      "customerName": customerName,
      "companyName": companyName,
      "companyAddress": companyAddress,
      "shippingAddress": shippingAddress,
      "distance": distance,
      "mst": mst,
      "phone": phone,
      "cskh": cskh,
      "contactPerson": contactPerson,
      "rateCustomer": rateCustomer,
      "customerSource": customerSource,
      "userId": userId,
      "payment": payment!.toJson(),
    };
  }
}
