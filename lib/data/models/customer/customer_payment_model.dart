import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class CustomerPaymentModel {
  final int cusPaymentId;
  final double? debtCurrent;
  final double? debtLimit;
  final String? paymentType;
  final List<int>? closingDays;
  final int paymentTermDays;

  //FK
  final String customerId;
  final CustomerModel? customer;

  CustomerPaymentModel({
    required this.cusPaymentId,
    this.debtCurrent,
    this.debtLimit,
    this.paymentType,
    this.closingDays,
    required this.paymentTermDays,

    //FK
    required this.customerId,
    this.customer,
  });

  factory CustomerPaymentModel.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentModel(
      cusPaymentId: json["cusPaymentId"] ?? 0,
      debtCurrent: toDouble(json["debtCurrent"]),
      debtLimit: toDouble(json["debtLimit"]),
      paymentType: json["paymentType"] ?? "",
      closingDays: json["closingDays"] != null ? List<int>.from(json["closingDays"]) : null,
      paymentTermDays: json["paymentTermDays"] ?? 0,
      customerId: json["customerId"] ?? "",
      customer: json["Customer"] != null ? CustomerModel.fromJson(json["Customer"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "paymentType": paymentType,
      "debtLimit": debtLimit,
      "closingDays": closingDays,
      "paymentTermDays": paymentTermDays,
    };
  }
}
