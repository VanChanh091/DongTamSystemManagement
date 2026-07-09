import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/warehouse/outbound/outbound_history_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:dongtam/utils/logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ObHistoryDataSource extends DataGridSource {
  List<OutboundHistoryModel> outbounds = [];
  int? selectedOutboundId;
  Map<String, dynamic> totalPriceByDate = {};

  int currentPage;
  int pageSize;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ObHistoryDataSource({
    required this.outbounds,
    this.selectedOutboundId,
    required this.totalPriceByDate,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dateOutbound', sortGroupRows: false));
  }

  List<DataGridCell> buildDbPaperCells(OutboundHistoryModel outbound, int index) {
    DataGridCell<String> buildDimensionCell(String columnName, double? value) {
      return DataGridCell<String>(
        columnName: columnName,
        value: (value != null && value > 0) ? OrderModel.formatCurrency(value) : '0',
      );
    }

    final detail =
        outbound.detail != null && outbound.detail!.isNotEmpty ? outbound.detail!.first : null;

    final customer = detail?.order?.customer;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "outboundSlipCode", value: outbound.outboundSlipCode),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "companyName", value: customer?.companyName ?? ""),
      DataGridCell<int>(columnName: "totalOutboundQty", value: outbound.totalOutboundQty),
      DataGridCell<String>(
        columnName: "dueDate",
        value: outbound.dueDate != null ? formatter.format(outbound.dueDate!) : "",
      ),

      //money
      buildDimensionCell("totalPriceOrder", outbound.totalPriceOrder),
      buildDimensionCell("totalPriceVAT", outbound.totalPriceVAT),
      buildDimensionCell("totalPricePayment", outbound.totalPricePayment),
      buildDimensionCell("paidAmount", outbound.paidAmount),
      buildDimensionCell("remainingAmount", outbound.remainingAmount),

      DataGridCell<String>(columnName: "status", value: outbound.status),
      DataGridCell<String>(columnName: "outboundBy", value: outbound.outboundBy),

      //hidden
      DataGridCell<int>(columnName: "outboundId", value: outbound.outboundId),
      DataGridCell<String>(
        columnName: "dateOutbound",
        value: formatter.format(outbound.dateOutbound),
      ),
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
    num totalAmount = 0;

    if (match != null) {
      final fullDate = match.group(1) ?? '';
      displayDate = fullDate.split(' ').first; // chỉ lấy phần ngày
      final count = match.group(2) ?? '0';
      itemCount = '$count Phiếu';
    }

    try {
      if (displayDate.isNotEmpty) {
        // Ép formatter dùng đúng định dạng dd/MM/yyyy của UI cho chắc chắn
        final parsedDate = DateFormat('dd/MM/yyyy').parse(displayDate.trim());
        final lookupKey = DateFormat('yyyy-MM-dd').format(parsedDate);

        totalAmount = (totalPriceByDate[lookupKey] as num?) ?? 0;
      }
    } catch (e) {
      AppLogger.e('Lỗi khi parse ngày hoặc truy xuất tổng tiền: $e');
      totalAmount = 0;
    }

    final formattedTotal = totalAmount > 0 ? OrderModel.formatCurrency(totalAmount) : '0';

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày xuất kho: $displayDate – $itemCount – Tổng Tiền: $formattedTotal VNĐ'
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
