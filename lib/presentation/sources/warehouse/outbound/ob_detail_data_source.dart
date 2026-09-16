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

  @override
  List<DataGridRow> get rows => stagesDataGridRows;

  List<DataGridCell> buildStagesCells(OutboundDetailModel detail) {
    final order = detail.order;

    String formatDimensions(num? length, num? size) {
      if (length == 0 && size == 0) return "";

      // Hàm phụ để xử lý định dạng từng số (cm -> mm -> chuỗi 4 chữ số)
      String formatValue(num? val) {
        if (val == null) return "";
        return (val * 10).round().toString().padLeft(4, '0');
      }

      final lengthStr = formatValue(length);
      final sizeStr = formatValue(size);

      return "${lengthStr}x$sizeStr";
    }

    return [
      DataGridCell<String>(columnName: "orderId", value: detail.orderId),
      DataGridCell<String>(columnName: "typeProduct", value: order!.product!.typeProduct),
      DataGridCell<String>(columnName: "productName", value: order.product!.productName),
      DataGridCell<bool>(columnName: "isFSC", value: order.isFSC),
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(
        columnName: "flute",
        value:
            order.flute != "0"
                ? '${order.flute ?? ""}-${formatDimensions(order.lengthPaperManufacture, order.paperSizeManufacture)}'
                : "-",
      ),
      DataGridCell<String>(columnName: "dvt", value: order.dvt),
      DataGridCell<int>(columnName: "deliveredQty", value: detail.deliveredQty),
      DataGridCell<int>(columnName: "outboundQty", value: detail.outboundQty),
      DataGridCell<double>(columnName: "price", value: detail.price > 0 ? detail.price : 0),
      DataGridCell<double>(columnName: "discount", value: order.discount! > 0 ? order.discount : 0),
      DataGridCell<double>(columnName: "totalPriceOutbound", value: detail.totalPriceOutbound),

      DataGridCell<String>(
        columnName: "type",
        value: detail.isPromotion ? "Hàng Tặng" : "Hàng Bán",
      ),

      //hidden
      DataGridCell<int>(columnName: "outboundDetailId", value: detail.outboundDetailId),
    ];
  }

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
            final value = dataCell.value;
            final boolColumns = ["isFSC"];

            String displayValue = "";
            Alignment alignment;

            if (dataCell.value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);
            } else if (boolColumns.contains(dataCell.columnName)) {
              alignment = Alignment.center;
              displayValue = (value == true) ? "✅" : "";
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
