import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/synthetic/reportRevenue/report_yearly_revenue_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class YearlyRevenueDataSource extends DataGridSource {
  final List<CustomerYearRevenue> customers;
  final MultiYearSummary? summary;
  final List<int> years;
  final int currentPage;
  final int pageSize;

  List<DataGridRow> _yearlyRevenueRows = [];

  YearlyRevenueDataSource({
    required this.customers,
    this.summary,
    required this.years,
    required this.currentPage,
    required this.pageSize,
  }) {
    _buildYearlyRevenueRows();
  }

  @override
  List<DataGridRow> get rows => _yearlyRevenueRows;

  void _buildYearlyRevenueRows() {
    final int offset = (currentPage - 1) * pageSize;

    _yearlyRevenueRows =
        customers.asMap().entries.map((entry) {
          final int globalIndex = offset + entry.key;
          final c = entry.value;

          return DataGridRow(cells: buildsYearlyRevenueCells(c, globalIndex));
        }).toList();
  }

  List<DataGridCell> buildsYearlyRevenueCells(CustomerYearRevenue item, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "customerName", value: item.customerName),
      DataGridCell<int>(columnName: "currentDebt", value: item.currentDebt),
      DataGridCell<int>(columnName: "grandTotal", value: item.grandTotal),

      //hidden
      DataGridCell<String>(columnName: "customerId", value: item.customerId),

      for (final y in years) ...[
        for (int m = 1; m <= 12; m++)
          DataGridCell<int>(columnName: "y_${y}_m_$m", value: item.years[y]?.months[m] ?? 0),
        DataGridCell<int>(columnName: "y_${y}_total", value: item.years[y]?.yearTotal ?? 0),
      ],
    ];
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;
            String displayValue = "";

            Alignment alignment = Alignment.centerLeft;
            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment);
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

      final int amount = _getSummaryValue(colName);
      final String displayValue = amount == 0 ? "-" : OrderModel.formatCurrency(amount);

      return formatDataTable(
        label: displayValue,
        alignment: Alignment.centerRight,
        textStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
      );
    }

    return formatDataTable(label: "", alignment: Alignment.center);
  }

  /// Tách riêng logic bóc tách dữ liệu theo columnName
  int _getSummaryValue(String columnName) {
    if (summary == null) return 0;
    final sm = summary!;

    if (columnName == "currentDebt") return sm.totalCurrentDebt;
    if (columnName == "grandTotal") return sm.grandTotal;

    // Xử lý các cột năm/tháng động: y_2024_total, y_2024_m_1, ...
    if (columnName.startsWith("y_")) {
      final parts = columnName.split("_");

      // Dạng: y_{year}_m_{month}
      if (parts.length >= 4 && parts[2] == "m") {
        final y = int.tryParse(parts[1]);
        final m = int.tryParse(parts[3]);
        if (y != null && m != null) {
          return sm.years[y]?.months[m] ?? 0;
        }
      }
      // Dạng: y_{year}_total
      else if (parts.length >= 3 && parts[2] == "total") {
        final y = int.tryParse(parts[1]);
        if (y != null) {
          return sm.years[y]?.yearTotal ?? 0;
        }
      }
    }

    return 0;
  }
}
