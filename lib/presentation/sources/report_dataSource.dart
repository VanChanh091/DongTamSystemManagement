import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/report/report_production_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ReportDatasource extends DataGridSource {
  List<ReportProductionModel> report = [];
  String? selectedReportId;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ReportDatasource({required this.report, required this.selectedReportId}) {
    buildDataGridRows();
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
        columnName: 'dayProduction',
        value:
            reportData.dayStart != null
                ? formatter.format(reportData.dayStart!)
                : null,
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
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(reportData.order!.totalPrice)} VND',
      ),
      DataGridCell<double>(columnName: 'bottom', value: reportData.bottom),
      DataGridCell<double>(columnName: 'fluteE', value: reportData.fluteE),
      DataGridCell<double>(columnName: 'fluteB', value: reportData.fluteB),
      DataGridCell<double>(columnName: 'fluteC', value: reportData.fluteC),
      DataGridCell<double>(
        columnName: 'totalLoss',
        value: reportData.totalLoss,
      ),
      DataGridCell<int>(columnName: 'qtyActually', value: report.qtyActually),
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
