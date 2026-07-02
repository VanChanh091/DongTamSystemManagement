import 'package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_box_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectionBoxDataSource extends DataGridSource {
  List<QcInspectionBoxModel> inspectionBoxes = [];
  List<int> selectedBoxIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  InspectionBoxDataSource({
    required this.inspectionBoxes,
    required this.selectedBoxIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildInspectionBoxCells(QcInspectionBoxModel inspectionBox, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),

      //hidden fields
      DataGridCell<int>(columnName: 'inspecBoxId', value: inspectionBox.inspecBoxId),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        inspectionBoxes.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildInspectionBoxCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final inspecBoxId = row.getCells().firstWhere((cell) => cell.columnName == 'inspecBoxId').value;
    final isSelected = selectedBoxIds.contains(inspecBoxId);

    Color backgroundColor;
    if (isSelected == true) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = dataCell.value;

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: cellText?.toString() ?? "", alignment: alignment);
          }).toList(),
    );
  }
}
