import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String? QC_box;
  final String? canLan;
  final String? daoXa;
  final String? day;
  final String? middle_1;
  final String? middle_2;
  final String? mat;
  final String? songE;
  final String? songB;
  final String? songC;
  final String? songE2;
  final double lengthPaper;
  final double paperSize;
  final int quantity;
  final double acreage;
  final String dvt;
  final double price;
  final double pricePaper;
  final double totalPrice;
  final int? vat;
  final DateTime dayReceiveOrder;
  final DateTime dateRequestShipping;
  final String? instructSpecial;
  final String customerId;
  final String productId;

  final Customer? customer;
  final Product? product;
  final Box? box;

  Order({
    required this.orderId,
    required this.dayReceiveOrder,
    required this.customerId,
    required this.productId,
    this.QC_box,
    this.canLan,
    this.daoXa,
    this.day,
    this.middle_1,
    this.middle_2,
    this.mat,
    this.songE,
    this.songB,
    this.songC,
    this.songE2,
    required this.lengthPaper,
    required this.paperSize,
    required this.quantity,
    required this.acreage,
    required this.dvt,
    required this.price,
    required this.pricePaper,
    required this.dateRequestShipping,
    this.instructSpecial,
    this.vat,
    required this.totalPrice,
    this.customer,
    this.box,
    this.product,
  });

  //Acreage (m2) = lengthPaper * paperSize / 10000 * quantity
  static double acreagePaper(
    double lengthPaper,
    double paperSize,
    int quantity,
  ) {
    return lengthPaper *
        paperSize /
        10000 *
        double.parse(quantity.toStringAsFixed(2));
  }

  //Total price paper = (kg, cái) => price, else => lengthPaper * paperSize * price
  static double totalPricePaper(
    String dvt,
    double length,
    double size,
    double price,
  ) {
    dvt = dvt.trim();
    if (dvt == 'Kg' || dvt == 'Cái') {
      return price;
    }
    return length * size * price / 10000;
  }

  //Total price = quantity * pricePaper
  static double totalPriceOrder(int quantity, double pricePaper) {
    return pricePaper * double.parse(quantity.toStringAsFixed(1));
  }

  //format number
  static String formatCurrency(num value) {
    return NumberFormat("#,###.##").format(value);
  }

  String get formatterStructureOrder {
    final prefixes = ['', 'E', '', 'B', '', 'C', '', ''];
    final parts = [day, songE, middle_1, songB, middle_2, songC, mat, songE2];
    final formattedParts = <String>[];

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part != null && part.isNotEmpty) {
        final prefix = prefixes[i];
        if (!part.startsWith(prefix.replaceAll(r'[^A-Z]', ""))) {
          formattedParts.add('$prefix$part');
        } else {
          formattedParts.add(part);
        }
      }
    }
    return formattedParts.join('/');
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 'ORDER',
      customerId: json['customerId'] ?? 'CUSTOMER',
      productId: json['productId'] ?? "PRODUCT",
      dayReceiveOrder: DateTime.parse(json['dayReceiveOrder']),
      QC_box: json['QC_box'] ?? "",
      canLan: json['canLan'] ?? "",
      daoXa: json['daoXa'] ?? "",
      day: json['day'] ?? "",
      middle_1: json['middle_1'] ?? "",
      middle_2: json['middle_2'] ?? "",
      mat: json['mat'] ?? "",
      songE: json['songE'] ?? "",
      songB: json['songB'] ?? "",
      songC: json['songC'] ?? "",
      songE2: json['songE2'] ?? "",
      dvt: json['dvt'] ?? "",
      vat: json['vat'] ?? 0,
      quantity: json['quantity'] ?? 0,
      lengthPaper:
          (json['lengthPaper'] is int)
              ? (json['lengthPaper'] as int).toDouble()
              : (json['lengthPaper'] ?? 0.0) as double,
      paperSize:
          (json['paperSize'] is int)
              ? (json['paperSize'] as int).toDouble()
              : (json['paperSize'] ?? 0.0) as double,
      acreage:
          (json['acreage'] is int)
              ? (json['acreage'] as int).toDouble()
              : (json['acreage'] ?? 0.0) as double,
      price:
          (json['price'] is int)
              ? (json['price'] as int).toDouble()
              : (json['price'] ?? 0.0) as double,
      pricePaper:
          (json['pricePaper'] is int)
              ? (json['pricePaper'] as int).toDouble()
              : (json['pricePaper'] ?? 0.0) as double,
      totalPrice:
          (json['totalPrice'] is int)
              ? (json['totalPrice'] as int).toDouble()
              : (json['totalPrice'] ?? 0.0) as double,
      dateRequestShipping: DateTime.parse(json['dateRequestShipping']),
      instructSpecial: json['instructSpecial'] ?? "",
      customer:
          json['Customer'] != null ? Customer.fromJson(json['Customer']) : null,
      product:
          json['Product'] != null ? Product.fromJson(json['Product']) : null,
      box: json['box'] != null ? Box.fromJson(json['box']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': orderId,
      'customerId': customerId,
      'productId': productId,
      'dayReceiveOrder': DateFormat('yyyy-MM-dd').format(dayReceiveOrder),
      'QC_box': QC_box,
      'canLan': canLan,
      'daoXa': daoXa,
      'day': day,
      'middle_1': middle_1,
      'middle_2': middle_2,
      'mat': mat,
      'songE': songE,
      'songB': songB,
      'songC': songC,
      'songE2': songE2,
      'lengthPaper': lengthPaper,
      'paperSize': paperSize,
      'quantity': quantity,
      'acreage': acreage,
      'dvt': dvt,
      'price': price,
      'pricePaper': pricePaper,
      'dateRequestShipping': DateFormat(
        'yyyy-MM-dd',
      ).format(dateRequestShipping),
      'instructSpecial': instructSpecial,
      'vat': vat,
      'totalPrice': totalPrice,
      'box': box?.toJson(),
    };
  }
}
