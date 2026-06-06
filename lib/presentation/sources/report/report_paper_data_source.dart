import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/report/report_paper_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPaperDatasource extends DataGridSource {
  List<ReportPaperModel> reportPapers = [];
  List<int> selectedReportId;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  ReportPaperDatasource({
    required this.reportPapers,
    required this.selectedReportId,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dateTimeRp', sortGroupRows: false));
  }

  List<DataGridCell> buildReportInfoCells(ReportPaperModel reportPaper, int index) {
    final orderCell = reportPaper.planningPaper!.order;
    final planningPaper = reportPaper.planningPaper;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: 'orderId', value: orderCell!.orderId),
      DataGridCell<String>(columnName: 'customerName', value: orderCell.customer?.customerName),

      DataGridCell<String>(
        columnName: "dayStartProduction",
        value: formatter.format(planningPaper!.dayStart!),
      ),
      DataGridCell<String?>(
        columnName: "dayReported",
        value: formatterDayReported.format(reportPaper.dayReport),
      ),

      DataGridCell<String>(columnName: 'structure', value: planningPaper.formatterStructureOrder),
      DataGridCell<String>(columnName: 'flute', value: orderCell.flute ?? ''),
      DataGridCell<String>(columnName: 'daoXa', value: orderCell.daoXa),
      DataGridCell<String>(columnName: 'size', value: '${planningPaper.sizePaperPLaning}'),
      DataGridCell<String>(
        columnName: 'length',
        value: planningPaper.lengthPaperPlanning > 0 ? '${planningPaper.lengthPaperPlanning}' : "0",
      ),
      DataGridCell<int>(columnName: 'numberChild', value: planningPaper.numberChild),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${planningPaper.ghepKho} cm'),

      DataGridCell<int>(columnName: "runningPlanProd", value: planningPaper.runningPlan),
      DataGridCell<int>(columnName: "qtyReported", value: reportPaper.qtyProduced),
      DataGridCell<int>(columnName: "lackOfQty", value: reportPaper.lackOfQty),
      DataGridCell<double>(
        columnName: 'qtyWasteRp',
        value: reportPaper.qtyWasteNorm > 0 ? reportPaper.qtyWasteNorm : 0,
      ),

      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value: PlanningPaper.formatTimeOfDay(timeOfDay: planningPaper.timeRunning!),
      ),
      DataGridCell<String>(columnName: "HD_special", value: orderCell.instructSpecial ?? ''),

      DataGridCell<String>(columnName: 'shiftProduction', value: reportPaper.shiftProduction),
      DataGridCell<String>(columnName: 'shiftManager', value: reportPaper.shiftManagement),
      DataGridCell<String>(columnName: 'reportedBy', value: reportPaper.reportedBy),

      DataGridCell<bool>(columnName: 'hasMadeBox', value: reportPaper.planningPaper!.hasBox),

      //hidden fields
      DataGridCell<int>(columnName: 'reportPaperId', value: reportPaper.reportPaperId),
      DataGridCell<String?>(
        columnName: "dateTimeRp",
        value: formatter.format(reportPaper.dayReport),
      ),
    ];
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ['hasMadeBox'];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        reportPapers.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildReportInfoCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
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
      itemCount = '$count đơn hàng';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày báo cáo: $displayDate  $itemCount'
            : '📅 Ngày báo cáo: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final reportPaperId =
        row.getCells().firstWhere((cell) => cell.columnName == 'reportPaperId').value;
    final isSelected = selectedReportId.contains(reportPaperId);

    Color backgroundColor;
    if (isSelected == true) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = _formatCellValueBool(dataCell);

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            Color cellColor = Colors.transparent;
            if (dataCell.columnName == 'qtyReported') {
              final qty = dataCell.value;
              if (qty > 0) {
                cellColor = Colors.amberAccent.withValues(alpha: 0.3);
              }
            } else if (dataCell.columnName == "lackOfQty") {
              final int value = dataCell.value ?? 0;
              final String display = value < 0 ? "+${value.abs()}" : value.toString();

              Color textColor = Colors.black;
              if (value > 0) {
                textColor = Colors.redAccent;
              } else if (value < 0) {
                textColor = Colors.green;
              }

              return Container(
                alignment: alignment,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
                ),
                child: Text(
                  display,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: value < 0 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }

            return formatDataTable(
              label: _formatCellValueBool(dataCell),
              alignment: alignment,
              cellColor: cellColor,
            );
          }).toList(),
    );
  }
}
