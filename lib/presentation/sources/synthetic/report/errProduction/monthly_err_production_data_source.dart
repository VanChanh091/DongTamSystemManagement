import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/synthetic/errorProduction/monthly_error_production_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class MonthlyErrProductionDataSource extends DataGridSource {
  final List<MonthlyErrorReportRow> rowsData;
  final MonthlyErrorReportSummary? summary;
  final int daysInMonth;

  List<DataGridRow> _monthlyErrProductionRows = [];

  MonthlyErrProductionDataSource({
    required this.rowsData,
    this.summary,
    required this.daysInMonth,
  }) {
    _buildRows();
  }

  @override
  List<DataGridRow> get rows => _monthlyErrProductionRows;

  List<DataGridCell> buildMonthlyErrProductionCells(MonthlyErrorReportRow row, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index),
      DataGridCell<String>(columnName: "machine", value: row.machine),
      DataGridCell<String>(columnName: "employeeName", value: row.employeeName),
      DataGridCell<int>(columnName: "totalErrors", value: row.totalErrors),

      for (int d = 1; d <= daysInMonth; d++)
        DataGridCell<int>(columnName: "d_$d", value: row.dailyErrors[d] ?? 0),
    ];
  }

  void _buildRows() {
    _monthlyErrProductionRows =
        rowsData.asMap().entries.map((entry) {
          final int index = entry.key + 1;
          final row = entry.value;

          return DataGridRow(cells: buildMonthlyErrProductionCells(row, index));
        }).toList();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;
            final colName = dataCell.columnName;

            String displayValue = "";
            TextStyle? textStyle;

            Alignment alignment = Alignment.centerLeft;
            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);

              if (colName != 'index' && numVal > 0) {
                textStyle = const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold);
              }
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment, textStyle: textStyle);
          }).toList(),
    );
  }

  @override
  Widget? buildTableSummaryCellWidget(
    GridTableSummaryRow summaryRow,
    GridSummaryColumn? summaryColumn,
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    if (summaryColumn == null) {
      return formatDataTable(
        label: summaryValue.isEmpty ? "Tổng" : summaryValue,
        alignment: Alignment.center,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    if (summary != null) {
      final colName = summaryColumn.columnName;
      final int value = _getSummaryValue(colName);
      final displayValue = value == 0 ? "-" : value.toString();

      return formatDataTable(
        label: displayValue,
        alignment: Alignment.centerRight,
        textStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
      );
    }

    return formatDataTable(label: "", alignment: Alignment.center);
  }

  int _getSummaryValue(String columnName) {
    if (summary == null) return 0;
    if (columnName == "totalErrors") return summary!.totalError;
    if (columnName.startsWith("d_")) {
      final int day = int.tryParse(columnName.replaceFirst("d_", "")) ?? 0;
      return summary!.dailyTotals[day] ?? 0;
    }
    return 0;
  }
}
