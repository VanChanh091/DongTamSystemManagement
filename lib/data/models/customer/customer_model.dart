import 'package:dongtam/data/models/customer/customer_payment_model.dart';
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
  final String customerSource;
  final DateTime? dayCreated;
  final String? rateCustomer;
  final DateTime? createdAt;

  final CustomerPayment? payment;

  Customer({
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
    this.dayCreated,
    this.rateCustomer,
    this.createdAt,

    this.payment,
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
      rateCustomer: json['rateCustomer'] ?? "",
      customerSource: json['customerSource'] ?? "",
      createdAt:
          json['createdAt'] != null && json['createdAt'].toString().isNotEmpty
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      payment: json['payment'] != null ? CustomerPayment.fromJson(json['payment']) : null,
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
      "rateCustomer": rateCustomer,
      "customerSource": customerSource,
      'payment': payment!.toJson(),
    };
  }
}
