import 'package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_paper_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class InspectionPaperDataSource extends DataGridSource {
  List<QcInspectionPaperModel> inspectionPapers = [];
  List<int> selectedPaperIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayReported = DateFormat("dd/MM/yyyy HH:mm:ss");

  InspectionPaperDataSource({
    required this.inspectionPapers,
    required this.selectedPaperIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildInspectionPaperCells(QcInspectionPaperModel inspectionPaper, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),

      //hidden fields
      DataGridCell<int>(columnName: 'inspecPaperId', value: inspectionPaper.inspecPaperId),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        inspectionPapers.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildInspectionPaperCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final inspecPaperId =
        row.getCells().firstWhere((cell) => cell.columnName == 'inspecPaperId').value;
    final isSelected = selectedPaperIds.contains(inspecPaperId);

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
