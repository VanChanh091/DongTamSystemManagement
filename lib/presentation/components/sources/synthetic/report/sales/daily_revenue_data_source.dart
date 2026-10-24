import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/synthetic/reportRevenue/report_daily_revenue_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DailyRevenueDataSource extends DataGridSource {
  final List<CustomerDailyRevenueRow> customers;
  final DailyRevenueSummary? summary;
  final int daysInMonth;
  final int currentPage;
  final int pageSize;

  List<DataGridRow> _dailyRevenueRows = [];

  DailyRevenueDataSource({
    required this.customers,
    this.summary,
    required this.daysInMonth,
    required this.currentPage,
    required this.pageSize,
  }) {
    _buildDailyRevenueRows();
  }

  @override
  List<DataGridRow> get rows => _dailyRevenueRows;

  List<DataGridCell> builDailyRevenueCells(CustomerDailyRevenueRow customer, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "customerName", value: customer.customerName),
      DataGridCell<double>(columnName: "totalDebt", value: customer.totalCustomerDebt),
      DataGridCell<double>(columnName: "totalSales", value: customer.totalCustomerSales),

      //hidden
      DataGridCell<String>(columnName: "customerId", value: customer.customerId),

      for (int d = 1; d <= daysInMonth; d++)
        DataGridCell<double>(columnName: "d_$d", value: customer.dailyAmounts[d] ?? 0),
    ];
  }

  void _buildDailyRevenueRows() {
    final int offset = (currentPage - 1) * pageSize;

    _dailyRevenueRows =
        customers.asMap().entries.map((entry) {
          final int globalIndex = offset + entry.key;
          final customer = entry.value;

          return DataGridRow(cells: builDailyRevenueCells(customer, globalIndex));
        }).toList();
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
    // Ô tiêu đề "Tổng"
    if (summaryColumn == null) {
      return formatDataTable(
        label: summaryValue.isEmpty ? "Tổng" : summaryValue,
        alignment: Alignment.center,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    // Ô số liệu lấy từ summary
    if (summary != null) {
      final colName = summaryColumn.columnName;

      final value = _getSummaryValue(colName);
      final displayValue = value == 0 ? "-" : OrderModel.formatCurrency(value);

      return formatDataTable(
        label: displayValue,
        alignment: Alignment.centerRight,
        textStyle: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
      );
    }

    // 3. Fallback ô rỗng để giữ đúng border của bảng
    return formatDataTable(label: "", alignment: Alignment.center);
  }

  double _getSummaryValue(String columnName) {
    if (summary == null) return 0;
    final sm = summary!;

    // 1. Các cột cố định
    if (columnName == "totalDebt") return sm.totalMonthDebt;
    if (columnName == "totalSales") return sm.totalMonthSales;

    // 2. Cột ngày động dạng "d_1", "d_2", ...
    if (columnName.startsWith("d_")) {
      final int day = int.tryParse(columnName.replaceFirst("d_", "")) ?? 0;
      return sm.dailyTotals[day] ?? 0;
    }

    return 0;
  }
}
