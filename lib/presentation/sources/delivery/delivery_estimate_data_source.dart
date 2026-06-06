import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryEstimateDataSource extends DataGridSource {
  List<PlanningPaper> delivery = [];
  List<int> selectedPaperIds = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  DeliveryEstimateDataSource({
    required this.delivery,
    required this.selectedPaperIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildDbPaperCells(PlanningPaper paper, int index) {
    final order = paper.order;
    final inventory = order?.Inventory;

    return [
      // Order
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: paper.orderId),
      DataGridCell<String>(columnName: "orderIdCust", value: order?.orderIdCustomer ?? ""),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            order?.dateRequestShipping != null ? formatter.format(order!.dateRequestShipping!) : "",
      ),
      DataGridCell<String>(columnName: "delivered", value: paper.deliveryPlanned ?? ""),

      //customer
      DataGridCell<String>(columnName: "customerName", value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),

      DataGridCell<String>(columnName: "QcBox", value: order?.QC_box ?? ""),
      DataGridCell<String>(columnName: 'size', value: '${order!.paperSizeManufacture} cm'),
      DataGridCell<String>(columnName: 'length', value: '${order.lengthPaperManufacture} cm'),

      //quantity
      DataGridCell<int>(columnName: 'quantityOrd', value: order.quantityManufacture),
      DataGridCell<int>(columnName: "qtyProduced", value: paper.qtyProduced),
      DataGridCell<int>(columnName: "qtyOutbound", value: inventory?.totalQtyOutbound ?? 0),
      DataGridCell<int>(columnName: "qtyInventory", value: inventory?.qtyInventory ?? 0),

      DataGridCell<String>(columnName: "dvt", value: order.dvt),
      DataGridCell<String>(
        columnName: 'volume',
        value:
            order.volume != null && order.volume! > 0
                ? '${Order.formatCurrency(order.volume ?? 0)} m³'
                : "0",
      ),

      //structure
      DataGridCell<String>(columnName: 'structure', value: paper.formatterStructureOrder),
      DataGridCell<String>(columnName: "instructSpecial", value: order.instructSpecial ?? ''),
      DataGridCell<String>(columnName: "note", value: order.note ?? ''),

      //user
      DataGridCell<String>(columnName: "staffOrder", value: order.user?.fullName ?? ""),

      // hidden technical fields
      DataGridCell<int>(columnName: "planningId", value: paper.planningId),
    ];
  }

  @override
  List<DataGridRow> get rows => dbPaperDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    dbPaperDataGridRows =
        delivery.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          final cells = buildDbPaperCells(entry.value, globalIndex);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final planningId = row.getCells().firstWhere((cell) => cell.columnName == 'planningId').value;
    final isSelected = selectedPaperIds.contains(planningId);

    final status = getCellValue<String>(row, 'delivered', "");

    Color rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3);
    } else if (status.isNotEmpty) {
      if (status == "pending") {
        rowColor = Colors.orange.withValues(alpha: 0.3);
      } else if (status == "planned") {
        rowColor = Colors.green.withValues(alpha: 0.3);
      } else {
        rowColor = Colors.transparent;
      }
    } else {
      rowColor = Colors.transparent;
    }

    String getStatusVi(String status) {
      switch (status) {
        case "none":
          return "";
        case "pending":
          return "Đã Đăng Ký";
        case "planned":
          return "Đã Xếp Xe";
        default:
          return status;
      }
    }

    return DataGridRowAdapter(
      color: rowColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            String displayValue = dataCell.value?.toString() ?? "";

            if (dataCell.columnName == 'delivered') {
              displayValue = getStatusVi(displayValue);
            }

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
