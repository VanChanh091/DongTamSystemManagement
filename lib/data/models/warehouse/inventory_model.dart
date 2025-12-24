import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/helper_model.dart';

class InventoryModel {
  final int inventoryId;
  final int totalQtyInbound;
  final int totalQtyOutbound;
  final int qtyInventory;
  final double valueInventory;

  final String orderId;
  final Order? order;

  InventoryModel({
    required this.inventoryId,
    required this.totalQtyInbound,
    required this.totalQtyOutbound,
    required this.qtyInventory,
    required this.valueInventory,

    required this.orderId,
    this.order,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json['inventoryId'] ?? 0,
      totalQtyInbound: json['totalQtyInbound'] ?? 0,
      totalQtyOutbound: json['totalQtyOutbound'] ?? 0,
      qtyInventory: json['qtyInventory'] ?? 0,
      valueInventory: toDouble(json['valueInventory']),

      orderId: json['orderId'] ?? "",
      order: json['Order'] != null ? Order.fromJson(json['Order']) : null,
    );
  }
}
