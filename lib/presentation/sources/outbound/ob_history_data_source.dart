import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ObHistoryDataSource extends DataGridSource {
  List<OutboundHistoryModel> outbounds = [];
  int? selectedOutboundId;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ObHistoryDataSource({required this.outbounds, this.selectedOutboundId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildDbPaperCells(OutboundHistoryModel outbounds) {
    final detail =
        outbounds.detail != null && outbounds.detail!.isNotEmpty ? outbounds.detail!.first : null;

    final customer = detail?.order?.customer;

    return [
      DataGridCell<String>(
        columnName: "dateOutbound",
        value: formatter.format(outbounds.dateOutbound),
      ),
      DataGridCell<String>(columnName: "outboundSlipCode", value: outbounds.outboundSlipCode),
      DataGridCell<String>(columnName: "customerName", value: customer!.customerName),
      DataGridCell<String>(columnName: "companyName", value: customer.companyName),
      DataGridCell<String>(
        columnName: "totalPriceOrder",
        value: '${Order.formatCurrency(outbounds.totalPriceOrder)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "totalPriceVAT",
        value: '${Order.formatCurrency(outbounds.totalPriceVAT!)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "totalPricePayment",
        value: '${Order.formatCurrency(outbounds.totalPricePayment)} VNĐ',
      ),
      DataGridCell<int>(columnName: "totalOutboundQty", value: outbounds.totalOutboundQty),

      //hidden
      DataGridCell<int>(columnName: "outboundId", value: outbounds.outboundId),
    ];
  }

  @override
  List<DataGridRow> get rows => dbPaperDataGridRows;

  void buildDataGridRows() {
    dbPaperDataGridRows =
        outbounds.map<DataGridRow>((o) {
          final cells = buildDbPaperCells(o);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final outboundId = row.getCells().firstWhere((cell) => cell.columnName == 'outboundId').value;

    Color backgroundColor;
    if (selectedOutboundId == outboundId) {
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
