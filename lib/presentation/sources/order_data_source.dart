import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class OrderDataSource extends DataGridSource {
  List<Order> orders;
  String? selectedOrderId;

  late List<DataGridRow> orderDataGridRows;
  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');

  OrderDataSource({required this.orders, this.selectedOrderId}) {
    buildDataCell();
  }

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
      DataGridCell<String>(columnName: 'flute', value: order.flute ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(
        columnName: 'structure',
        value: order.formatterStructureOrder,
      ),
      DataGridCell<String>(columnName: 'canLan', value: order.canLan ?? ''),
      DataGridCell<String>(columnName: 'daoXaOrd', value: order.daoXa),
      DataGridCell<String>(
        columnName: 'lengthCus',
        value:
            ((order.lengthPaperCustomer) > 0)
                ? '${Order.formatCurrency(order.lengthPaperCustomer)} cm'
                : '0',
      ),
      DataGridCell<String>(
        columnName: 'lengthMf',
        value:
            ((order.lengthPaperManufacture) > 0)
                ? '${Order.formatCurrency(order.lengthPaperManufacture)} cm'
                : "0",
      ),
      DataGridCell<String>(
        columnName: 'sizeCustomer',
        value: '${Order.formatCurrency(order.paperSizeCustomer)} cm',
      ),
      DataGridCell<String>(
        columnName: 'sizeManufacture',
        value: '${Order.formatCurrency(order.paperSizeManufacture)} cm',
      ),
      DataGridCell<int>(
        columnName: 'quantityCustomer',
        value: order.quantityCustomer,
      ),
      DataGridCell<int>(
        columnName: 'qtyManufacture',
        value: order.quantityManufacture,
      ),
      DataGridCell<int>(columnName: 'child', value: order.numberChild),
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
      DataGridCell<String>(
        columnName: 'discounts',
        value: Order.formatCurrency(order.discount ?? 0),
      ),
      DataGridCell<String>(
        columnName: 'profitOrd',
        value: Order.formatCurrency(order.profit),
      ),
      DataGridCell<String>(columnName: 'vat', value: '${order.vat ?? 0}%'),
      DataGridCell<String>(
        columnName: 'HD_special',
        value: order.instructSpecial ?? "",
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(order.totalPrice)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: 'totalPriceAfterVAT',
        value: '${Order.formatCurrency(order.totalPriceVAT)} VNĐ',
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
        columnName: 'chongTham',
        value: order.box?.chongTham ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'canLanBox',
        value: order.box?.canLan ?? false,
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
      DataGridCell<String>(
        columnName: 'maKhuon',
        value: order.box?.maKhuon ?? "",
      ),
      DataGridCell<bool>(
        columnName: 'dan_1_Manh',
        value: order.box?.dan_1_Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dan_2_Manh',
        value: order.box?.dan_2_Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhimMotManh',
        value: order.box?.dongGhim1Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhimHaiManh',
        value: order.box?.dongGhim2Manh ?? false,
      ),
      DataGridCell<String>(
        columnName: 'dongGoi',
        value: order.box?.dongGoi ?? "",
      ),
      ...userController.hasAnyRole(['admin', 'manager'])
          ? [
            DataGridCell(
              columnName: 'staffOrder',
              value: () {
                final fullName = order.user?.fullName ?? ""; //Nguyễn Văn Chánh
                final parts = fullName.trim().split(
                  " ",
                ); //["Nguyễn", "Văn", "Chánh"]
                if (parts.length >= 2) {
                  return parts.sublist(parts.length - 2).join(" "); //Văn Chánh
                } else {
                  return fullName;
                }
              }(),
            ),
          ]
          : [],

      DataGridCell(columnName: 'status', value: formatStatus(order.status)),
      DataGridCell(columnName: 'rejectReason', value: order.rejectReason ?? ""),
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

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'chongTham',
      'canLanBox',
      'canMang',
      'xa',
      'catKhe',
      'be',
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhimMotManh',
      'dongGhimHaiManh',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  void buildDataCell() {
    orderDataGridRows =
        orders
            .map<DataGridRow>(
              (order) => DataGridRow(
                cells: [...buildOrderCells(order), ...buildBoxCells(order)],
              ),
            )
            .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

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
        case 'chấp nhận':
          backgroundColor = Colors.amberAccent.withValues(alpha: 0.4);
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

            return formatDataTable(
              label: _formatCellValueBool(dataCell),
              alignment: alignment,
            );
          }).toList(),
    );
  }
}
