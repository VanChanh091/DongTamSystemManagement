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

  late List<DataGridRow> customerDataGridRows;

  DebtCustomerDataSource({
    required this.customers,
    required this.currentPage,
    required this.pageSize,
    this.selectedCustomerId,
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
      DataGridCell<double>(columnName: "dueIn1_3", value: item.aging.dueIn1_3),

      // Số tiền công nợ
      DataGridCell<double>(columnName: "totalDebt", value: item.totalDebt),
      DataGridCell<double>(columnName: "closedDebt", value: item.closedDebt),
      DataGridCell<double>(columnName: "currentPeriodDebt", value: item.currentPeriodDebt),
      DataGridCell<double>(columnName: "notDueDebt", value: item.notDueDebt),
      DataGridCell<double>(columnName: "dueDebt", value: item.dueDebt),

      // Tuổi nợ (Aging)
      DataGridCell<double>(columnName: "overdue1_30", value: item.aging.overdue1_30),
      DataGridCell<double>(columnName: "overdue31_60", value: item.aging.overdue31_60),
      DataGridCell<double>(columnName: "overdue61_90", value: item.aging.overdue61_90),
      DataGridCell<double>(columnName: "overdueOver90", value: item.aging.overdueOver90),
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
            Alignment alignment = Alignment.centerLeft;
            Color? textColor;

            // 3. Căn phải & Format tiền tệ cho các cột tiền / tuổi nợ
            if (value is num) {
              alignment = Alignment.centerRight;

              final numVal = value.toDouble();
              if (numVal == 0) {
                displayValue = "-";
              } else {
                displayValue = OrderModel.formatCurrency(numVal);
              }

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
}
