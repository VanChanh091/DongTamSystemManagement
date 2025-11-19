import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardBoxDataSource extends DataGridSource {
  List<PlanningBox> dbBoxes = [];
  int? selectedDbBoxId;

  late List<DataGridRow> customerDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  DashboardBoxDataSource({required this.dbBoxes, this.selectedDbBoxId}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildCustomerCells(PlanningBox box) {
    return [
      // DataGridCell<String>(columnName: "rateCustomer", value: customer.rateCustomer ?? ""),
    ];
  }

  @override
  List<DataGridRow> get rows => customerDataGridRows;

  void buildDataGridRows() {
    customerDataGridRows =
        dbBoxes.map<DataGridRow>((box) {
          return DataGridRow(cells: buildCustomerCells(box));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final customerId = row.getCells().firstWhere((cell) => cell.columnName == 'customerId').value;

    Color backgroundColor;
    if (selectedDbBoxId == customerId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: dataCell.value?.toString() ?? "", alignment: alignment);
          }).toList(),
    );
  }
}
