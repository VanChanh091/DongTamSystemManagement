import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ObHistoryDataSource extends DataGridSource {
  List<OutboundHistoryModel> outbounds = [];
  int? selectedOutboundId;
  int currentPage;
  int pageSize;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ObHistoryDataSource({
    required this.outbounds,
    this.selectedOutboundId,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dateOutbound', sortGroupRows: false));
  }

  List<DataGridCell> buildDbPaperCells(OutboundHistoryModel outbound, int index) {
    final detail =
        outbound.detail != null && outbound.detail!.isNotEmpty ? outbound.detail!.first : null;

    final customer = detail?.order?.customer;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "outboundSlipCode", value: outbound.outboundSlipCode),
      DataGridCell<String>(
        columnName: "dateOutbound",
        value: formatter.format(outbound.dateOutbound),
      ),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "companyName", value: customer?.companyName ?? ""),
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
    final int offset = (currentPage - 1) * pageSize;

    dbPaperDataGridRows =
        outbounds.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          final cells = buildDbPaperCells(entry.value, globalIndex);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$', caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = '';
    String itemCount = '';

    if (match != null) {
      final fullDate = match.group(1) ?? '';
      displayDate = fullDate.split(' ').first; // chỉ lấy phần ngày
      final count = match.group(2) ?? '0';
      itemCount = '$count Phiếu';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày xuất kho: $displayDate – $itemCount'
            : '📅 Ngày xuất kho: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
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
