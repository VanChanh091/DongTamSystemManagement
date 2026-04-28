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
      DataGridCell<String>(columnName: 'flute', value: order?.flute ?? ""),
      DataGridCell<String>(columnName: 'structure', value: order?.formatterStructureOrder ?? ""),
      DataGridCell<String>(
        columnName: 'size',
        value:
            order?.paperSizeCustomer != null && order!.paperSizeCustomer > 0
                ? "${order.paperSizeCustomer} cm"
                : "0",
      ),
      DataGridCell<String>(
        columnName: 'length',
        value:
            order?.lengthPaperCustomer != null && order!.lengthPaperCustomer > 0
                ? "${order.lengthPaperCustomer} cm"
                : "0",
      ),
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
    final liquidationId =
        row.getCells().firstWhere((cell) => cell.columnName == 'liquidationId').value;
    final isSelected = selectedLiquidationId?.contains(liquidationId);

    Color backgroundColor;
    if (isSelected == true) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: dataCell.value?.toString() ?? "", alignment: alignment);
          }).toList(),
    );
  }
}
