import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/inventory/inventory_transfers.dart";
import "package:dongtam/data/models/warehouse/inventory/liquidation_inventory_model.dart";
import "package:dongtam/utils/helper/helper_model.dart";

class InventoryModel {
  final int inventoryId;
  final int totalQtyInbound;
  final int totalQtyOutbound;
  final int qtyInventory;
  final int? qtyVariance;
  final double valueInventory;

  //FK
  final String orderId;
  final Order? order;

  final List<InventoryTransfersModel>? invTransfers;
  final LiquidationInventoryModel? liquidation;

  InventoryModel({
    required this.inventoryId,
    required this.totalQtyInbound,
    required this.totalQtyOutbound,
    required this.qtyInventory,
    required this.valueInventory,
    this.qtyVariance,

    required this.orderId,
    this.order,
    this.invTransfers,
    this.liquidation,
  });

  int get getTotalQtyTransfer => invTransfers?.fold(0, (sum, e) => sum! + e.qtyTransfers) ?? 0;

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      inventoryId: json["inventoryId"] ?? 0,
      totalQtyInbound: json["totalQtyInbound"] ?? 0,
      totalQtyOutbound: json["totalQtyOutbound"] ?? 0,
      qtyInventory: json["qtyInventory"] ?? 0,
      qtyVariance: json["qtyVariance"] ?? 0,
      valueInventory: toDouble(json["valueInventory"]),

      orderId: json["orderId"] ?? "",
      order: json["Order"] != null ? Order.fromJson(json["Order"]) : null,

      invTransfers:
          json["invTransfers"] != null
              ? List<InventoryTransfersModel>.from(
                json["invTransfers"].map((x) => InventoryTransfersModel.fromJson(x)),
              )
              : [],
      liquidation:
          json["liquidation"] != null
              ? LiquidationInventoryModel.fromJson(json["liquidation"])
              : null,
    );
  }
}
