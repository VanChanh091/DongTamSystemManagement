import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class LiquidationInventoryModel {
  final int liquidationId;
  final int qtyTransferred;
  final int qtySold;
  final int qtyRemaining;
  final double liquidationValue;
  final String reason;
  final String status;

  //FK
  final int inventoryId;
  final String orderId;

  final Order? order;
  final InventoryModel? inventory;

  LiquidationInventoryModel({
    required this.liquidationId,
    required this.qtyTransferred,
    required this.qtySold,
    required this.qtyRemaining,
    required this.liquidationValue,
    required this.reason,
    required this.status,

    //FK
    required this.inventoryId,
    required this.orderId,
    this.order,
    this.inventory,
  });

  factory LiquidationInventoryModel.fromJson(Map<String, dynamic> json) {
    return LiquidationInventoryModel(
      liquidationId: json['liquidationId'] ?? 0,
      qtyTransferred: json['qtyTransferred'] ?? 0,
      qtySold: json['qtySold'] ?? 0,
      qtyRemaining: json['qtyRemaining'] ?? 0,
      liquidationValue: toDouble(json['liquidationValue']),
      reason: json['reason'] ?? "",
      status: json['status'] ?? "",

      //FK
      orderId: json['orderId'] ?? "",
      inventoryId: json['inventoryId'] ?? 0,

      inventory: json['Inventory'] != null ? InventoryModel.fromJson(json['Inventory']) : null,
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
