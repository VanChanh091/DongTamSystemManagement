import 'package:intl/intl.dart';

class Customer {
  final String customerId;
  final String customerName;
  final String companyName;
  final String companyAddress;
  final String shippingAddress;
  final String mst;
  final String phone;
  final String cskh;
  final String? contactPerson;
  final DateTime? dayCreated;

  Customer({
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.companyAddress,
    required this.shippingAddress,
    required this.mst,
    required this.phone,
    required this.cskh,
    this.contactPerson,
    this.dayCreated,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 'CUSTOM',
      customerName: json['customerName'] ?? "",
      companyName: json['companyName'] ?? "",
      companyAddress: json['companyAddress'] ?? "",
      shippingAddress: json['shippingAddress'] ?? "",
      mst: json['mst'] ?? "",
      phone: json['phone'] ?? "",
      cskh: json['cskh'] ?? "",
      contactPerson: json['contactPerson'] ?? "",
      dayCreated:
          json['dayCreated'] != null && json['dayCreated'].toString().isNotEmpty
              ? DateTime.tryParse(json['dayCreated'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': customerId,
      'customerName': customerName,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'shippingAddress': shippingAddress,
      'mst': mst,
      'phone': phone,
      'cskh': cskh,
      "contactPerson": contactPerson,
      "dayCreated": DateFormat('yyyy-MM-dd').format(dayCreated!),
    };
  }
}
