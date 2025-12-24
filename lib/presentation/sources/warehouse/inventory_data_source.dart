import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/inventory_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InventoryDataSource extends DataGridSource {
  List<InventoryModel> inventory = [];
  List<int>? selectedInventoryId;

  late List<DataGridRow> inventoryDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  InventoryDataSource({required this.inventory, this.selectedInventoryId}) {
    buildDataGridRows();
  }

  @override
  List<DataGridRow> get rows => inventoryDataGridRows;

  List<DataGridCell> buildReportInfoCells(InventoryModel inventory) {
    final order = inventory.order;

    return [
      DataGridCell<String>(columnName: 'orderId', value: inventory.orderId),
      DataGridCell<String>(columnName: 'flute', value: order?.flute ?? ""),
      DataGridCell<String>(columnName: 'structure', value: order?.formatterStructureOrder ?? ""),
      DataGridCell<String>(
        columnName: 'length',
        value:
            ((order?.lengthPaperCustomer ?? 0) > 0)
                ? '${Order.formatCurrency(order?.lengthPaperCustomer ?? 0)} cm'
                : '0',
      ),
      DataGridCell<String>(
        columnName: 'size',
        value:
            ((order?.paperSizeCustomer ?? 0) > 0)
                ? '${Order.formatCurrency(order?.paperSizeCustomer ?? 0)} cm'
                : '0',
      ),
      DataGridCell<int>(columnName: 'qtyCustomer', value: order?.quantityCustomer ?? 0),
      DataGridCell<String>(columnName: 'dvt', value: order?.dvt ?? ""),
      DataGridCell<String>(
        columnName: 'price',
        value: '${Order.formatCurrency(order?.price ?? 0)} VNĐ',
      ),
      DataGridCell<String>(columnName: 'vat', value: '${order?.vat ?? 0}%'),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(order?.totalPrice ?? 0)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: 'totalPriceVAT',
        value: '${Order.formatCurrency(order?.totalPriceVAT ?? 0)} VNĐ',
      ),
      DataGridCell<int>(columnName: 'totalQtyInbound', value: inventory.totalQtyInbound),
      DataGridCell<int>(columnName: 'totalQtyOutbound', value: inventory.totalQtyOutbound),
      DataGridCell<int>(columnName: 'qtyInventory', value: inventory.qtyInventory),
      DataGridCell<String>(
        columnName: 'valueInventory',
        value: '${Order.formatCurrency(inventory.valueInventory)} VNĐ',
      ),

      //hidden
      DataGridCell<int>(columnName: 'inventoryId', value: inventory.inventoryId),
    ];
  }

  void buildDataGridRows() {
    inventoryDataGridRows =
        inventory.map<DataGridRow>((inventory) {
          final cells = buildReportInfoCells(inventory);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final inventoryId = row.getCells().firstWhere((cell) => cell.columnName == 'inventoryId').value;
    final isSelected = selectedInventoryId?.contains(inventoryId);

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
