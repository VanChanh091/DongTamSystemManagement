class Customer {
  final String customerId,
      customerName,
      companyName,
      companyAddress,
      shippingAddress,
      mst,
      phone,
      cskh;

  Customer({
    required this.customerId,
    required this.customerName,
    required this.companyName,
    required this.companyAddress,
    required this.shippingAddress,
    required this.mst,
    required this.phone,
    required this.cskh,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'],
      customerName: json['customerName'],
      companyName: json['companyName'],
      companyAddress: json['companyAddress'],
      shippingAddress: json['shippingAddress'],
      mst: json['mst'],
      phone: json['phone'],
      cskh: json['cskh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'shippingAddress': shippingAddress,
      'mst': mst,
      'phone': phone,
      'cskh': cskh,
    };
  }
}
