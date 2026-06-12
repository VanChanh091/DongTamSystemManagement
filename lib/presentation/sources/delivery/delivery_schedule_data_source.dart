import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/delivery/delivery_schedule_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryScheduleDataSource extends DataGridSource {
  List<DeliveryScheduleModel> delivery = [];
  List<int> selectedDeliveryId;
  bool showGroup;
  String page;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  DeliveryScheduleDataSource({
    required this.delivery,
    required this.selectedDeliveryId,
    required this.showGroup,
    required this.page,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(ColumnGroup(name: 'sequence', sortGroupRows: false));
      addColumnGroup(ColumnGroup(name: 'vehicleName', sortGroupRows: false));
    }
  }

  List<DataGridCell> buildDbPaperCells(DeliveryScheduleModel schedule, DeliveryItemModel item) {
    final vehicle = item.vehicle;
    final order = item.request?.paper?.order;
    final customer = order?.customer;
    final product = order?.product;

    return [
      //order
      DataGridCell<String>(columnName: "orderId", value: order!.orderId),
      DataGridCell<String>(columnName: "orderIdCus", value: order.orderIdCustomer ?? ""),
      DataGridCell<String>(columnName: "status", value: item.status),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: product?.productName ?? ""),

      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(columnName: "structure", value: order.formatterStructureOrder),

      DataGridCell<String>(columnName: "sizeProd", value: '${order.paperSizeManufacture} cm'),
      DataGridCell<String>(columnName: "lengthProd", value: '${order.lengthPaperManufacture} cm'),

      DataGridCell<int>(columnName: "qtyCustomer", value: order.quantityCustomer),
      DataGridCell<int>(
        columnName: "totalQtyOutbound",
        value: order.Inventory?.totalQtyOutbound ?? 0,
      ),
      DataGridCell<int>(columnName: "qtyRegistered", value: item.request?.qtyRegistered ?? 0),
      DataGridCell<int>(columnName: "qtyOutbound", value: item.getTotalQtyOutbound),

      DataGridCell<String>(columnName: "note", value: item.request?.note ?? ""),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),
      DataGridCell<String>(
        columnName: "volume",
        value: item.request!.volume != 0 ? "${item.request!.volume} m³" : "",
      ),
      DataGridCell<String>(columnName: "vehicleHouse", value: vehicle?.vehicleHouse ?? ""),

      //hidden field
      DataGridCell<int>(columnName: "deliveryId", value: schedule.deliveryId),
      DataGridCell<int>(columnName: "deliveryItemId", value: item.deliveryItemId),
      DataGridCell<String>(
        columnName: "deliveryDate",
        value: schedule.deliveryDate != null ? formatter.format(schedule.deliveryDate!) : "",
      ),
      DataGridCell<String>(columnName: "status", value: item.status), //status of delivery item
      DataGridCell<String>(columnName: "vehicleName", value: vehicle?.vehicleName ?? ""),
      DataGridCell<String>(columnName: "sequence", value: item.sequence),
    ];
  }

  @override
  List<DataGridRow> get rows => dbPaperDataGridRows;

  void buildDataGridRows() {
    dbPaperDataGridRows =
        delivery.expand<DataGridRow>((plan) {
          final items = plan.deliveryItems ?? [];
          return items.map((item) {
            return DataGridRow(cells: buildDbPaperCells(plan, item));
          });
        }).toList();
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Tách field và value
    final parts = summaryValue.split(':');
    if (parts.length < 2) return null;

    final fieldName = parts[0].trim(); // sequence
    final valuePart = parts[1].trim(); // "1 - 3 items" | "chanh 1 - 2 items"

    final valuePieces = valuePart.split('-');
    if (valuePieces.length < 2) return null;

    final groupValue = valuePieces[0].trim();
    final itemCount = valuePieces[1].replaceAll(RegExp(r'items?', caseSensitive: false), '').trim();

    String caption;

    switch (fieldName) {
      case 'sequence':
        caption = '🚚 Tài: $groupValue - $itemCount đơn hàng';
        break;

      case 'vehicleName':
        caption = '$groupValue - $itemCount đơn hàng';
        break;

      default:
        caption = '$groupValue - $itemCount items';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(caption, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final deliveryItemId =
        row.getCells().firstWhere((cell) => cell.columnName == 'deliveryItemId').value;

    final isSelected = selectedDeliveryId.contains(deliveryItemId);

    final status = getCellValue<String>(row, 'status', "");

    Color? rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3);
    } else if (status.isNotEmpty) {
      if (status == "completed") {
        rowColor = Colors.green.withValues(alpha: 0.3);
      } else if (status == "cancelled") {
        rowColor = Colors.red.withValues(alpha: 0.4);
      } else if (status == "requested") {
        page == 'schedule'
            ? rowColor = Colors.orange.withValues(alpha: 0.3)
            : rowColor = Colors.transparent;
      } else if (status == "prepared") {
        rowColor = Colors.yellow.withValues(alpha: 0.4);
      } else if (status == "outbound") {
        rowColor = Colors.teal.withValues(alpha: 0.3);
      }
    } else {
      rowColor = Colors.transparent;
    }

    String getStatusVi(String status) {
      switch (status) {
        case "none":
          return "";
        case "planned":
          return "Chờ";
        case "requested":
          return "Đã Yêu Cầu";
        case "prepared":
          return "Đã Chuẩn Bị Hàng";
        case "outbound":
          return "Đã Xuất Kho";
        case "cancelled":
          return "Hủy Giao";
        case "completed":
          return "Hoàn Thành";
        default:
          return status;
      }
    }

    return DataGridRowAdapter(
      color: rowColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            String displayValue = dataCell.value?.toString() ?? "";

            if (dataCell.columnName == 'status') {
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
