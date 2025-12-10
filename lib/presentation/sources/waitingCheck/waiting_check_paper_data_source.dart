import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckPaperDataSource extends DataGridSource {
  List<PlanningPaper> planning = [];
  List<String> selectedPlanningIds = [];
  bool showGroup;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  bool hasSortedInitially = false;

  WaitingCheckPaperDataSource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(ColumnGroup(name: 'dayStartProduction', sortGroupRows: false));
    }
  }

  // create list cell for planning
  List<DataGridCell> buildPlanningInfoCells(PlanningPaper planning) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: planning.orderId),

      DataGridCell<String?>(
        columnName: "dayStartProduction",
        value: planning.dayStart != null ? formatter.format(planning.dayStart!) : null,
      ),
      DataGridCell<String?>(
        columnName: "dayCompletedProd",
        value:
            planning.dayCompleted != null
                ? formatterDayCompleted.format(planning.dayCompleted!)
                : null,
      ),
      DataGridCell<String>(
        columnName: 'customerName',
        value: planning.order?.customer?.customerName ?? '',
      ),
      DataGridCell<String>(columnName: 'structure', value: planning.formatterStructureOrder),
      DataGridCell<String>(columnName: 'flute', value: planning.order?.flute ?? ''),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${planning.ghepKho} cm'),
      DataGridCell<String>(columnName: 'daoXa', value: planning.order?.daoXa ?? ''),
      DataGridCell<String>(columnName: 'length', value: '${planning.lengthPaperPlanning} cm'),
      DataGridCell<String>(columnName: 'size', value: '${planning.sizePaperPLaning} cm'),
      DataGridCell<int>(columnName: 'child', value: planning.numberChild),

      DataGridCell<int>(columnName: 'quantityOrd', value: planning.order?.quantityManufacture ?? 0),
      DataGridCell<int>(columnName: "qtyProduced", value: planning.qtyProduced),
      DataGridCell<int>(columnName: "runningPlanProd", value: planning.runningPlan),

      DataGridCell<String>(
        columnName: "instructSpecial",
        value: planning.order?.instructSpecial ?? '',
      ),
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            planning.timeRunning != null
                ? PlanningPaper.formatTimeOfDay(timeOfDay: planning.timeRunning!)
                : '',
      ),
    ];
  }

  List<DataGridCell> buildWasteNormCell(PlanningPaper planning) {
    DataGridCell<String> buildWasteCell({required String columnName, required double value}) {
      return DataGridCell<String>(columnName: columnName, value: value != 0 ? '$value kg' : '0');
    }

    return [
      buildWasteCell(columnName: 'bottom', value: planning.bottom ?? 0),
      buildWasteCell(columnName: 'fluteE', value: planning.fluteE ?? 0),
      buildWasteCell(columnName: 'fluteE2', value: planning.fluteE2 ?? 0),
      buildWasteCell(columnName: 'fluteB', value: planning.fluteB ?? 0),
      buildWasteCell(columnName: 'fluteC', value: planning.fluteC ?? 0),
      buildWasteCell(columnName: 'knife', value: planning.knife ?? 0),
      buildWasteCell(columnName: 'totalLoss', value: planning.totalLoss ?? 0),
      buildWasteCell(columnName: 'qtyWastes', value: planning.qtyWasteNorm ?? 0),

      DataGridCell<bool>(columnName: 'haveMadeBox', value: planning.order!.isBox),

      // hidden technical fields
      DataGridCell<String>(columnName: "status", value: planning.status),
      DataGridCell<int>(columnName: "index", value: planning.sortPlanning ?? 0),
      DataGridCell<int>(columnName: 'planningId', value: planning.planningId),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  int extractFlute(String loaiSong) {
    //5BC => 5
    final match = RegExp(r'^\d+').firstMatch(loaiSong);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["haveMadeBox"];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>(
              (planning) => DataGridRow(
                cells: [...buildPlanningInfoCells(planning), ...buildWasteNormCell(planning)],
              ),
            )
            .toList();

    notifyListeners();
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$', caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = '';
    String itemCount = '';

    if (match != null) {
      displayDate = match.group(1) ?? '';
      final count = match.group(2) ?? '0';
      itemCount = '$count đơn hàng';
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày sản xuất: $displayDate – $itemCount'
            : '📅 Ngày sản xuất: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final planningId =
        row.getCells().firstWhere((cell) => cell.columnName == 'planningId').value.toString();

    final isSelected = selectedPlanningIds.contains(planningId);

    Color? rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3); //selected row
    } else {
      rowColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: rowColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = _formatCellValueBool(dataCell);

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == '✅') {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
