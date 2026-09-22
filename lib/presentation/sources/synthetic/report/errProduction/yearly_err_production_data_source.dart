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
            // Ẩn số tấn giấy ở các dòng chi tiết (chỉ hiển thị ở dòng Tổng)
            if (colName == "totalTonnage" || colName.endsWith("tonnage")) {
              alignment = Alignment.centerRight;
              displayValue = "-";
            } else if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);

              // if (colName != 'index' && numVal > 0) {
              //   textStyle = const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold);
              // }
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
    // Cột tiêu đề của dòng tổng (thường là cột đầu tiên)
    if (summaryColumn == null) {
      return formatDataTable(
        label: summaryValue.isEmpty ? "Tổng" : summaryValue,
        alignment: Alignment.center,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    final colName = summaryColumn.columnName;
    final parts = colName.split("_");
    final month = parts.length > 1 ? int.tryParse(parts[1]) : null;
    final mMetric = month != null ? summary?.monthlyMetrics[month] : null;

    // 1. Cột Tấn giấy (Cả năm hoặc theo tháng - định dạng 2 số thập phân)
    if (colName.endsWith("tonnage") || colName == "totalTonnage") {
      double ton = 0.0;
      if (summary != null) {
        ton = colName == "totalTonnage" ? summary!.totalTonnage : (mMetric?.tonnage ?? 0.0);
      } else if (rowsData.isNotEmpty) {
        // Fallback: Tấn giấy là sản lượng chung của kỳ
        ton =
            colName == "totalTonnage"
                ? rowsData.first.totalMetrics.tonnage
                : (rowsData.first.monthlyMetrics[month]?.tonnage ?? 0.0);
      }

      return _buildSummaryCell(
        label: ton == 0 ? "-" : OrderModel.formatCurrency(ton),
        alignment: Alignment.centerRight,
      );
    }

    // 2. Cột Số lỗi (Cả năm hoặc theo tháng)
    if (colName.endsWith("errors") || colName == "totalErrors") {
      int err = 0;
      if (summary != null) {
        err = colName == "totalErrors" ? summary!.totalErrorCount : (mMetric?.errorCount ?? 0);
      } else {
        // Fallback: Tổng số lỗi cộng dồn từ tất cả tiêu chí
        err = rowsData.fold<int>(
          0,
          (sum, row) =>
              sum +
              (colName == "totalErrors"
                  ? row.totalMetrics.errorCount
                  : (row.monthlyMetrics[month]?.errorCount ?? 0)),
        );
      }

      return _buildSummaryCell(
        label: err == 0 ? "-" : OrderModel.formatCurrency(err),
        alignment: Alignment.centerRight,
      );
    }

    // 3. Cột Tỉ lệ lỗi (Cả năm hoặc theo tháng)
    if (colName.endsWith("rate") || colName == "totalErrorRate") {
      // Cộng trực tiếp tỉ lệ của các dòng chi tiết để số dòng Tổng khớp 100% với hiển thị bên trên
      final double rate = rowsData.fold<double>(
        0.0,
        (sum, row) =>
            sum +
            (colName == "totalErrorRate"
                ? row.totalMetrics.errorRate
                : (row.monthlyMetrics[month]?.errorRate ?? 0.0)),
      );

      return _buildSummaryCell(
        label: rate == 0 ? "-" : OrderModel.formatCurrency(rate),
        alignment: Alignment.centerRight,
      );
    }

    return formatDataTable(label: "", alignment: Alignment.center);
  }

  // Giữ lại duy nhất hàm dựng cell format chung này cho gọn UI
  Widget _buildSummaryCell({
    required String label,
    required Alignment alignment,
    Color? textColor,
  }) {
    return formatDataTable(
      label: label,
      alignment: alignment,
      textStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor),
    );
  }
}
