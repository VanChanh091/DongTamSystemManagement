import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticOrdersDataSource extends DataGridSource {
  List<Order> orders = [];
  List<String> selectedOrderIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> orderDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final userController = Get.find<UserController>();

  SyntheticOrdersDataSource({
    required this.orders,
    required this.selectedOrderIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataCell();
  }

  String formatStatus(String status) {
    if (status == 'accept') {
      return 'Chờ lên kế hoạch';
    } else if (status == 'planning') {
      return "Đã lên kế hoạch";
    } else if (status == 'completed') {
      return "Hoàn thành";
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

    DataGridCell<String> buildCurrencyCell(String columnName, num value) {
      return DataGridCell<String>(columnName: columnName, value: Order.formatCurrency(value));
    }

    final inventory = order.Inventory;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(columnName: 'orderIdCus', value: order.orderIdCustomer ?? ""),
      DataGridCell<String>(
        columnName: 'dayReceive',
        value: formatter.format(order.dayReceiveOrder),
      ),
      DataGridCell<String>(
        columnName: 'dateShipping',
        value:
            order.dateRequestShipping != null ? formatter.format(order.dateRequestShipping!) : '',
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
      buildCurrencyCell('qtyInventory', inventory?.qtyInventory ?? 0),
      buildCurrencyCell('qtyOutbound', inventory?.totalQtyOutbound ?? 0),
      buildCurrencyCell('qtyVariance', inventory?.qtyVariance ?? 0),

      DataGridCell<String>(columnName: 'unit', value: order.dvt),
      DataGridCell<String>(columnName: 'vat', value: order.vat != null ? '${order.vat}%' : ''),

      buildCurrencyCell("pricePer", order.price),
      buildCurrencyCell("pricePaper", order.pricePaper ?? 0),
      buildCurrencyCell("totalPrice", order.totalPrice ?? 0),
      buildCurrencyCell("totalPriceVAT", order.totalPriceVAT ?? 0),

      DataGridCell<String>(columnName: 'instructSpecial', value: order.instructSpecial ?? ""),
      DataGridCell(columnName: 'staffOrder', value: order.user?.fullName ?? ""),

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
    final int offset = (currentPage - 1) * pageSize;

    orderDataGridRows =
        orders.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildOrderCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = getCellValue<String>(row, 'orderId', '');

    //get value cell
    final statusCell = getCellValue<String>(row, 'status', "");
    final status = statusCell.toString().toLowerCase();

    final isSelected = selectedOrderIds.contains(orderId);

    // Chọn màu nền theo status
    Color backgroundColor;
    if (isSelected) {
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
