import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachinePaperDatasource extends DataGridSource {
  List<PlanningPaper> planning = [];
  List<String> selectedPlanningIds = [];
  UnsavedChangeController? unsavedChange;
  bool isShowPlanningPaper;
  bool showGroup;
  bool hasBox;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");
  bool hasSortedInitially = false;

  MachinePaperDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    this.unsavedChange,
    this.isShowPlanningPaper = false,
    this.hasBox = false,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(
        ColumnGroup(name: 'dayStartProduction', sortGroupRows: false),
      );
    }
  }

  // create list cell for planning
  List<DataGridCell> buildPlanningInfoCells(PlanningPaper planning) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: planning.orderId),
      DataGridCell<String>(
        columnName: 'customerName',
        value: planning.order?.customer?.customerName ?? '',
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            planning.order?.dateRequestShipping != null
                ? formatter.format(planning.order!.dateRequestShipping)
                : '',
      ),
      DataGridCell<String?>(
        columnName: "dayCompletedProd",
        value:
            planning.dayCompleted != null
                ? formatterDayCompleted.format(planning.dayCompleted!)
                : null,
      ),
      DataGridCell<String>(
        columnName: 'structure',
        value: planning.formatterStructureOrder,
      ),
      DataGridCell<String>(
        columnName: 'flute',
        value: planning.order?.flute ?? '',
      ),
      DataGridCell<String>(
        columnName: 'daoXa',
        value: planning.order?.daoXa ?? '',
      ),
      DataGridCell<String>(
        columnName: 'length',
        value: '${planning.lengthPaperPlanning} cm',
      ),
      DataGridCell<String>(
        columnName: 'size',
        value: '${planning.sizePaperPLaning} cm',
      ),
      DataGridCell<int>(columnName: 'child', value: planning.numberChild),
      DataGridCell<String>(
        columnName: 'khoCapGiay',
        value: '${planning.ghepKho} cm',
      ),
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            planning.timeRunning != null
                ? PlanningPaper.formatTimeOfDay(planning.timeRunning!)
                : '',
      ),
      DataGridCell<int>(
        columnName: 'quantityOrd',
        value: planning.order?.quantityManufacture ?? 0,
      ),
      DataGridCell<int>(columnName: "qtyProduced", value: planning.qtyProduced),
      DataGridCell<int>(
        columnName: "runningPlanProd",
        value: planning.runningPlan,
      ),
      DataGridCell<String>(
        columnName: "HD_special",
        value: planning.order?.instructSpecial ?? '',
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(planning.order?.totalPrice ?? 0)} VND',
      ),
      DataGridCell<String>(
        columnName: 'totalPriceAfterVAT',
        value:
            '${Order.formatCurrency(planning.order?.totalPriceVAT ?? 0)} VND',
      ),
    ];
  }

  List<DataGridCell> buildWasteNormCell(PlanningPaper planning) {
    return [
      DataGridCell<String>(
        columnName: 'bottom',
        value: planning.bottom != 0 ? '${planning.bottom} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteE',
        value: planning.fluteE != 0 ? '${planning.fluteE} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteB',
        value: planning.fluteB != 0 ? '${planning.fluteB} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'fluteC',
        value: planning.fluteC != 0 ? '${planning.fluteC} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'knife',
        value: planning.knife != 0 ? '${planning.knife} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'totalLoss',
        value: planning.totalLoss != 0 ? '${planning.totalLoss} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'qtyWastes',
        value: planning.qtyWasteNorm != 0 ? '${planning.qtyWasteNorm} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'shiftProduct',
        value: planning.shiftProduction,
      ),
      DataGridCell<String>(
        columnName: 'shiftManager',
        value: planning.shiftManagement,
      ),
      DataGridCell<bool>(
        columnName: 'haveMadeBox',
        value: planning.order!.isBox,
      ),

      // hidden technical fields
      DataGridCell<String>(columnName: "status", value: planning.status),
      DataGridCell<int>(columnName: "index", value: planning.sortPlanning ?? 0),
      DataGridCell<int>(columnName: 'planningId', value: planning.planningId),
      DataGridCell<String?>(
        columnName: "dayStartProduction",
        value:
            planning.dayStart != null
                ? formatter.format(planning.dayStart!)
                : null,
      ),
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
                cells: [
                  ...buildPlanningInfoCells(planning),
                  ...buildWasteNormCell(planning),
                ],
              ),
            )
            .toList();

    notifyListeners();
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    unsavedChange?.setUnsavedChanges(true);

    List<PlanningPaper> selectedItems =
        planning
            .where((p) => idsToMove.contains(p.planningId.toString()))
            .toList();

    selectedItems.sort(
      (a, b) => planning.indexOf(a).compareTo(planning.indexOf(b)),
    );

    int minCurrentIndex = planning.length;
    for (var item in selectedItems) {
      int index = planning.indexOf(item);
      if (index != -1 && index < minCurrentIndex) {
        minCurrentIndex = index;
      }
    }

    if (minCurrentIndex == 0) return;

    List<PlanningPaper> itemsToRemove = [...selectedItems];
    itemsToRemove.sort(
      (a, b) => planning.indexOf(b).compareTo(planning.indexOf(a)),
    );
    for (var item in itemsToRemove) {
      planning.remove(item);
    }

    int newInsertIndex = minCurrentIndex - 1;
    planning.insertAll(newInsertIndex, selectedItems);

    buildDataGridRows();
  }

  // Di chuyển hàng xuống
  void moveRowDown(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    unsavedChange?.setUnsavedChanges(true);

    List<PlanningPaper> selectedItems =
        planning
            .where((p) => idsToMove.contains(p.planningId.toString()))
            .toList();

    selectedItems.sort(
      (a, b) => planning.indexOf(a).compareTo(planning.indexOf(b)),
    );

    int maxCurrentIndex = -1;
    for (var item in selectedItems) {
      int index = planning.indexOf(item);
      if (index != -1 && index > maxCurrentIndex) {
        maxCurrentIndex = index;
      }
    }

    if (maxCurrentIndex == -1 || maxCurrentIndex == planning.length - 1) return;

    PlanningPaper? elementAfterBlock;
    if (maxCurrentIndex + 1 < planning.length) {
      elementAfterBlock = planning[maxCurrentIndex + 1];
    } else {
      return;
    }

    List<PlanningPaper> itemsToRemove = [...selectedItems];
    itemsToRemove.sort(
      (a, b) => planning.indexOf(b).compareTo(planning.indexOf(a)),
    );
    for (var item in itemsToRemove) {
      planning.remove(item);
    }

    int newInsertIndex = planning.indexOf(elementAfterBlock);
    if (newInsertIndex == -1) {
      newInsertIndex = planning.length;
    } else {
      newInsertIndex = newInsertIndex + 1;
    }

    if (newInsertIndex > planning.length) {
      newInsertIndex = planning.length;
    }

    planning.insertAll(newInsertIndex, selectedItems);

    buildDataGridRows();
  }

  @override
  Widget? buildGroupCaptionCellWidget(
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(
      r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$',
      caseSensitive: false,
    );
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
        row
            .getCells()
            .firstWhere((cell) => cell.columnName == 'planningId')
            .value
            .toString();

    final isSelected = selectedPlanningIds.contains(planningId);

    // Lấy giá trị các cột cần check
    final sortPlanning = getCellValue<int>(row, 'index', 0);
    final status = getCellValue<String>(row, 'status', "");
    final runningPlan = getCellValue<int>(row, 'runningPlanProd', 0);
    final totalLoss = getCellValue<String>(row, 'totalLoss', "0");
    final qtyWastes = getCellValue<String>(row, 'qtyWastes', "0");

    // Chuyển từ "10 kg" -> 10.0
    final totalWasteLossVal =
        double.tryParse(totalLoss.replaceAll(' kg', '')) ?? 0;
    final qtyWastesVal = double.tryParse(qtyWastes.replaceAll(' kg', '')) ?? 0;

    Color? rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3); //selected row
    } else if (sortPlanning > 0 && status == "producing") {
      rowColor = Colors.orange.withValues(alpha: 0.4); //confirm production
    } else if (sortPlanning > 0 && status == "complete") {
      rowColor = Colors.green.withValues(alpha: 0.3); //have completed
    } else if (sortPlanning == 0) {
      rowColor = Colors.amberAccent.withValues(alpha: 0.3); //no sorting
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

            Color cellColor = Colors.transparent;
            if (dataCell.columnName == "qtyProduced" && runningPlan > 0) {
              cellColor = Colors.red.withValues(alpha: 0.5); //lack of qty
            } else if (dataCell.columnName == "qtyWastes" &&
                qtyWastesVal > totalWasteLossVal) {
              cellColor = Colors.red.withValues(alpha: 0.5); //lack of qty
            }

            return formatDataTable(
              label: _formatCellValueBool(dataCell),
              alignment: alignment,
              cellColor: cellColor,
            );
          }).toList(),
    );
  }
}
