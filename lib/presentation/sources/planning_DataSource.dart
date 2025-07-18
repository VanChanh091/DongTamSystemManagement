import 'package:dongtam/data/models/order/order_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class PlanningDataSource extends DataGridSource {
  late List<DataGridRow> orderDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  List<Order> orders;
  bool selectedAll = false;
  String? selectedOrderId;

  PlanningDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(Order order) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(
        columnName: 'dateRequestShipping',
        value: formatter.format(order.dateRequestShipping),
      ),
      DataGridCell<String>(
        columnName: 'companyName',
        value: order.customer?.companyName ?? '',
      ),
      DataGridCell<String>(
        columnName: 'typeProduct',
        value: order.product?.typeProduct ?? '',
      ),
      DataGridCell<String>(
        columnName: 'productName',
        value: order.product?.productName ?? '',
      ),
      DataGridCell<String>(columnName: 'flute', value: order.flute ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(
        columnName: 'structure',
        value: order.formatterStructureOrder,
      ),
      DataGridCell<String>(columnName: 'canLan', value: order.canLan ?? ''),
      DataGridCell<String>(columnName: 'daoXa', value: order.daoXa),
      DataGridCell<String>(
        columnName: 'lengthMf',
        value: Order.formatCurrency(order.lengthPaperManufacture),
      ),
      DataGridCell<String>(
        columnName: 'sizeManufacture',
        value: Order.formatCurrency(order.paperSizeManufacture),
      ),
      DataGridCell<int>(
        columnName: 'qtyManufacture',
        value: order.quantityManufacture,
      ),
      DataGridCell<String>(
        columnName: 'instructSpecial',
        value: order.instructSpecial ?? "",
      ),
      DataGridCell<String>(
        columnName: 'haveMadeBox',
        value: order.formatIsBox(order.isBox),
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: Order.formatCurrency(order.totalPrice),
      ),
    ];
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

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  String formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'canMang',
      'xa',
      'catKhe',
      'be',
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhimMotManh',
      'dongGhimHaiManh',
      'chongTham',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? 'Có' : '';
    }

    return value?.toString() ?? '';
  }

  void removeItemById(String orderId) {
    orders.removeWhere((order) => order.orderId == orderId);
    buildDataCell();
  }

  void removeAll() {
    orders.clear();
    buildDataCell();
  }

  void buildDataCell() {
    orders.sort((a, b) {
      int getStatusPriority(String? status) {
        switch (status?.toLowerCase()) {
          case 'reject':
            return 0;
          case 'pending':
            return 1;
          case 'accept':
            return 2;
          case 'planning':
            return 3;
          default:
            return 4;
        }
      }

      int statusCompare = getStatusPriority(
        a.status,
      ).compareTo(getStatusPriority(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.orderId.compareTo(b.orderId);
    });

    orderDataGridRows =
        orders
            .map<DataGridRow>(
              (order) => DataGridRow(cells: buildOrderCells(order)),
            )
            .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

    Color backgroundColor = Colors.transparent;
    if (selectedOrderId == orderId) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                formatCellValueBool(dataCell),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}
