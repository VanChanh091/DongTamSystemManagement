import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
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
  final double lengthPaperCustomer;
  final double lengthPaperManufacture;
  final double paperSizeCustomer;
  final double paperSizeManufacture;
  final int quantityCustomer;
  final int quantityManufacture;
  final double acreage;
  final String dvt;
  final double price;
  final double pricePaper;
  final double? discount;
  final double profit;
  final double totalPrice;
  final int? vat;
  final DateTime dayReceiveOrder;
  final DateTime dateRequestShipping;
  final String? instructSpecial;
  final String status;
  final String? rejectReason;

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
    required this.lengthPaperCustomer,
    required this.lengthPaperManufacture,
    required this.paperSizeCustomer,
    required this.paperSizeManufacture,
    required this.quantityCustomer,
    required this.quantityManufacture,
    required this.acreage,
    required this.dvt,
    required this.price,
    required this.pricePaper,
    this.discount,
    required this.profit,
    required this.dateRequestShipping,
    this.instructSpecial,
    this.vat,
    required this.status,
    this.rejectReason,
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
      quantityCustomer: json['quantityCustomer'] ?? 0,
      quantityManufacture: json['quantityManufacture'] ?? 0,
      lengthPaperCustomer: toDouble(json['lengthPaperCustomer']),
      lengthPaperManufacture: toDouble(json['lengthPaperManufacture']),
      paperSizeCustomer: toDouble(json['paperSizeCustomer']),
      paperSizeManufacture: toDouble(json['paperSizeManufacture']),
      acreage: toDouble(json['acreage']),
      price: toDouble(json['price']),
      pricePaper: toDouble(json['pricePaper']),
      discount: toDouble(json['discount']),
      profit: toDouble(json['profit']),
      totalPrice: toDouble(json['totalPrice']),
      dateRequestShipping: DateTime.parse(json['dateRequestShipping']),
      instructSpecial: json['instructSpecial'] ?? "",
      status: json['status'] ?? "",
      rejectReason: json['rejectReason'] ?? "",
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
      'lengthPaperCustomer': lengthPaperCustomer,
      'lengthPaperManufacture': lengthPaperManufacture,
      'paperSizeCustomer': paperSizeCustomer,
      'paperSizeManufacture': paperSizeManufacture,
      'quantityCustomer': quantityCustomer,
      'quantityManufacture': quantityManufacture,
      'acreage': acreage,
      'dvt': dvt,
      'price': price,
      'pricePaper': pricePaper,
      'discount': discount,
      'profit': profit,
      'dateRequestShipping': DateFormat(
        'yyyy-MM-dd',
      ).format(dateRequestShipping),
      'instructSpecial': instructSpecial,
      'status': status,
      "rejectReason": rejectReason,
      'vat': vat,
      'totalPrice': totalPrice,
      'box': box?.toJson(),
    };
  }
}
