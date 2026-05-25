import 'package:dongtam/data/models/warehouse/inventory/inventory_model.dart';

class InventoryTransfersModel {
  final int transferId;
  final String sourceId;
  final String targetId;
  final int qtyTransfers;
  final String? reason;

  //FK
  final int inventoryId;
  final InventoryModel? inventory;

  InventoryTransfersModel({
    required this.transferId,
    required this.sourceId,
    required this.targetId,
    required this.qtyTransfers,
    this.reason,

    required this.inventoryId,
    this.inventory,
  });

  factory InventoryTransfersModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransfersModel(
      transferId: json['transferId'] ?? 0,
      sourceId: json['sourceId'] ?? "",
      targetId: json['targetId'] ?? "",
      qtyTransfers: json['qtyTransfers'] ?? 0,
      reason: json['reason'] ?? "",

      inventoryId: json['inventoryId'] ?? 0,
      inventory: json['Inventory'] != null ? InventoryModel.fromJson(json['Inventory']) : null,
    );
  }
}
