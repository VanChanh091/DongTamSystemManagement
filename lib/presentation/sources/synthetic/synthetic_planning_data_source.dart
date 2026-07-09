import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DashboardPaperDataSource extends DataGridSource {
  List<PlanningPaperModel> dbPlanning = [];
  int? selectedDbPaperId;
  String page;
  int currentPage;
  int pageSize;

  late List<DataGridRow> dbPaperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  DashboardPaperDataSource({
    required this.dbPlanning,
    this.selectedDbPaperId,
    required this.page,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildDbPaperCells(PlanningPaperModel paper, int index) {
    final order = paper.order;

    DataGridCell<String> buildGridCell(String columnName, DateTime? value) {
      return DataGridCell<String>(
        columnName: columnName,
        value: value != null ? formatter.format(value) : "",
      );
    }

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: paper.orderId),

      //customer & product
      DataGridCell<String>(columnName: "customerName", value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),

      //structure
      DataGridCell<String>(columnName: 'structure', value: paper.formatterStructureOrder),

      //day
      buildGridCell("dayReceive", order?.dayReceiveOrder),
      buildGridCell("dayStartProduction", paper.dayStart),
      buildGridCell("dayCompletedProd", paper.dayCompleted),
      buildGridCell("dayCompletedOvfl", paper.timeOverflowPlanning?.overflowDayCompleted),

      //other fields
      DataGridCell<String>(columnName: 'flute', value: order?.flute ?? ''),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${paper.ghepKho} cm'),
      DataGridCell<String>(
        columnName: 'QcBox',
        value: order?.QC_box != null && order!.QC_box!.isNotEmpty ? '${order.QC_box} cm' : '',
      ),
      DataGridCell<String>(columnName: 'daoXa', value: order?.daoXa ?? ''),
      DataGridCell<String>(columnName: 'size', value: '${paper.sizePaperPLaning} cm'),
      DataGridCell<String>(
        columnName: 'length',
        value: paper.lengthPaperPlanning > 0 ? '${paper.lengthPaperPlanning} cm' : "0",
      ),
      DataGridCell<int>(columnName: 'child', value: paper.numberChild),

      //quantity
      DataGridCell<int>(columnName: 'quantityOrd', value: order?.quantityManufacture ?? 0),
      DataGridCell<int>(columnName: "qtyProduced", value: paper.qtyProduced),
      DataGridCell<int>(columnName: "runningPlanProd", value: paper.runningPlan),
      DataGridCell<int>(
        columnName: "qtyInventory",
        value: paper.order?.Inventory?.qtyInventory ?? 0,
      ),

      //time running
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            paper.timeRunning != null
                ? PlanningPaperModel.formatTimeOfDay(timeOfDay: paper.timeRunning!)
                : '',
      ),
      DataGridCell<String>(
        columnName: 'timeRunningOvfl',
        value:
            paper.timeOverflowPlanning?.overflowTimeRunning != null
                ? PlanningPaperModel.formatTimeOfDay(
                  timeOfDay: paper.timeOverflowPlanning!.overflowTimeRunning!,
                )
                : '',
      ),
      DataGridCell<String>(columnName: "instructSpecial", value: order?.instructSpecial ?? ''),
      DataGridCell<String>(columnName: "dvt", value: order?.dvt ?? ""),

      //Waste
      if (page == "dashboard") ...[...buildWasteAndManufactureCells(paper)],

      DataGridCell<bool>(columnName: "chongTham", value: order?.chongTham ?? false),
      DataGridCell<bool>(columnName: "isBox", value: order?.isBox ?? false),

      // hidden technical fields
      DataGridCell<int>(columnName: "planningId", value: paper.planningId),
    ];
  }

  List<DataGridCell> buildWasteAndManufactureCells(PlanningPaperModel paper) {
    DataGridCell<String> buildWasteCell({required String columnName, required double value}) {
      return DataGridCell<String>(columnName: columnName, value: value != 0 ? '$value kg' : '0');
    }

    return [
      //Phe lieu
      buildWasteCell(columnName: 'bottom', value: paper.bottom ?? 0),
      buildWasteCell(columnName: 'fluteE', value: paper.fluteE ?? 0),
      buildWasteCell(columnName: 'fluteE2', value: paper.fluteE2 ?? 0),
      buildWasteCell(columnName: 'fluteB', value: paper.fluteB ?? 0),
      buildWasteCell(columnName: 'fluteC', value: paper.fluteC ?? 0),
      buildWasteCell(columnName: 'knife', value: paper.knife ?? 0),
      buildWasteCell(columnName: 'totalLoss', value: paper.totalLoss ?? 0),

      //san xuat
      buildWasteCell(columnName: 'qtyWastes', value: paper.qtyWasteNorm ?? 0),
      DataGridCell<String>(columnName: "shiftProduct", value: paper.shiftProduction),
      DataGridCell<String>(columnName: "shiftManager", value: paper.shiftManagement),
      DataGridCell<String>(columnName: "machine", value: paper.chooseMachine),
    ];
  }

  @override
  List<DataGridRow> get rows => dbPaperDataGridRows;

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ['chongTham', 'isBox'];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    dbPaperDataGridRows =
        dbPlanning.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;
          final cells = buildDbPaperCells(entry.value, globalIndex);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final planningId = row.getCells().firstWhere((cell) => cell.columnName == 'planningId').value;

    Color backgroundColor;
    if (selectedDbPaperId == planningId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
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
