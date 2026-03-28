import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:intl/intl.dart';

class CustomerPayment {
  final int cusPaymentId;
  final double? debtCurrent;
  final double? debtLimit;
  final DateTime? timePayment;
  final String? paymentType;
  final int closingDate;

  CustomerPayment({
    required this.cusPaymentId,
    this.debtCurrent,
    this.debtLimit,
    this.timePayment,
    this.paymentType,
    required this.closingDate,
  });

  factory CustomerPayment.fromJson(Map<String, dynamic> json) {
    return CustomerPayment(
      cusPaymentId: json['cusPaymentId'] ?? 0,
      debtCurrent: toDouble(json['debtCurrent']),
      debtLimit: toDouble(json['debtLimit']),
      timePayment:
          json['timePayment'] != null && json['timePayment'].toString().isNotEmpty
              ? DateTime.tryParse(json['timePayment'].toString())
              : null,
      paymentType: json['paymentType'] ?? "",
      closingDate: json['closingDate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'debtCurrent': debtCurrent,
      'debtLimit': debtLimit,
      'timePayment': DateFormat('yyyy-MM-dd').format(timePayment!),
      'paymentType': paymentType,
      'closingDate': closingDate,
    };
  }
}
