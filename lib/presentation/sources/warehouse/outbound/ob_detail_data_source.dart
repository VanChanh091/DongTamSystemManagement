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
      DataGridCell<String>(columnName: "QC_box", value: order.QC_box ?? ""),
      DataGridCell<String>(
        columnName: "flute",
        value:
            '${order.flute ?? ""}-${formatDimensions(order.lengthPaperManufacture, order.paperSizeManufacture)}',
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
