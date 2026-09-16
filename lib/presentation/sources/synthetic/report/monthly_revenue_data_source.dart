import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/reportRevenue/report_monthly_revenue_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:dongtam/utils/logger/app_logger.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class MonthlyRevenueDataSource extends DataGridSource {
  final List<MonthlyRevenueReport> dailyReports;
  final MonthlyRevenueSummary? summary;
  final int month;
  final int year;

  final formatter = DateFormat("dd/MM/yyyy");

  List<DataGridRow> _rows = [];

  MonthlyRevenueDataSource({
    required this.dailyReports,
    this.summary,
    required this.month,
    required this.year,
  }) {
    _buildMonthlyRevenueRows();
  }

  @override
  List<DataGridRow> get rows => _rows;

  void _buildMonthlyRevenueRows() {
    _rows =
        dailyReports.asMap().entries.map((entry) {
          return DataGridRow(cells: buildMonthlyRevenueCells(entry.value, entry.key));
        }).toList();
  }

  List<DataGridCell> buildMonthlyRevenueCells(MonthlyRevenueReport item, int index) {
    String displayDate = item.date;
    if (item.date.contains("-")) {
      try {
        final parsed = DateTime.parse(item.date);
        displayDate = formatter.format(parsed);
      } catch (_) {
        AppLogger.e("Error parsing date: ${item.date}");
      }
    }

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "date", value: displayDate),
      DataGridCell<int>(columnName: "orderApprovedAmount", value: item.orderApprovedAmount),
      DataGridCell<int>(columnName: "productionAmount", value: item.productionAmount),
      DataGridCell<int>(columnName: "salesAmount", value: item.salesAmount),
      DataGridCell<int>(columnName: "returnAmount", value: item.returnAmount),
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
        label: summaryValue.isEmpty ? "Tổng cộng" : summaryValue,
        alignment: Alignment.center,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );
    }

    if (summary != null) {
      final val = switch (summaryColumn.columnName) {
        "orderApprovedAmount" => summary!.totalOrderApproved,
        "productionAmount" => summary!.totalProduction,
        "salesAmount" => summary!.totalSales,
        "returnAmount" => summary!.totalReturn,
        _ => 0,
      };

      return formatDataTable(
        label: val == 0 ? "-" : OrderModel.formatCurrency(val.toDouble()),
        alignment: Alignment.centerRight,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      );
    }

    return formatDataTable(label: "", alignment: Alignment.center);
  }
}
