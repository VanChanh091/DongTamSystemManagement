import 'package:dongtam/data/models/order/order_model.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class OrderDataSource extends DataGridSource {
  final formatter = DateFormat('dd/MM/yyyy');
  List<Order> orders;
  bool selectedAll = false;
  String? selectedOrderId;

  OrderDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

  late List<DataGridRow> orderDataGridRows;

  List<DataGridCell> buildOrderCells(Order order) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(
        columnName: 'dayReceiveOrder',
        value: formatter.format(order.dayReceiveOrder),
      ),
      DataGridCell<String>(
        columnName: 'dateRequestShipping',
        value: formatter.format(order.dateRequestShipping),
      ),
      DataGridCell<String>(
        columnName: 'customerName',
        value: order.customer?.customerName ?? '',
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
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(
        columnName: 'structure',
        value: order.formatterStructureOrder,
      ),
      DataGridCell<String>(
        columnName: 'lengthPaper',
        value: Order.formatCurrency(order.lengthPaper),
      ),
      DataGridCell<String>(
        columnName: 'paperSize',
        value: Order.formatCurrency(order.paperSize),
      ),
      DataGridCell<int>(columnName: 'quantity', value: order.quantity),
      DataGridCell<String>(columnName: 'dvt', value: order.dvt),
      DataGridCell<String>(
        columnName: 'acreage',
        value: Order.formatCurrency(order.acreage),
      ),
      DataGridCell<String>(
        columnName: 'price',
        value: Order.formatCurrency(order.price),
      ),
      DataGridCell<String>(
        columnName: 'pricePaper',
        value: Order.formatCurrency(order.pricePaper),
      ),
      DataGridCell<String>(columnName: 'vat', value: '${order.vat ?? 0}%'),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: Order.formatCurrency(order.totalPrice),
      ),
    ];
  }

  List<DataGridCell> buildBoxCells(Order order) {
    return [
      DataGridCell<int>(
        columnName: 'inMatTruoc',
        value: order.box?.inMatTruoc ?? 0,
      ),
      DataGridCell<int>(
        columnName: 'inMatSau',
        value: order.box?.inMatSau ?? 0,
      ),
      DataGridCell<bool>(
        columnName: 'canMang',
        value: order.box?.canMang ?? false,
      ),
      DataGridCell<bool>(columnName: 'xa', value: order.box?.Xa ?? false),
      DataGridCell<bool>(
        columnName: 'catKhe',
        value: order.box?.catKhe ?? false,
      ),
      DataGridCell<bool>(columnName: 'be', value: order.box?.be ?? false),
      DataGridCell<bool>(
        columnName: 'dan_1_Manh',
        value: order.box?.dan_1_Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dan_2_Manh',
        value: order.box?.dan_2_Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhim1Manh',
        value: order.box?.dongGhim1Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhim2Manh',
        value: order.box?.dongGhim2Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'chongTham',
        value: order.box?.chongTham ?? false,
      ),
      DataGridCell<String>(
        columnName: 'dongGoi',
        value: order.box?.dongGoi ?? "",
      ),
      DataGridCell<String>(
        columnName: 'maKhuon',
        value: order.box?.maKhuon ?? "",
      ),
      DataGridCell<String>(
        columnName: 'HD_special',
        value: order.instructSpecial ?? "",
      ),
    ];
  }

  void buildDataCell() {
    orders.sort((a, b) => a.orderId.compareTo(b.orderId));
    orderDataGridRows =
        orders.map<DataGridRow>((order) {
          return DataGridRow(
            cells: [...buildOrderCells(order), ...buildBoxCells(order)],
          );
        }).toList();

    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  void removeItemById(String orderId) {
    orders.removeWhere((order) => order.orderId == orderId);
    buildDataCell();
  }

  void removeAll() {
    orders.clear();
    buildDataCell();
  }

  String formatCellValue(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'canMang',
      'xa',
      'catKhe',
      'be',
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhim1Manh',
      'dongGhim2Manh',
      'chongTham',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return 'Không';
      return value == true ? 'Có' : 'Không';
    }

    return value?.toString() ?? '';
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

    return DataGridRowAdapter(
      color:
          selectedOrderId == orderId
              ? Colors.blue.withOpacity(0.3)
              : Colors.transparent,
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
                formatCellValue(dataCell),
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
