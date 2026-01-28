import 'package:dongtam/data/models/customer/customer_model.dart';
import 'package:dongtam/data/models/order/box_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/product/product_model.dart';
import 'package:dongtam/data/models/user/user_user_model.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Order {
  final String orderId;
  final String? flute, QC_box, canLan;
  final String? day, matE, matB, matC, matE2, songE, songB, songC, songE2;
  final String? instructSpecial, rejectReason;
  final String daoXa, dvt, status;
  final double lengthPaperCustomer, lengthPaperManufacture;
  final double paperSizeCustomer, paperSizeManufacture;
  final double? discount, acreage, pricePaper, totalPrice, totalPriceVAT;
  final double profit, price;
  final int quantityCustomer, quantityManufacture;
  final int numberChild;
  final int? vat;
  final DateTime? dateRequestShipping;
  final DateTime dayReceiveOrder;
  final bool isBox;

  //temp field
  final int? remainingQty;

  //association
  final String customerId, productId;
  final Customer? customer;
  final Product? product;
  final Box? box;
  final UserUserModel? user;
  final List<PlanningPaper>? planningPaper;
  final InventoryModel? Inventory;

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
    this.acreage,
    required this.dvt,
    required this.price,
    this.pricePaper,
    this.discount,
    required this.profit,
    required this.dateRequestShipping,
    this.instructSpecial,
    this.vat,
    required this.status,
    this.rejectReason,
    this.totalPrice,
    this.totalPriceVAT,
    required this.isBox,

    this.remainingQty,

    this.customer,
    this.box,
    this.product,
    this.user,
    this.planningPaper,
    this.Inventory,
  });

  //format number
  static String formatCurrency(num value) {
    return NumberFormat("#,###.##").format(value);
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

  int getTotalByField(num? Function(PlanningPaper p) selector) {
    if (planningPaper == null || planningPaper!.isEmpty) return 0;

    return planningPaper!.fold<int>(0, (sum, p) => sum + (selector(p)?.toInt() ?? 0));
  }

  //listener
  static void listenerForFieldNeed(
    TextEditingController fieldController,
    TextEditingController fieldControllerReplace,
  ) {
    fieldController.addListener(() {
      if (fieldController.text != fieldControllerReplace.text) {
        fieldControllerReplace.text = fieldController.text;
      }
    });
  }

  // helper: only add prefix if not empty and not already present
  static String addPrefixIfNeeded(String value, String prefix) {
    value = value.trim().toUpperCase();
    if (value.isEmpty) return '';
    return value.startsWith(prefix) ? value : '$prefix$value';
  }

  // create a string after prefix
  static String generateOrderCode(String prefix) {
    if (prefix.contains('/D')) return prefix;

    final now = DateTime.now();
    final String month = now.month.toString().padLeft(2, '0');
    final String year = now.year.toString().substring(2);
    return "$prefix/$month/$year/D";
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
      dateRequestShipping:
          json['dateRequestShipping'] != null && json['dateRequestShipping'] != ''
              ? DateTime.tryParse(json['dateRequestShipping'])
              : null,
      instructSpecial: json['instructSpecial'] ?? "",
      isBox: json['isBox'] ?? false,
      status: json['status'] ?? "",
      rejectReason: json['rejectReason'] ?? "",

      remainingQty: json['remainingQty'] ?? 0,

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
      Inventory: json['Inventory'] != null ? InventoryModel.fromJson(json['Inventory']) : null,
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
      'dvt': dvt,
      'price': price,
      'pricePaper': pricePaper,
      'discount': discount,
      'profit': profit,
      'dateRequestShipping': DateFormat('yyyy-MM-dd').format(dateRequestShipping!),
      'instructSpecial': instructSpecial,
      "isBox": isBox,
      'status': status,
      "rejectReason": rejectReason,
      'vat': vat,
      'box': box?.toJson(),
    };
  }
}
