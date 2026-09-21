import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/synthetic/errorProduction/yearly_error_production_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class YearlyErrProductionDataSource extends DataGridSource {
  final List<YearlyErrorReportRow> rowsData;
  final YearlyErrorReportSummary? summary;

  List<DataGridRow> _gridRows = [];

  YearlyErrProductionDataSource({required this.rowsData, this.summary}) {
    _buildRows();
  }

  @override
  List<DataGridRow> get rows => _gridRows;

  List<DataGridCell> buildYearlyErrProductionCells(YearlyErrorReportRow row, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index),
      DataGridCell<String>(columnName: "criteriaName", value: row.criteriaName),
      DataGridCell<double>(columnName: "totalTonnage", value: row.totalMetrics.tonnage),
      DataGridCell<int>(columnName: "totalErrors", value: row.totalMetrics.errorCount),
      DataGridCell<double>(columnName: "totalErrorRate", value: row.totalMetrics.errorRate),

      for (int m = 1; m <= 12; m++) ...[
        DataGridCell<double>(
          columnName: "m_${m}_tonnage",
          value: row.monthlyMetrics[m]?.tonnage ?? 0.0,
        ),
        DataGridCell<int>(
          columnName: "m_${m}_errors",
          value: row.monthlyMetrics[m]?.errorCount ?? 0,
        ),
        DataGridCell<double>(
          columnName: "m_${m}_rate",
          value: row.monthlyMetrics[m]?.errorRate ?? 0.0,
        ),
      ],
    ];
  }

  void _buildRows() {
    _gridRows =
        rowsData.asMap().entries.map((entry) {
          final int index = entry.key + 1;
          final row = entry.value;

          return DataGridRow(cells: buildYearlyErrProductionCells(row, index));
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

            if (colName == "index") {
              alignment = Alignment.center;
              displayValue = value?.toString() ?? "";
            } else if (colName == "criteriaName") {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            } else if (colName.endsWith("tonnage") || colName == "totalTonnage") {
              alignment = Alignment.centerRight;
              final numVal = (value as num?)?.toDouble() ?? 0.0;
              displayValue = numVal == 0 ? "-" : numVal.toStringAsFixed(3);
            } else if (colName.endsWith("errors") || colName == "totalErrors") {
              alignment = Alignment.center;
              final numVal = (value as num?)?.toInt() ?? 0;
              displayValue = numVal == 0 ? "-" : numVal.toString();
              if (numVal > 0) {
                textStyle = const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                );
              }
            } else if (colName.endsWith("rate") || colName == "totalErrorRate") {
              alignment = Alignment.centerRight;
              final numVal = (value as num?)?.toDouble() ?? 0.0;
              displayValue = numVal == 0 ? "-" : numVal.toStringAsFixed(2);
            } else {
              if (value is num) {
                alignment = Alignment.centerRight;
                final numVal = value.toDouble();
                displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);
              } else {
                alignment = Alignment.centerLeft;
                displayValue = value?.toString() ?? "";
              }
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

    final colName = summaryColumn.columnName;

    // 1. Cột Tấn giấy (Cả năm hoặc theo tháng)
    if (colName.endsWith("tonnage") || colName == "totalTonnage") {
      final ton = _getSummaryTonnage(colName);
      return _buildSummaryCell(
        label: ton == 0 ? "-" : ton.toStringAsFixed(3),
        alignment: Alignment.centerRight,
      );
    }

    // 2. Cột Số lỗi (Cả năm hoặc theo tháng)
    if (colName.endsWith("errors") || colName == "totalErrors") {
      final err = _getSummaryErrors(colName);
      return _buildSummaryCell(
        label: err == 0 ? "-" : err.toString(),
        alignment: Alignment.center,
        textColor: err > 0 ? Colors.red : null,
      );
    }

    // 3. Cột Tỉ lệ lỗi (Cả năm hoặc theo tháng)
    if (colName.endsWith("rate") || colName == "totalErrorRate") {
      final rate = _getSummaryErrorRate(colName);
      return _buildSummaryCell(
        label: rate == 0 ? "-" : rate.toStringAsFixed(2),
        alignment: Alignment.centerRight,
      );
    }

    return formatDataTable(label: "", alignment: Alignment.center);
  }

  // --- Helper Methods ---

  double _getSummaryTonnage(String colName) {
    if (colName == "totalTonnage") return summary?.totalTonnage ?? 0.0;
    final m = int.tryParse(colName.split("_")[1]) ?? 0;
    return summary?.monthlyMetrics[m]?.tonnage ?? 0.0;
  }

  int _getSummaryErrors(String colName) {
    if (colName == "totalErrors") return summary?.totalErrorCount ?? 0;
    final m = int.tryParse(colName.split("_")[1]) ?? 0;
    return summary?.monthlyMetrics[m]?.errorCount ?? 0;
  }

  double _getSummaryErrorRate(String colName) {
    if (colName == "totalErrorRate") return summary?.totalErrorRate ?? 0.0;
    final m = int.tryParse(colName.split("_")[1]) ?? 0;
    return summary?.monthlyMetrics[m]?.errorRate ?? 0.0;
  }

  Widget _buildSummaryCell({
    required String label,
    required Alignment alignment,
    Color? textColor,
  }) {
    return formatDataTable(
      label: label,
      alignment: alignment,
      textStyle: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }
}
