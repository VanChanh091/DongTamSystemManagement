import "package:dongtam/utils/helper/helper_model.dart";
import "package:dongtam/data/models/customer/customer_model.dart";
import "package:dongtam/data/models/warehouse/payment/payment_allocation_model.dart";

class PaymentReceiptModel {
  final int receiptId;
  final double amountPayment;
  final DateTime paymentDate;
  final String sourcePayment;

  //association
  final String customerId;
  final CustomerModel? Customer;
  final List<PaymentAllocationModel>? allocations;

  PaymentReceiptModel({
    required this.receiptId,
    required this.amountPayment,
    required this.paymentDate,
    required this.sourcePayment,

    //association
    required this.customerId,
    this.Customer,
    this.allocations,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) {
    return PaymentReceiptModel(
      receiptId: json["receiptId"] ?? 0,
      amountPayment: toDouble(json["amountPayment"]),
      paymentDate: DateTime.tryParse(json["paymentDate"].toString()) ?? DateTime.now(),
      sourcePayment: json["sourcePayment"] ?? "",

      //association
      customerId: json["customerId"] ?? "",
      Customer: json["Customer"] != null ? CustomerModel.fromJson(json["Customer"]) : null,
      allocations:
          json["allocations"] != null
              ? List<PaymentAllocationModel>.from(
                json["allocations"].map((x) => PaymentAllocationModel.fromJson(x)),
              )
              : [],
    );
  }
}
