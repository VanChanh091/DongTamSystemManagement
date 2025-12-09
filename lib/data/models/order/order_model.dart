import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/data/models/user/user_user_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String? flute, QC_box, canLan;
  final String? day, matE, matB, matC, matE2, songE, songB, songC, songE2;
  final String? instructSpecial, rejectReason;
  final String daoXa, dvt, status;
  final double lengthPaperCustomer, lengthPaperManufacture;
  final double paperSizeCustomer, paperSizeManufacture;
  final double? discount;
  final double acreage, profit, price, pricePaper, totalPrice, totalPriceVAT;
  final int quantityCustomer, quantityManufacture;
  final int numberChild;
  final int? vat;
  final DateTime dayReceiveOrder, dateRequestShipping;
  final bool isBox;

  //association
  final String customerId, productId;
  final Customer? customer;
  final Product? product;
  final Box? box;
  final UserUserModel? user;
  final List<PlanningPaper>? planningPaper;

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
    this.matE2,
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
    required this.totalPriceVAT,
    required this.isBox,

    this.customer,
    this.box,
    this.product,
    this.user,
    this.planningPaper,
  });

  //format number
  static String formatCurrency(num value) {
    return NumberFormat("#,###.##").format(value);
  }

  //Acreage (m2) = lengthPaper * paperSize / 10000 * quantity
  static double acreagePaper({
    required double lengthPaper,
    required double paperSize,
    required int quantity,
  }) {
    return lengthPaper * paperSize / 10000 * double.parse(quantity.toStringAsFixed(2));
  }

  //Total price paper = (kg, cái) => price, else => lengthPaper * paperSize * price
  static double totalPricePaper({
    required String dvt,
    required double length,
    required double size,
    required double price,
    double pricePaper = 0,
  }) {
    if (dvt == 'M2' || dvt == 'Tấm') {
      return length * size * price / 10000;
    } else if (dvt == 'Tấm Bao Khổ') {
      return pricePaper;
    }
    return price;
  }

  //Total price = quantity * pricePaper
  static double totalPriceOrder({required int quantity, required double pricePaper}) {
    return pricePaper * double.parse(quantity.toStringAsFixed(1));
  }

  static double totalPriceAfterVAT({required double totalPrice, required int vat}) {
    if (vat == 0) {
      return totalPrice;
    }
    return totalPrice * (1 + (vat / 100));
  }

  String get formatterStructureOrder {
    final parts = [day, songE, matE, songB, matB, songC, matC, songE2, matE2];
    final formattedParts = <String>[];

    for (final part in parts) {
      if (part != null && part.isNotEmpty) {
        formattedParts.add(part);
      }
    }

    return formattedParts.join('/');
  }

  //calculate flute
  static String flutePaper({
    required String day,
    required String matE,
    required String matB,
    required String matC,
    required String matE2,
    required String songE,
    required String songB,
    required String songC,
    required String songE2,
  }) {
    final layers =
        [
          day,
          matE,
          matB,
          matC,
          matE2,
          songE,
          songB,
          songC,
          songE2,
        ].where((e) => e.trim().isNotEmpty).toList();

    // Thu thập sóng theo thứ tự ưu tiên thực tế
    final flutesRaw = <String>[];
    if (songE.trim().isNotEmpty) flutesRaw.add('E');
    if (songB.trim().isNotEmpty) flutesRaw.add('B');
    if (songC.trim().isNotEmpty) flutesRaw.add('C');
    if (songE2.trim().isNotEmpty) flutesRaw.add('E');

    const fluteOrder = ['E', 'B', 'C'];

    final sortedFlutes = <String>[];
    for (final f in fluteOrder) {
      sortedFlutes.addAll(flutesRaw.where((x) => x == f));
    }

    return '${layers.length}${sortedFlutes.join()}';
  }

  int getTotalByField(num? Function(PlanningPaper p) selector) {
    if (planningPaper == null || planningPaper!.isEmpty) return 0;

    return planningPaper!.fold<int>(0, (sum, p) => sum + (selector(p)?.toInt() ?? 0));
  }

  int get totalQtyProduced => getTotalByField((p) => p.qtyProduced);
  int get totalQtyRunningPlan => getTotalByField((p) => p.runningPlan);

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
      matE2: json['matE2'] ?? "",
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
      totalPriceVAT: toDouble(json['totalPriceVAT']),
      dateRequestShipping: DateTime.parse(json['dateRequestShipping']),
      instructSpecial: json['instructSpecial'] ?? "",
      isBox: json['isBox'] ?? false,
      status: json['status'] ?? "",
      rejectReason: json['rejectReason'] ?? "",
      customer: json['Customer'] != null ? Customer.fromJson(json['Customer']) : null,
      product: json['Product'] != null ? Product.fromJson(json['Product']) : null,
      box: json['box'] != null ? Box.fromJson(json['box']) : null,
      user: json['User'] != null ? UserUserModel.fromJson(json['User']) : null,
      planningPaper:
          json['PlanningPapers'] != null
              ? List<PlanningPaper>.from(
                json['PlanningPapers'].map((x) => PlanningPaper.fromJson(x)),
              )
              : [],
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
      'matE2': matE2,
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
      'dateRequestShipping': DateFormat('yyyy-MM-dd').format(dateRequestShipping),
      'instructSpecial': instructSpecial,
      "isBox": isBox,
      'status': status,
      "rejectReason": rejectReason,
      'vat': vat,
      'totalPrice': totalPrice,
      'totalPriceVAT': totalPriceVAT,
      'box': box?.toJson(),
    };
  }
}
