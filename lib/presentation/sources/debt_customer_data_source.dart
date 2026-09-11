import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/warehouse/payment/customer_debt_summary_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class DebtCustomerDataSource extends DataGridSource {
  final List<CustomerDebtItemModel> customers;
  final String? selectedCustomerId;
  final int currentPage;
  final int pageSize;
  final CustomerDebtItemModel? grandTotal;

  late List<DataGridRow> customerDataGridRows;

  DebtCustomerDataSource({
    required this.customers,
    required this.currentPage,
    required this.pageSize,
    this.selectedCustomerId,
    this.grandTotal,
  }) {
    buildDataGridRows();
  }

  @override
  List<DataGridRow> get rows => customerDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    customerDataGridRows =
        customers.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          return DataGridRow(cells: buildCustomerCells(entry.value, globalIndex));
        }).toList();
  }

  List<DataGridCell> buildCustomerCells(CustomerDebtItemModel item, int index) {
    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "customerId", value: item.customerId),
      DataGridCell<String>(columnName: "customerName", value: item.customerName),
      DataGridCell<int>(columnName: "unpaidOutboundCount", value: item.unpaidOutboundCount),
      DataGridCell<double>(columnName: "totalDebt", value: item.totalDebt),

      // Số tiền công nợ
      DataGridCell<double>(columnName: "notDueDebt", value: item.notDueDebt),
      DataGridCell<double>(columnName: "currentPeriodDebt", value: item.currentPeriodDebt),
      DataGridCell<double>(columnName: "closedDebt", value: item.closedDebt),
      DataGridCell<double>(columnName: "dueIn1_3", value: item.aging.dueIn1_3),

      // Tuổi nợ (Aging)
      DataGridCell<double>(columnName: "overdue1_30", value: item.aging.overdue1_30),
      DataGridCell<double>(columnName: "overdue31_60", value: item.aging.overdue31_60),
      DataGridCell<double>(columnName: "overdue61_90", value: item.aging.overdue61_90),
      DataGridCell<double>(columnName: "overdue91_120", value: item.aging.overdue91_120),
      DataGridCell<double>(columnName: "overdueOver120", value: item.aging.overdueOver120),
      DataGridCell<double>(columnName: "dueDebt", value: item.overdueDebt),
    ];
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final columnName = dataCell.columnName;

            final value = dataCell.value;
            String displayValue = "";

            Color? textColor;
            Alignment alignment = Alignment.centerLeft;

            // format cho các cột tiền
            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              displayValue = numVal == 0 ? "-" : OrderModel.formatCurrency(numVal);

              // Nổi bật cột "Nợ đến hạn" hoặc các cột nợ quá hạn có tiền > 0
              if (columnName == "dueDebt" && numVal > 0) {
                textColor = Colors.red.shade700;
              } else if (columnName.startsWith("overdue") && numVal > 0) {
                textColor = Colors.orange.shade800;
              }
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment, textColor: textColor);
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
    if (summaryColumn == null || grandTotal == null) return null;

    // Lấy giá trị từ grandTotal theo columnName
    final value = _getGrandTotalValue(summaryColumn.columnName);
    final displayValue = value == 0 ? "-" : OrderModel.formatCurrency(value);

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        displayValue,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
    );
  }

  double _getGrandTotalValue(String columnName) {
    final gt = grandTotal!;
    return switch (columnName) {
      "notDueDebt" => gt.notDueDebt,
      "currentPeriodDebt" => gt.currentPeriodDebt,
      "closedDebt" => gt.closedDebt,
      "dueIn1_3" => gt.aging.dueIn1_3,
      "overdue1_30" => gt.aging.overdue1_30,
      "overdue31_60" => gt.aging.overdue31_60,
      "overdue61_90" => gt.aging.overdue61_90,
      "overdue91_120" => gt.aging.overdue91_120,
      "overdueOver120" => gt.aging.overdueOver120,
      "dueDebt" => gt.overdueDebt,
      _ => 0,
    };
  }
}
