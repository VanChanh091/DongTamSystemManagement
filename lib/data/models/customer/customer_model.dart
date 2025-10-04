import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:intl/intl.dart';

class Customer {
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
  final DateTime? dayCreated;
  final double? debtCurrent;
  final double? debtLimit;
  final DateTime? timePayment;
  final String? rateCustomer;

  Customer({
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.companyAddress,
    required this.shippingAddress,
    this.distance,
    required this.mst,
    required this.phone,
    required this.cskh,
    this.contactPerson,
    this.dayCreated,
    this.debtCurrent,
    required this.debtLimit,
    this.timePayment,
    required this.rateCustomer,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 'CUSTOM',
      customerName: json['customerName'] ?? "",
      companyName: json['companyName'] ?? "",
      companyAddress: json['companyAddress'] ?? "",
      shippingAddress: json['shippingAddress'] ?? "",
      distance: toDouble(json['distance']),
      mst: json['mst'] ?? "",
      phone: json['phone'] ?? "",
      cskh: json['cskh'] ?? "",
      contactPerson: json['contactPerson'] ?? "",
      dayCreated:
          json['dayCreated'] != null && json['dayCreated'].toString().isNotEmpty
              ? DateTime.tryParse(json['dayCreated'].toString())
              : null,
      debtCurrent: toDouble(json['debtCurrent']),
      debtLimit: toDouble(json['debtLimit']),
      timePayment:
          json['timePayment'] != null &&
                  json['timePayment'].toString().isNotEmpty
              ? DateTime.tryParse(json['timePayment'].toString())
              : null,
      rateCustomer: json['rateCustomer'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': customerId,
      'customerName': customerName,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'shippingAddress': shippingAddress,
      'distance': distance,
      'mst': mst,
      'phone': phone,
      'cskh': cskh,
      "contactPerson": contactPerson,
      "dayCreated": DateFormat('yyyy-MM-dd').format(dayCreated!),
      "debtLimit": debtLimit,
      "timePayment": DateFormat('yyyy-MM-dd').format(timePayment!),
      "rateCustomer": rateCustomer,
    };
  }
}
