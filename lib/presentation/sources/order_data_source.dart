import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class OrderDataSource extends DataGridSource {
  final BuildContext context;
  late List<DataGridRow> orderDataGridRows;

  List<Order> orders;
  String? selectedOrderId;

  final userController = Get.find<UserController>();
  final formatter = DateFormat('dd/MM/yyyy');

  OrderDataSource({required this.orders, this.selectedOrderId, required this.context}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(Order order, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: order.orderId),
      DataGridCell<String>(columnName: 'customerName', value: order.customer?.customerName ?? ''),
      DataGridCell<String>(columnName: 'productName', value: order.product?.productName ?? ''),
      DataGridCell<String>(columnName: 'flute', value: order.flute ?? ''),
      DataGridCell<String>(columnName: 'QC_box', value: order.QC_box ?? ''),
      DataGridCell<String>(columnName: 'structure', value: order.formatterStructureOrder),
      DataGridCell<String>(
        columnName: 'sizeCustomer',
        value: '${Order.formatCurrency(order.paperSizeCustomer)} cm',
      ),
      DataGridCell<String>(
        columnName: 'lengthCus',
        value:
            ((order.lengthPaperCustomer) > 0)
                ? '${Order.formatCurrency(order.lengthPaperCustomer)} cm'
                : '0',
      ),
      DataGridCell<String>(columnName: 'canLan', value: order.canLan ?? ''),
      DataGridCell<String>(columnName: 'daoXaOrd', value: order.daoXa),
      DataGridCell<String>(
        columnName: 'quantityCustomer',
        value: Order.formatCurrency(order.quantityCustomer),
      ),
      DataGridCell<String>(columnName: 'instructSpecial', value: order.instructSpecial ?? ""),

      ...userController.hasAnyRole(roles: ['admin', 'manager'])
          ? [
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
          ]
          : [],

      DataGridCell(columnName: 'status', value: formatStatus(order.status)),
      DataGridCell(columnName: 'rejectReason', value: order.rejectReason ?? ""),
      DataGridCell(columnName: 'orderImage', value: order.orderImage?.imageUrl ?? ""),
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

            if (dataCell.columnName == 'orderImage') {
              final imageUrl = dataCell.value?.toString() ?? "";
              final hasImage = imageUrl.isNotEmpty && imageUrl != "Không có ảnh";

              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child:
                    hasImage
                        ? TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Scaffold(
                                    backgroundColor: Colors.black54,
                                    body: Center(
                                      child: GestureDetector(
                                        onTap: () {}, // Ngăn đóng dialog khi bấm ảnh
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 800,
                                            height: 800,
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 300,
                                                  height: 300,
                                                  color: Colors.grey.shade300,
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                    "Lỗi ảnh",
                                                    style: TextStyle(color: Colors.black),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            "Xem ảnh",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                        : Text('Không có ảnh'),
              );
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
