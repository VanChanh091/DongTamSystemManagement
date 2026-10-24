import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/inventory/inventory_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class InventoryDataSource extends DataGridSource {
  List<InventoryModel> inventory = [];
  List<int>? selectedInventoryId;
  int currentPage;
  int pageSize;

  late List<DataGridRow> inventoryDataGridRows;
  final formatter = DateFormat("dd/MM/yyyy");

  InventoryDataSource({
    required this.inventory,
    this.selectedInventoryId,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  @override
  List<DataGridRow> get rows => inventoryDataGridRows;

  List<DataGridCell> buildInventoryCells(InventoryModel inventory, int index) {
    final order = inventory.order;

    DataGridCell<num> buildCurrencyCell(String columnName, num value) {
      return DataGridCell<num>(columnName: columnName, value: value);
    }

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),

      DataGridCell<String>(columnName: "orderId", value: inventory.orderId),
      DataGridCell<String>(columnName: "customerName", value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "typeProduct", value: order?.product?.typeProduct ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),
      DataGridCell<bool>(columnName: "isFSC", value: order?.isFSC ?? false),

      DataGridCell<String>(columnName: "QcBox", value: order?.QC_box ?? ""),
      DataGridCell<String>(columnName: "flute", value: order?.flute != "0" ? order?.flute : "-"),
      DataGridCell<String>(columnName: "structure", value: order?.formatterStructureOrder ?? ""),

      buildCurrencyCell("size", order?.paperSizeManufacture ?? 0),
      buildCurrencyCell("length", order?.lengthPaperManufacture ?? 0),

      DataGridCell<int>(columnName: "totalQtyInbound", value: inventory.totalQtyInbound),
      DataGridCell<int>(columnName: "totalQtyOutbound", value: inventory.totalQtyOutbound),
      DataGridCell<int>(columnName: "qtyTransfer", value: inventory.getTotalQtyTransfer),
      DataGridCell<int>(columnName: "qtyInventory", value: inventory.qtyInventory),

      DataGridCell<String>(columnName: "dvt", value: order?.dvt ?? ""),
      DataGridCell<String>(
        columnName: "price",
        value: "${OrderModel.formatCurrency(order?.pricePaper ?? 0)} VNĐ",
      ),
      DataGridCell<String>(
        columnName: "valueInventory",
        value:
            inventory.valueInventory != 0
                ? "${OrderModel.formatCurrency(inventory.valueInventory)} VNĐ"
                : "-",
      ),

      DataGridCell<String>(columnName: "fullName", value: order?.user?.fullName ?? ""),

      //hidden
      DataGridCell<int>(columnName: "inventoryId", value: inventory.inventoryId),
    ];
  }

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    inventoryDataGridRows =
        inventory.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          final cells = buildInventoryCells(entry.value, globalIndex);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;

            String displayValue = "";
            Alignment alignment;

            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);
            } else if (["isFSC"].contains(dataCell.columnName)) {
              alignment = Alignment.center;
              displayValue = (value == true) ? "✅" : "";
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
