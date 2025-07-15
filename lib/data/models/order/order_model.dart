import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String? flute, QC_box, canLan;
  final String? day, matE, matB, matC, songE, songB, songC, songE2;
  final String? instructSpecial, rejectReason;
  final String daoXa, dvt, status;
  final double lengthPaperCustomer, lengthPaperManufacture;
  final double paperSizeCustomer, paperSizeManufacture;
  final double? discount;
  final double acreage, profit, totalPrice, price, pricePaper;
  final int quantityCustomer, quantityManufacture;
  final int numberChild;
  final int? vat;
  final DateTime dayReceiveOrder, dateRequestShipping;

  final String customerId, productId;
  final Customer? customer;
  final Product? product;
  final Box? box;

  Order({
    required this.orderId,
    required this.dayReceiveOrder,
    required this.customerId,
    required this.productId,
    this.flute,
    this.QC_box,
    this.canLan,
    required this.daoXa,
    this.day,
    this.matE,
    this.matB,
    this.matC,
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
    required this.numberChild,
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

  // String get formatterStructureOrder {
  //   final prefixes = ['', 'E', '', 'B', '', 'C', '', ''];
  //   final parts = [day, songE, matE, songB, matB, songC, matC, songE2];
  //   final formattedParts = <String>[];

  //   for (int i = 0; i < parts.length; i++) {
  //     final part = parts[i];
  //     if (part != null && part.isNotEmpty) {
  //       final prefix = prefixes[i];
  //       if (!part.startsWith(prefix.replaceAll(r'[^A-Z]', ""))) {
  //         formattedParts.add('$prefix$part');
  //       } else {
  //         formattedParts.add(part);
  //       }
  //     }
  //   }
  //   return formattedParts.join('/');
  // }

  String get formatterStructureOrder {
    final parts = [day, songE, matE, songB, matB, songC, matC, songE2];
    final formattedParts = <String>[];

    for (final part in parts) {
      if (part != null && part.isNotEmpty) {
        formattedParts.add(part);
      }
    }

    return formattedParts.join('/');
  }

  //calculate flute
  static String flutePaper(
    String day,
    String middle_1,
    String middle_2,
    String mat,
    String songE,
    String songB,
    String songC,
    String songE2,
  ) {
    final layers =
        [
          day,
          middle_1,
          middle_2,
          mat,
          songE,
          songB,
          songC,
          songE2,
        ].where((e) => e.trim().isNotEmpty).toList();

    // Thu thập sóng (có thể trùng)
    final flutesRaw = <String>[];
    if (songE.trim().isNotEmpty) flutesRaw.add('E');
    if (songB.trim().isNotEmpty) flutesRaw.add('B');
    if (songC.trim().isNotEmpty) flutesRaw.add('C');
    if (songE2.trim().isNotEmpty) flutesRaw.add('E');

    // Sắp xếp theo thứ tự E -> B -> C và loại trùng
    const fluteOrder = ['E', 'B', 'C'];
    final uniqueFlutes =
        fluteOrder.where((f) => flutesRaw.contains(f)).toList();

    return '${layers.length}${uniqueFlutes.join()}';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 'ORDER',
      customerId: json['customerId'] ?? 'CUSTOMER',
      productId: json['productId'] ?? "PRODUCT",
      dayReceiveOrder: DateTime.parse(json['dayReceiveOrder']),
      flute: json['flute'] ?? "",
      QC_box: json['QC_box'] ?? "",
      canLan: json['canLan'] ?? "",
      daoXa: json['daoXa'] ?? "",
      day: json['day'] ?? "",
      matE: json['matE'] ?? "",
      matB: json['matB'] ?? "",
      matC: json['matC'] ?? "",
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
      numberChild: json['numberChild'] ?? 0,
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
      'flute': flute,
      'QC_box': QC_box,
      'canLan': canLan,
      'daoXa': daoXa,
      'day': day,
      'matE': matE,
      'matB': matB,
      'matC': matC,
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
      'numberChild': numberChild,
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
