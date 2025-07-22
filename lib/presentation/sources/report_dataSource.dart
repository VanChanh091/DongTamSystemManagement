import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/report/report_production_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportDatasource extends DataGridSource {
  List<ReportProductionModel> report = [];
  String? selectedReportId;
  bool showGroup;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ReportDatasource({
    required this.report,
    required this.selectedReportId,
    required this.showGroup,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(
        ColumnGroup(name: 'dayCompletedOrd', sortGroupRows: false),
      );
    }
  }

  List<DataGridCell> buildReportCells(ReportProductionModel report) {
    final reportData = report.planning;
    return [
      DataGridCell<String>(columnName: 'orderId', value: reportData!.orderId),
      DataGridCell<String>(
        columnName: 'customerName',
        value: reportData.order!.customer!.customerName,
      ),
      DataGridCell<String>(
        columnName: 'structure',
        value: reportData.formatterStructureOrder,
      ),
      DataGridCell<String>(
        columnName: 'flute',
        value: reportData.order?.flute ?? "",
      ),
      DataGridCell<String>(
        columnName: 'qc_box',
        value: reportData.order?.QC_box ?? "",
      ),
      DataGridCell<String>(
        columnName: 'dateToShipping',
        value:
            reportData.order?.dateRequestShipping != null
                ? formatter.format(reportData.dayStart!)
                : null,
      ),
      DataGridCell<String>(
        columnName: 'dayCompletedOrd',
        value: formatter.format(report.dayCompleted),
      ),
      DataGridCell<String>(
        columnName: 'instructSpecial',
        value: reportData.order?.instructSpecial ?? "",
      ),
      DataGridCell<String>(
        columnName: 'daoXa',
        value: reportData.order?.daoXa ?? "",
      ),
      DataGridCell<double>(
        columnName: 'length',
        value: reportData.lengthPaperPlanning,
      ),
      DataGridCell<double>(
        columnName: 'size',
        value: reportData.sizePaperPLaning,
      ),
      DataGridCell<int>(
        columnName: 'runningForPlan',
        value: reportData.runningPlan,
      ),
      DataGridCell<int>(columnName: 'qtyActually', value: report.qtyActually),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(reportData.order!.totalPrice)} VND',
      ),
      DataGridCell<double>(
        columnName: 'totalLoss',
        value: reportData.totalLoss,
      ),
      DataGridCell<double>(
        columnName: 'wasteActually',
        value: report.qtyWasteNorm,
      ),
      DataGridCell<String>(
        columnName: 'shiftManager',
        value: report.shiftManagement,
      ),
      DataGridCell<String>(
        columnName: 'shiftProduction',
        value: report.shiftProduction,
      ),
      DataGridCell<String>(columnName: 'note', value: report.note),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    reportDataGridRows =
        report
            .map<DataGridRow>(
              (reports) => DataGridRow(cells: buildReportCells(reports)),
            )
            .toList();

    notifyListeners();
  }

  @override
  Widget? buildGroupCaptionCellWidget(
    RowColumnIndex rowColumnIndex,
    String groupName,
  ) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(
      r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(groupName);

    String displayDate = '';
    String itemCount = '';

    if (match != null) {
      displayDate = match.group(1) ?? '';
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
            ? '📅 Ngày hoàn thành: $displayDate - $itemCount'
            : '📅 Ngày hoàn thành: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                dataCell.value?.toString() ?? "",
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
