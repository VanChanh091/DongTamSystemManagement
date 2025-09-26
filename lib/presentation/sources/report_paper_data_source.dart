import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/data/models/report/report_planning_paper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportPaperDatasource extends DataGridSource {
  List<ReportPaperModel> reportPapers = [];
  List<int>? selectedReportId;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  ReportPaperDatasource({required this.reportPapers, this.selectedReportId}) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dateTimeRp', sortGroupRows: false));
  }

  List<DataGridCell> buildReportInfoCells(ReportPaperModel reportPaper) {
    final orderCell = reportPaper.planningPaper!.order;
    final planningPaper = reportPaper.planningPaper;

    return [
      DataGridCell<String>(columnName: 'orderId', value: orderCell!.orderId),
      DataGridCell<int>(
        columnName: 'reportPaperId',
        value: reportPaper.reportPaperId,
      ),
      DataGridCell<String>(
        columnName: 'customerName',
        value: orderCell.customer?.customerName,
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value: formatter.format(orderCell.dateRequestShipping),
      ),
      DataGridCell<String>(
        columnName: "dayStartProduction",
        value: formatter.format(planningPaper!.dayStart!),
      ),
      DataGridCell<String?>(
        columnName: "dayReported",
        value: formatterDayReported.format(reportPaper.dayReport),
      ),
      DataGridCell<String?>(
        columnName: "dateTimeRp",
        value: formatter.format(reportPaper.dayReport),
      ),
      DataGridCell<String>(
        columnName: 'structure',
        value: planningPaper.formatterStructureOrder,
      ),
      DataGridCell<String>(columnName: 'flute', value: orderCell.flute ?? ''),
      DataGridCell<String>(columnName: 'daoXa', value: orderCell.daoXa),
      DataGridCell<String>(
        columnName: 'length',
        value: '${planningPaper.lengthPaperPlanning} cm',
      ),
      DataGridCell<String>(
        columnName: 'size',
        value: '${planningPaper.sizePaperPLaning} cm',
      ),
      DataGridCell<int>(columnName: 'child', value: orderCell.numberChild),
      DataGridCell<String>(
        columnName: 'khoCapGiay',
        value: '${planningPaper.ghepKho} cm',
      ),
      DataGridCell<int>(
        columnName: 'quantityOrd',
        value: orderCell.quantityManufacture,
      ),
      DataGridCell<int>(
        columnName: "runningPlanProd",
        value: planningPaper.runningPlan,
      ),
      // DataGridCell<int>(
      //   columnName: "qtyProduced",
      //   value: planningPaper.qtyProduced ?? 0,
      // ),
      DataGridCell<int>(
        columnName: "qtyReported",
        value: reportPaper.qtyProduced,
      ),
      DataGridCell<int>(columnName: "lackOfQty", value: reportPaper.lackOfQty),
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value: PlanningPaper.formatTimeOfDay(planningPaper.timeRunning!),
      ),
      DataGridCell<String>(
        columnName: "HD_special",
        value: orderCell.instructSpecial ?? '',
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(orderCell.totalPrice)} VND',
      ),
    ];
  }

  List<DataGridCell> buildWasteNormCell(ReportPaperModel reportPaper) {
    final planningPaper = reportPaper.planningPaper!;
    return [
      DataGridCell<String>(
        columnName: 'bottom',
        value: planningPaper.bottom != 0 ? '${planningPaper.bottom} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteE',
        value: planningPaper.fluteE != 0 ? '${planningPaper.fluteE} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteB',
        value: planningPaper.fluteB != 0 ? '${planningPaper.fluteB} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteC',
        value: planningPaper.fluteC != 0 ? '${planningPaper.fluteC} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'knife',
        value: planningPaper.knife != 0 ? '${planningPaper.knife} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'totalLoss',
        value:
            planningPaper.totalLoss != 0
                ? '${planningPaper.totalLoss} kg'
                : "0",
      ),
      DataGridCell<String>(
        columnName: 'qtyWasteRp',
        value:
            reportPaper.qtyWasteNorm != 0
                ? '${reportPaper.qtyWasteNorm} kg'
                : "0",
      ),
      DataGridCell<String>(
        columnName: 'shiftProduct',
        value: reportPaper.shiftProduction,
      ),
      DataGridCell<String>(
        columnName: 'shiftManager',
        value: reportPaper.shiftManagement,
      ),
      DataGridCell<bool>(
        columnName: 'hasMadeBox',
        value: reportPaper.planningPaper!.hasBox,
      ),
    ];
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ['hasMadeBox'];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? 'Có' : '';
    }

    return value?.toString() ?? '';
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    reportDataGridRows =
        reportPapers.map<DataGridRow>((report) {
          return DataGridRow(
            cells: [
              ...buildReportInfoCells(report),
              ...buildWasteNormCell(report),
            ],
          );
        }).toList();

    notifyListeners();
  }

  @override
  Widget? buildGroupCaptionCellWidget(
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(
      r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$',
      caseSensitive: false,
    );
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
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'reportPaperId')
            .value;
    final isSelected = selectedReportId?.contains(reportPaperId);

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
            Color cellColor = Colors.transparent;

            if (dataCell.columnName == "lackOfQty") {
              final int value = dataCell.value ?? 0;
              final String display =
                  value < 0 ? "+${value.abs()}" : value.toString();

              Color textColor = Colors.black;

              if (value > 0) {
                textColor = Colors.redAccent;
              } else if (value < 0) {
                textColor = Colors.green;
              }

              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
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

            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cellColor,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                _formatCellValueBool(dataCell),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}
