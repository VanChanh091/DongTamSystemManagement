import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ScrapReportDataSource extends DataGridSource {
  List<ScrapReportModel> scrapReports = [];
  List<int> selectedScrapIds = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> scrapDataGridRows;
  final formatterHHmm = DateFormat('dd/MM/yyyy HH:mm:ss');
  final formatter = DateFormat('dd/MM/yyyy');

  ScrapReportDataSource({
    required this.scrapReports,
    required this.selectedScrapIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();

    addColumnGroup(ColumnGroup(name: 'reportAt', sortGroupRows: false));
  }

  List<DataGridCell> buildScrapReportCells(ScrapReportModel scrapReport, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "status", value: scrapReport.status),

      DataGridCell<String>(
        columnName: "reportedAt",
        value: formatterHHmm.format(scrapReport.reportedAt!),
      ),
      DataGridCell<String>(
        columnName: "dayCompleted",
        value: formatter.format(scrapReport.dayCompleted!),
      ),

      DataGridCell<String>(columnName: "reportedBy", value: scrapReport.reportedBy),
      DataGridCell<String>(columnName: "shiftProduction", value: scrapReport.shiftProduction),

      DataGridCell<double>(columnName: "qtyForklift", value: scrapReport.qtyForklift),
      DataGridCell<double>(columnName: "qtyInventory", value: scrapReport.qtyInventory),
      DataGridCell<double>(columnName: "qtyCoreTube", value: scrapReport.qtyCoreTube),
      DataGridCell<double>(columnName: "qtyProduction", value: scrapReport.qtyProduction),
      DataGridCell<double>(columnName: "qtyOther", value: scrapReport.qtyOther),
      DataGridCell<double>(columnName: "totalQtyScrap", value: scrapReport.totalQtyScrap),

      DataGridCell<String>(columnName: "machine", value: scrapReport.machine),
      DataGridCell<String>(columnName: "rejectReason", value: scrapReport.rejectReason),

      //hidden field
      DataGridCell<int>(columnName: "scrapId", value: scrapReport.scrapId),
      DataGridCell<String>(
        columnName: "reportAt",
        value: formatter.format(scrapReport.reportedAt!),
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => scrapDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    scrapDataGridRows =
        scrapReports.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildScrapReportCells(entry.value, globalIndex));
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
      itemCount = '$count báo cáo';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày báo cáo: $displayDate – $itemCount'
            : '📅 Ngày báo cáo: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final scrapId = row.getCells().firstWhere((cell) => cell.columnName == 'scrapId').value;
    final isSelected = selectedScrapIds.contains(scrapId);

    //get value cell
    final statusCell = getCellValue<String>(row, 'status', "");

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      switch (statusCell) {
        case "pending":
          backgroundColor = Colors.yellow.withValues(alpha: 0.3);
          break;
        case "rejected":
          backgroundColor = Colors.red.withValues(alpha: 0.3);
          break;
        default:
          backgroundColor = Colors.transparent;
      }
    }

    String getStatusVi(String status) {
      switch (status) {
        case "pending":
          return "Chờ Xác Nhận";
        case "confirmed":
          return "Đã Xác Nhận";
        case "rejected":
          return "Bị Từ Chối";
        case "allocated":
          return "Đã Phân Bổ";
        default:
          return status;
      }
    }

    return DataGridRowAdapter(
      color: backgroundColor,
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
