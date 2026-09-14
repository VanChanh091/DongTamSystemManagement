import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory/liquidation_inventory_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LiquidationInvDataSource extends DataGridSource {
  List<LiquidationInventoryModel> liquidations = [];
  List<int>? selectedLiquidationId;
  int currentPage;
  int pageSize;

  late List<DataGridRow> liquidationDataGridRows;

  LiquidationInvDataSource({
    required this.liquidations,
    this.selectedLiquidationId,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  @override
  List<DataGridRow> get rows => liquidationDataGridRows;

  String formatStatus(String status) {
    if (status == 'pending') {
      return 'Chờ xử lý';
    } else if (status == 'selling') {
      return "Thanh lý 1 phần";
    } else if (status == 'completed') {
      return "Đã thanh lý";
    } else if (status == 'cancelled') {
      return "Đã hủy";
    }
    return "Chờ xử lý";
  }

  List<DataGridCell> buildLiquidationInvCells(LiquidationInventoryModel liquidation, int index) {
    final order = liquidation.order;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: liquidation.orderId),
      DataGridCell<String>(columnName: 'customerName', value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: 'productName', value: order?.product?.productName ?? ""),
      DataGridCell<String>(columnName: 'flute', value: order?.flute != "0" ? order?.flute : "-"),
      DataGridCell<String>(columnName: 'structure', value: order?.formatterStructureOrder ?? ""),

      DataGridCell<double>(columnName: 'size', value: order?.paperSizeCustomer ?? 0),
      DataGridCell<double>(columnName: 'length', value: order?.lengthPaperCustomer ?? 0),

      DataGridCell<String>(columnName: 'dvt', value: order?.dvt ?? ""),

      DataGridCell<int>(columnName: 'qtyTransferred', value: liquidation.qtyTransferred),
      DataGridCell<int>(columnName: 'qtySold', value: liquidation.qtySold),
      DataGridCell<int>(columnName: 'qtyRemaining', value: liquidation.qtyRemaining),

      DataGridCell<double>(columnName: 'liquidationValue', value: liquidation.liquidationValue),
      DataGridCell<String>(columnName: 'reason', value: liquidation.reason),
      DataGridCell<String>(columnName: 'status', value: formatStatus(liquidation.status)),

      //hidden
      DataGridCell<int>(columnName: 'liquidationId', value: liquidation.liquidationId),
    ];
  }

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    liquidationDataGridRows =
        liquidations.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          final cells = buildLiquidationInvCells(entry.value, globalIndex);

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
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
