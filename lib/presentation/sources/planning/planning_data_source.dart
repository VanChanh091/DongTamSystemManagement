import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class PlanningDataSource extends DataGridSource {
  List<Order> orders;
  String? selectedOrderId;
  bool selectedAll = false;

  late List<DataGridRow> orderDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  PlanningDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(Order order, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(
        columnName: 'dayReceiveOrder',
        value: formatter.format(order.dayReceiveOrder),
      ),
      DataGridCell<String>(
        columnName: 'dateRequestShipping',
        value: formatter.format(order.dateRequestShipping!),
      ),
      DataGridCell<String>(columnName: 'customerName', value: order.customer?.customerName ?? ''),
      DataGridCell<String>(columnName: 'typeProduct', value: order.product?.typeProduct ?? ''),
      DataGridCell<String>(columnName: 'productName', value: order.product?.productName ?? ''),
      DataGridCell<String>(columnName: 'flute', value: order.flute ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(columnName: 'structure', value: order.formatterStructureOrder),
      DataGridCell<String>(columnName: 'canLan', value: order.canLan ?? ''),
      DataGridCell<String>(columnName: 'daoXa', value: order.daoXa),
      DataGridCell<String>(
        columnName: 'sizeManu',
        value:
            order.paperSizeManufacture > 0
                ? '${Order.formatCurrency(order.paperSizeManufacture)} cm'
                : "0",
      ),
      DataGridCell<String>(
        columnName: 'lengthMf',
        value:
            order.lengthPaperManufacture > 0
                ? '${Order.formatCurrency(order.lengthPaperManufacture)} cm'
                : "0",
      ),
      DataGridCell<int>(columnName: 'qtyManufacture', value: order.quantityManufacture),
      DataGridCell<int>(
        columnName: 'runningPlan',
        value: order.totalQtyRunningPlan - order.totalQtyProduced,
      ),
      DataGridCell<int>(columnName: 'quantityProduced', value: order.totalQtyProduced),
      DataGridCell<String>(columnName: 'dvt', value: order.dvt),
      DataGridCell<String>(columnName: 'instructSpecial', value: order.instructSpecial ?? ""),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: order.totalPrice! > 0 ? '${Order.formatCurrency(order.totalPrice ?? 0)} VND' : '0',
      ),
      DataGridCell<String>(
        columnName: 'totalPriceAfterVAT',
        value:
            order.totalPriceVAT! > 0
                ? '${Order.formatCurrency(order.totalPriceVAT ?? 0)} VND'
                : "0",
      ),
      DataGridCell<bool>(columnName: 'haveMadeBox', value: order.isBox),
    ];
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  String formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["haveMadeBox"];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  void buildDataCell() {
    orderDataGridRows =
        orders.asMap().entries.map<DataGridRow>((entry) {
          int index = entry.key;
          return DataGridRow(cells: buildOrderCells(entry.value, index));
        }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = getCellValue<String>(row, 'orderId', '');

    Color backgroundColor = Colors.transparent;
    if (selectedOrderId == orderId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = formatCellValueBool(dataCell);

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
