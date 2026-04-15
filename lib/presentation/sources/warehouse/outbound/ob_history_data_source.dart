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

  List<DataGridCell> buildDbPaperCells(OutboundHistoryModel outbound) {
    final detail =
        outbound.detail != null && outbound.detail!.isNotEmpty ? outbound.detail!.first : null;

    final customer = detail?.order?.customer;

    return [
      DataGridCell<String>(columnName: "outboundSlipCode", value: outbound.outboundSlipCode),
      DataGridCell<String>(
        columnName: "dateOutbound",
        value: formatter.format(outbound.dateOutbound),
      ),
      DataGridCell<String>(columnName: "customerName", value: customer!.customerName),
      DataGridCell<String>(columnName: "companyName", value: customer.companyName),
      DataGridCell<int>(columnName: "totalOutboundQty", value: outbound.totalOutboundQty),
      DataGridCell<String>(
        columnName: "dueDate",
        value: outbound.dueDate != null ? formatter.format(outbound.dueDate!) : "",
      ),

      //money
      DataGridCell<String>(
        columnName: "totalPriceOrder",
        value: '${Order.formatCurrency(outbound.totalPriceOrder)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "totalPriceVAT",
        value:
            outbound.totalPriceVAT != null && outbound.totalPriceVAT! > 0
                ? '${Order.formatCurrency(outbound.totalPriceVAT!)} VNĐ'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "totalPricePayment",
        value: '${Order.formatCurrency(outbound.totalPricePayment)} VNĐ',
      ),
      DataGridCell<String>(
        columnName: "paidAmount",
        value:
            outbound.paidAmount != null && outbound.paidAmount! > 0
                ? '${Order.formatCurrency(outbound.paidAmount!)} VNĐ'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "remainingAmount",
        value:
            outbound.remainingAmount != null && outbound.remainingAmount! > 0
                ? '${Order.formatCurrency(outbound.remainingAmount!)} VNĐ'
                : "0",
      ),

      DataGridCell<String>(columnName: "status", value: outbound.status),

      //hidden
      DataGridCell<int>(columnName: "outboundId", value: outbound.outboundId),
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

    String getStatusVi(String status) {
      switch (status) {
        case "paid":
          return "Đã Thanh Toán";
        case "unpaid":
          return "Chưa Thanh Toán";
        case "partial":
          return "Thanh Toán Một Phần";
        default:
          return status;
      }
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            String displayValue = dataCell.value?.toString() ?? "";

            if (dataCell.columnName == "status") {
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
