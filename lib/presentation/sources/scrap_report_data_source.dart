import 'package:dongtam/data/models/scrap/scrap_report_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ScrapReportDataSource extends DataGridSource {
  List<ScrapReportModel> scrapReports = [];
  List<int> selectedScrapIds = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> scrapDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  ScrapReportDataSource({
    required this.scrapReports,
    required this.selectedScrapIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildScrapReportCells(ScrapReportModel scrapReport, int index) {
    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<int>(columnName: "scrapId", value: scrapReport.scrapId),
    ];
  }

  @override
  List<DataGridRow> get rows => scrapDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    scrapDataGridRows =
        scrapReports.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildScrapReportCells(entry.value, globalIndex));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final scrapId = row.getCells().firstWhere((cell) => cell.columnName == 'scrapId').value;

    final isSelected = selectedScrapIds.contains(scrapId);

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            String displayValue = dataCell.value?.toString() ?? "";

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
