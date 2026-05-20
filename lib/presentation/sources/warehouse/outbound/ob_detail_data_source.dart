import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_detail_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ObDetailDataSource extends DataGridSource {
  List<OutboundDetailModel> detail = [];

  late List<DataGridRow> stagesDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  ObDetailDataSource({required this.detail}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildStagesCells(OutboundDetailModel detail) {
    final order = detail.order;

    String formatNumber(double value) {
      String result;

      // Nếu là số nguyên (ví dụ 123.0) thì chuyển về "123"
      if (value == value.toInt()) {
        result = value.toInt().toString();
      } else {
        // Nếu là số thập phân (46.5, 46.25) thì xóa dấu chấm
        result = value.toString().replaceAll('.', '');
      }

      // Luôn bù số 0 cho đủ 4 ký tự
      return result.padLeft(4, '0');
    }

    return [
      DataGridCell<String>(columnName: "orderId", value: detail.orderId),
      DataGridCell<String>(columnName: "typeProduct", value: order!.product!.typeProduct),
      DataGridCell<String>(columnName: "productName", value: order.product!.productName),
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(
        columnName: "flute",
        value:
            '${order.flute ?? ""}-${formatNumber(order.lengthPaperManufacture)}x${formatNumber(order.paperSizeManufacture)}',
      ),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),
      DataGridCell<int>(columnName: "deliveredQty", value: detail.deliveredQty),
      DataGridCell<int>(columnName: "outboundQty", value: detail.outboundQty),
      DataGridCell<String>(columnName: "price", value: '${Order.formatCurrency(detail.price)} VNĐ'),
      DataGridCell<String>(
        columnName: "discount",
        value: '${Order.formatCurrency(order.discount ?? 0)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "totalPriceOutbound",
        value: '${Order.formatCurrency(detail.totalPriceOutbound)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "type",
        value: detail.isPromotion ? "Hàng Tặng" : "Hàng Bán",
      ),

      //hidden
      DataGridCell<int>(columnName: "outboundDetailId", value: detail.outboundDetailId),
    ];
  }

  @override
  List<DataGridRow> get rows => stagesDataGridRows;

  void buildDataGridRows() {
    stagesDataGridRows =
        detail.map<DataGridRow>((d) {
          final cells = buildStagesCells(d);
          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
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
