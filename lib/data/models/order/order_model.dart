import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/order/info_production_model.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String customerId;
  final DateTime dayReceiveOrder;
  final String? typeProduct;
  final String? productName;
  final String? song;
  final String? QC_box;
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
  final DateTime dateRequestShipping;
  final double totalPrice;
  final int? vat;

  final Customer? customer;
  final InfoProduction? infoProduction;
  final Box? box;

  Order({
    required this.orderId,
    required this.dayReceiveOrder,
    required this.customerId,
    this.song,
    this.typeProduct,
    this.productName,
    this.QC_box,
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
    this.vat,
    required this.totalPrice,
    this.customer,
    this.infoProduction,
    this.box,
  });

  /// Diện tích giấy (m2) = lengthPaper * paperSize / 10000 * quantity
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

  // Tổng giá tấm = (kg, cái) => price, ngược lại => lengthPaper * paperSize * price
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

  //Tổng doanh thu = quantity * pricePaper
  static double totalPriceOrder(int quantity, double pricePaper) {
    return pricePaper * double.parse(quantity.toStringAsFixed(1));
  }

  static String formatCurrency(num value) {
    return NumberFormat("#,###.##").format(value);
  }

  String get formatterStructureOrder {
    final parts = [
      day,
      songE,
      middle_1,
      songB,
      middle_2,
      songC,
      mat,
      if (songE2 != null && songE2!.isNotEmpty) songE2,
    ];

    return parts
        .where((e) => e != null && e.isNotEmpty)
        .map((e) => e!)
        .join('/');
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'] ?? 'CUSTOM',
      customerId: json['customerId'],
      dayReceiveOrder: DateTime.parse(json['dayReceiveOrder']),
      song: json['song'] ?? "",
      typeProduct: json['typeProduct'] ?? "",
      productName: json['productName'] ?? "",
      QC_box: json['QC_box'] ?? "",
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

      customer:
          json['Customer'] != null ? Customer.fromJson(json['Customer']) : null,
      infoProduction:
          json['infoProduction'] != null
              ? InfoProduction.fromJson(json['infoProduction'])
              : null,
      box: json['box'] != null ? Box.fromJson(json['box']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': orderId,
      'customerId': customerId,
      'dayReceiveOrder': DateFormat('yyyy-MM-dd').format(dayReceiveOrder),
      'typeProduct': typeProduct,
      'productName': productName,
      'song': song,
      'QC_box': QC_box,
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
      'vat': vat,
      'totalPrice': totalPrice,
      'infoProduction': infoProduction?.toJson(),
      'box': box?.toJson(),
    };
  }

  @override
  String toString() {
    return '''
Order(
  orderId: $orderId,
  customerId: $customerId,
  customerName: ${customer?.customerName ?? 'N/A'},
  companyName: ${customer?.companyName ?? 'N/A'},
  productName: $productName,
  typeProduct: $typeProduct,
  song: $song,
  QC_box: $QC_box,
  day: ${day ?? 'N/A'},
  middle_1: ${middle_1 ?? 'N/A'},
  middle_2: ${middle_2 ?? 'N/A'},
  mat: ${mat ?? 'N/A'},
  songE: ${songE ?? 'N/A'},
  songB: ${songB ?? 'N/A'},
  songC: ${songC ?? 'N/A'},
  songE2: ${songE2 ?? 'N/A'},
  quantity: $quantity,
  lengthPaper: $lengthPaper,
  paperSize: $paperSize,
  acreagePaper: $acreagePaper($lengthPaper, $paperSize, $quantity),
  dvt: $dvt,
  price: $price,
  pricePaper: $pricePaper,
  totalPrice: $totalPricePaper($dvt, $price, $lengthPaper, $paperSize),
  vat: $vat,
  dayReceiveOrder: ${dayReceiveOrder.toIso8601String()},
  dateRequestShipping: ${dateRequestShipping.toIso8601String()}
)
''';
  }
}
