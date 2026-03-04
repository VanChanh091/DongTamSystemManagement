import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/planning_helper.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachinePaperDatasource extends DataGridSource {
  List<PlanningPaper> planning = [];
  List<String> selectedPlanningIds = [];
  UnsavedChangeController? unsavedChange;
  bool showGroup;
  String page;

  late List<DataGridRow> planningDataGridRows;
  late List<String> visibleColumns;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  bool hasSortedInitially = false;

  MachinePaperDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    required this.page,
    this.unsavedChange,
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

      if (page == 'planning') ...[
        DataGridCell<String>(
          columnName: "dateShipping",
          value:
              planning.order?.dateRequestShipping != null
                  ? formatter.format(planning.order!.dateRequestShipping!)
                  : '',
        ),
      ],

      DataGridCell<String?>(
        columnName: "dayStartProduction",
        value: planning.dayStart != null ? formatter.format(planning.dayStart!) : null,
      ),
      DataGridCell<String>(
        columnName: 'customerName',
        value: planning.order?.customer?.customerName ?? '',
      ),
      DataGridCell<String>(columnName: 'structure', value: planning.formatterStructureOrder),
      DataGridCell<String>(columnName: 'flute', value: planning.order?.flute ?? ''),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${planning.ghepKho} cm'),
      DataGridCell<String>(columnName: 'daoXa', value: planning.order?.daoXa ?? ''),
      DataGridCell<String>(
        columnName: 'length',
        value: planning.lengthPaperPlanning > 0 ? '${planning.lengthPaperPlanning} cm' : "0",
      ),
      DataGridCell<String>(
        columnName: 'size',
        value: planning.sizePaperPLaning > 0 ? '${planning.sizePaperPLaning} cm' : '0',
      ),
      DataGridCell<int>(columnName: 'child', value: planning.numberChild),

      DataGridCell<int>(columnName: 'quantityOrd', value: planning.order?.quantityManufacture ?? 0),
      DataGridCell<int>(columnName: "qtyProduced", value: planning.qtyProduced),
      DataGridCell<int>(columnName: "runningPlanProd", value: planning.remainRunningPlan),

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
      if (page == "planning") ...[
        DataGridCell<String>(
          columnName: 'totalPrice',
          value:
              (planning.order?.totalPrice ?? 0) > 0
                  ? '${Order.formatCurrency(planning.order?.totalPrice ?? 0)} VND'
                  : "0",
        ),
      ],
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

      if (page == 'planning') ...[
        DataGridCell<String>(columnName: 'shiftProduct', value: planning.shiftProduction),
        DataGridCell<String>(columnName: 'shiftManager', value: planning.shiftManagement),
      ],

      DataGridCell<String?>(
        columnName: "dayCompletedProd",
        value:
            planning.dayCompleted != null
                ? formatterDayCompleted.format(planning.dayCompleted!)
                : null,
      ),

      DataGridCell<bool>(columnName: 'haveMadeBox', value: planning.order!.isBox),

      //status request
      DataGridCell<String>(columnName: "statusRequest", value: planning.statusRequest),

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

    if (dataCell.columnName == "statusRequest") {
      switch (value) {
        case "requested":
          return "Chờ nhập kho";
        case "reject":
          return "Từ chối";
        case "inbounded":
          return "Đã nhập kho";
        case "finalize":
          return "Chốt nhập kho";
        case "none":
        default:
          return "";
      }
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

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    PlanningListHelper.moveRows<PlanningPaper>(
      list: planning,
      idsToMove: idsToMove,
      getId: (p) => p.planningId.toString(),
      moveUp: true,
      onUpdate: buildDataGridRows,
      unsavedChangeController: unsavedChange,
    );
  }

  // Di chuyển hàng xuống
  void moveRowDown(List<String> idsToMove) {
    PlanningListHelper.moveRows<PlanningPaper>(
      list: planning,
      idsToMove: idsToMove,
      getId: (item) => item.planningId.toString(),
      moveUp: false,
      unsavedChangeController: unsavedChange,
      onUpdate: buildDataGridRows,
    );
  }

  //check ghepKho is same
  String? getKhoAtRow(int rowIndex) {
    if (rowIndex < 0 || rowIndex >= planningDataGridRows.length) return null;

    final row = planningDataGridRows[rowIndex];
    final cell = row.getCells().firstWhere(
      (c) => c.columnName == 'khoCapGiay',
      orElse: () => const DataGridCell<String>(columnName: 'khoCapGiay', value: ''),
    );

    return cell.value?.toString();
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
    // ===== Index row =====
    final int rowIndex = planningDataGridRows.indexOf(row);

    final String? currentKho = getKhoAtRow(rowIndex);
    final String? prevKho = getKhoAtRow(rowIndex - 1);

    // print("Row $rowIndex: currentKho = $currentKho, prevKho = $prevKho");

    // ===== chuyển khổ =====
    final bool isKhoTransition =
        rowIndex > 0 && currentKho != null && prevKho != null && currentKho != prevKho;

    // ===== select and row color =====
    final planningId =
        row.getCells().firstWhere((c) => c.columnName == 'planningId').value.toString();

    final isSelected = selectedPlanningIds.contains(planningId);

    final sortPlanning = getCellValue<int>(row, 'index', 0);
    final status = getCellValue<String>(row, 'status', "");
    final runningPlan = getCellValue<int>(row, 'runningPlanProd', 0);
    final qtyProduced = getCellValue<int>(row, 'qtyProduced', 0);
    final totalLoss = getCellValue<String>(row, 'totalLoss', "0");
    final qtyWastes = getCellValue<String>(row, 'qtyWastes', "0");

    final totalWasteLossVal = double.tryParse(totalLoss.replaceAll(' kg', '')) ?? 0;
    final qtyWastesVal = double.tryParse(qtyWastes.replaceAll(' kg', '')) ?? 0;

    Color? rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3);
    } else if (sortPlanning > 0 && status == "producing") {
      rowColor = Colors.orange.withValues(alpha: 0.4);
    } else if (sortPlanning > 0 && status == "complete") {
      rowColor = Colors.green.withValues(alpha: 0.3);
    } else if (sortPlanning == 0) {
      rowColor = Colors.amberAccent.withValues(alpha: 0.3);
    }

    // ===== color warning change ghepKho =====
    final Color? transitionColor = isKhoTransition ? Colors.orange : null;

    // ===== Build cells =====
    final widgets =
        row.getCells().asMap().entries.map<Widget>((entry) {
          final int cellIndex = entry.key;
          final DataGridCell dataCell = entry.value;

          final cellText = _formatCellValueBool(dataCell);

          Alignment alignment;
          if (dataCell.value is num) {
            alignment = Alignment.centerRight;
          } else if (cellText == '✅') {
            alignment = Alignment.center;
          } else {
            alignment = Alignment.centerLeft;
          }

          Color cellColor = Colors.transparent;
          if (dataCell.columnName == "qtyProduced" && qtyProduced < runningPlan) {
            cellColor = Colors.red.withValues(alpha: 0.5);
          } else if (dataCell.columnName == "qtyWastes" && qtyWastesVal > totalWasteLossVal) {
            cellColor = Colors.red.withValues(alpha: 0.5);
          }

          return formatDataTable(
            label: cellText,
            alignment: alignment,
            cellColor: cellColor,
            leading:
                dataCell.columnName == 'khoCapGiay' && isKhoTransition
                    ? Icon(Icons.warning_amber_rounded, size: 16, color: transitionColor)
                    : null,

            leftBorder:
                cellIndex == 0 && transitionColor != null
                    ? BorderSide(color: transitionColor, width: 4)
                    : null,
          );
        }).toList();

    return DataGridRowAdapter(color: rowColor, cells: widgets);
  }
}
