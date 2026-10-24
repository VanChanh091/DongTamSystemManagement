import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";
import "package:intl/intl.dart";

class PlanningDataSource extends DataGridSource {
  List<OrderModel> orders;
  String? selectedOrderId;
  bool selectedAll = false;

  late List<DataGridRow> orderDataGridRows;
  final formatter = DateFormat("dd/MM/yyyy");

  PlanningDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(OrderModel order, int index) {
    DataGridCell<String> buildDateCell({required String columnName, DateTime? value}) {
      return DataGridCell<String>(
        columnName: columnName,
        value: value != null ? formatter.format(value) : "",
      );
    }

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: order.orderId),

      buildDateCell(columnName: "dayReceiveOrder", value: order.dayReceiveOrder!),
      buildDateCell(columnName: "dateRequestShipping", value: order.dateRequestShipping!),

      DataGridCell<String>(columnName: "customerName", value: order.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "typeProduct", value: order.product?.typeProduct ?? ""),
      DataGridCell<String>(columnName: "productName", value: order.product?.productName ?? ""),
      DataGridCell<String>(columnName: "flute", value: order.flute ?? ""),
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(columnName: "structure", value: order.formatterStructureOrder),
      DataGridCell<String>(columnName: "canLan", value: order.canLan ?? ""),
      DataGridCell<String>(columnName: "daoXa", value: order.daoXa),

      DataGridCell<double>(columnName: "sizeManu", value: order.paperSizeManufacture),
      DataGridCell<double>(columnName: "lengthMf", value: order.lengthPaperManufacture),
      DataGridCell<int>(columnName: "qtyManufacture", value: order.quantityManufacture),
      DataGridCell<int>(
        columnName: "runningPlan",
        value: order.totalQtyRunningPlan - order.totalQtyProduced,
      ),

      DataGridCell<int>(columnName: "quantityProduced", value: order.totalQtyProduced),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),
      DataGridCell<String>(columnName: "instructSpecial", value: order.instructSpecial ?? ""),
      DataGridCell<String>(columnName: "note", value: order.note ?? ""),
      DataGridCell<double>(columnName: "totalPrice", value: order.totalPrice),
      DataGridCell<bool>(columnName: "haveMadeBox", value: order.isBox),
    ];
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

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
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;
            final boolColumns = ["haveMadeBox"];

            String displayValue = "";
            Alignment alignment;

            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);
            } else if (boolColumns.contains(dataCell.columnName)) {
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
