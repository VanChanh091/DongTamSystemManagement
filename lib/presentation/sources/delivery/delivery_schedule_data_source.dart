import 'package:dongtam/data/models/delivery/delivery_item_model.dart';
import 'package:dongtam/data/models/delivery/delivery_plan_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DeliveryScheduleDataSource extends DataGridSource {
  List<DeliveryPlanModel> delivery = [];
  List<int>? selectedDeliveryId;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  DeliveryScheduleDataSource({required this.delivery, this.selectedDeliveryId}) {
    buildDataGridRows();

    addColumnGroup(ColumnGroup(name: 'sequence', sortGroupRows: false));
    addColumnGroup(ColumnGroup(name: 'customerName', sortGroupRows: false));
  }

  List<DataGridCell> buildDbPaperCells(DeliveryPlanModel plan, DeliveryItemModel item) {
    final vehicle = item.vehicle;
    final order = item.planning?.order;
    final customer = order?.customer;
    final product = order?.product;
    final inventory = order?.Inventory;

    return [
      DataGridCell<String>(columnName: "vehicleName", value: vehicle?.vehicleName ?? ""),

      //order
      DataGridCell<String>(columnName: "orderId", value: order!.orderId),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: product?.productName ?? ""),
      DataGridCell<String>(columnName: "flute", value: order.flute ?? ""),
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(columnName: "structure", value: order.formatterStructureOrder),
      DataGridCell<String>(columnName: "lengthProd", value: '${order.lengthPaperManufacture} cm'),
      DataGridCell<String>(columnName: "sizeProd", value: '${order.paperSizeManufacture} cm'),
      DataGridCell<int>(columnName: "quantity", value: order.quantityManufacture),
      DataGridCell<int>(columnName: "qtyInventory", value: inventory?.qtyInventory ?? 0),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),

      //vehicle
      DataGridCell<String>(columnName: "licensePlate", value: vehicle?.licensePlate ?? ""),
      DataGridCell<String>(
        columnName: "maxPayload",
        value: vehicle?.maxPayload != 0 ? "${vehicle?.maxPayload} kg" : "",
      ),
      DataGridCell<String>(
        columnName: "volumeCapacity",
        value: vehicle?.volumeCapacity != 0 ? "${vehicle?.volumeCapacity} m³" : "",
      ),

      //delivery item
      DataGridCell<String>(columnName: "note", value: item.note ?? ""),

      //hidden field
      DataGridCell<int>(columnName: "deliveryId", value: plan.deliveryId),
      DataGridCell<String>(
        columnName: "deliveryDate",
        value: plan.deliveryDate != null ? formatter.format(plan.deliveryDate!) : "",
      ),
      DataGridCell<String>(columnName: "status", value: item.status), //status of delivery item
      DataGridCell<int>(columnName: "sequence", value: item.sequence),
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

    final fieldName = parts[0].trim(); // sequence | customerName
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

      case 'customerName':
        caption = 'Khách Hàng: $groupValue';
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
    final deliveryId = row.getCells().firstWhere((cell) => cell.columnName == 'deliveryId').value;

    Color backgroundColor;
    if (selectedDeliveryId != null && selectedDeliveryId!.contains(deliveryId)) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: dataCell.value?.toString() ?? "", alignment: alignment);
          }).toList(),
    );
  }
}
