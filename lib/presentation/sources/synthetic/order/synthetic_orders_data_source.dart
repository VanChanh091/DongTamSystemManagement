import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticOrdersDataSource extends DataGridSource {
  List<Order> orders;
  String? selectedOrderId;

  late List<DataGridRow> orderDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();

  SyntheticOrdersDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

  String formatStatus(String status) {
    if (status == 'accept') {
      return 'Chấp nhận';
    } else if (status == 'reject') {
      return "Từ chối";
    } else if (status == 'planning') {
      return "Đã lên kế hoạch";
    }
    return "Chờ Duyệt";
  }

  List<DataGridCell> buildOrderCells(Order order, int index) {
    DataGridCell<String> buildDimensionCell(String columnName, double? value) {
      return DataGridCell<String>(
        columnName: columnName,
        value: (value != null && value > 0) ? '${Order.formatCurrency(value)} cm' : '0',
      );
    }

    DataGridCell<String> buildCurrencyCell(String columnName, int value) {
      return DataGridCell<String>(columnName: columnName, value: Order.formatCurrency(value));
    }

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(
        columnName: 'dayReceive',
        value: formatter.format(order.dayReceiveOrder),
      ),
      DataGridCell<String>(columnName: 'customerName', value: order.customer?.customerName ?? ''),
      DataGridCell<String>(columnName: 'productName', value: order.product?.productName ?? ''),

      DataGridCell<String>(columnName: 'flute', value: order.flute ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(columnName: 'structure', value: order.formatterStructureOrder),

      buildDimensionCell('sizeCust', order.paperSizeCustomer),
      buildDimensionCell('lengthCust', order.lengthPaperCustomer),
      buildDimensionCell('sizeManu', order.paperSizeManufacture),
      buildDimensionCell('lengthManu', order.lengthPaperManufacture),

      buildCurrencyCell('quantityCustomer', order.quantityCustomer),
      buildCurrencyCell('qtyProduced', order.totalQtyProduced),
      buildCurrencyCell('qtyOutbound', order.Inventory?.totalQtyOutbound ?? 0),
      buildCurrencyCell('qtyInventory', order.Inventory?.qtyInventory ?? 0),
      buildCurrencyCell('qtyWasteNorm', order.totalQtyWasteNorm),

      DataGridCell<String>(columnName: 'unit', value: order.dvt),
      DataGridCell<String>(columnName: 'instructSpecial', value: order.instructSpecial ?? ""),

      DataGridCell(
        columnName: 'staffOrder',
        value: () {
          final fullName = order.user?.fullName ?? ""; //Nguyễn Văn Chánh
          final parts = fullName.trim().split(" "); //["Nguyễn", "Văn", "Chánh"]
          if (parts.length >= 2) {
            return parts.sublist(parts.length - 2).join(" "); //Văn Chánh
          } else {
            return fullName;
          }
        }(),
      ),

      DataGridCell<bool>(columnName: 'isBox', value: order.isBox),
      DataGridCell<String>(columnName: 'status', value: formatStatus(order.status)),
    ];
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["isBox"];

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

    //get value cell
    final statusCell = getCellValue<String>(row, 'status', "");
    final status = statusCell.toString().toLowerCase();

    // Chọn màu nền theo status
    Color backgroundColor;
    if (selectedOrderId == orderId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      switch (status) {
        case 'từ chối':
          backgroundColor = Colors.red.withValues(alpha: 0.4);
          break;
        case 'đã lên kế hoạch':
          backgroundColor = Colors.white;
          break;
        default:
          backgroundColor = Colors.transparent;
      }
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = _formatCellValueBool(dataCell);

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
