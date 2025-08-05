import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachineBoxDatasource extends DataGridSource {
  List<PlanningBox> planning = [];
  List<String> selectedPlanningIds = [];
  String machine;
  bool showGroup;
  String? producingOrderId;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  bool hasSortedInitially = false;

  MachineBoxDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    required this.machine,
    this.producingOrderId,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(
        ColumnGroup(name: 'dayStartProduction', sortGroupRows: false),
      );
    }
  }

  List<DataGridCell> buildPlanningCells(PlanningBox planning, String machine) {
    final boxMachineTime = planning.getBoxMachineTimeByMachine(machine);

    return [
      DataGridCell<String>(columnName: "orderId", value: planning.orderId),
      DataGridCell<int>(
        columnName: "planningBoxId",
        value: planning.planningBoxId,
      ),
      DataGridCell<String>(
        columnName: "customerName",
        value: planning.order?.customer?.customerName ?? "",
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            planning.order?.dateRequestShipping != null
                ? formatter.format(planning.order!.dateRequestShipping)
                : '',
      ),
      DataGridCell<String>(
        columnName: "dayStartProduction",
        value:
            planning.dayStart != null
                ? formatter.format(planning.dayStart!)
                : '',
      ),
      DataGridCell<String>(
        columnName: "dayCompletedProd",
        value:
            boxMachineTime?.dayCompleted != null
                ? formatter.format(boxMachineTime!.dayCompleted!)
                : '',
      ),
      DataGridCell<String>(
        columnName: "structure",
        value: planning.formatterStructureOrder,
      ),
      DataGridCell<String>(
        columnName: "flute",
        value: planning.order?.flute ?? "",
      ),
      DataGridCell<String>(
        columnName: "QC_box",
        value: planning.order?.QC_box ?? "",
      ),
      DataGridCell<String>(
        columnName: "length",
        value: '${planning.length} cm',
      ),
      DataGridCell<String>(columnName: "size", value: '${planning.size} cm'),
      DataGridCell<String>(
        columnName: "runningPlanProd",
        value: '${planning.runningPlan} cái',
      ),
      DataGridCell<String>(
        columnName: "qtyProduced",
        value:
            boxMachineTime?.qtyProduced != 0
                ? '${boxMachineTime?.qtyProduced} cái'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "timeRunningProd",
        value:
            boxMachineTime?.timeRunning != null
                ? PlanningBox.formatTimeOfDay(boxMachineTime!.timeRunning!)
                : '',
      ),
      DataGridCell<String>(
        columnName: "wasteLoss",
        value:
            boxMachineTime?.wasteBox != 0 && boxMachineTime?.wasteBox != null
                ? '${boxMachineTime?.wasteBox} kg'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "rpWasteNorm",
        value:
            boxMachineTime?.rpWasteLoss != 0 &&
                    boxMachineTime?.rpWasteLoss != null
                ? '${boxMachineTime?.rpWasteLoss} kg'
                : "0",
      ),
      DataGridCell<String>(
        columnName: "shiftManagement",
        value: boxMachineTime?.shiftManagement ?? "",
      ),
      DataGridCell<String>(
        columnName: "status",
        value: boxMachineTime?.status ?? "",
      ),
      DataGridCell<int>(
        columnName: "index",
        value: boxMachineTime?.sortPlanning ?? 0,
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>(
              (planning) =>
                  DataGridRow(cells: buildPlanningCells(planning, machine)),
            )
            .toList();

    notifyListeners();
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    List<PlanningBox> selectedItems =
        planning.where((p) => idsToMove.contains(p.orderId)).toList();

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

    List<PlanningBox> itemsToRemove = [...selectedItems];
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

    List<PlanningBox> selectedItems =
        planning.where((p) => idsToMove.contains(p.orderId)).toList();

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

    PlanningBox? elementAfterBlock;
    if (maxCurrentIndex + 1 < planning.length) {
      elementAfterBlock = planning[maxCurrentIndex + 1];
    } else {
      return;
    }

    List<PlanningBox> itemsToRemove = [...selectedItems];
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
    String groupName,
  ) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(
      r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$',
      caseSensitive: false,
    );
    final match = regex.firstMatch(groupName);

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
            ? '📅 Ngày sản xuất: $displayDate - $itemCount'
            : '📅 Ngày sản xuất: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();
    final isSelected = selectedPlanningIds.contains(orderId);

    final sortPlanningCell = row.getCells().firstWhere(
      (cell) => cell.columnName == 'index',
      orElse: () => DataGridCell<int>(columnName: 'index', value: 0),
    );

    final statusCell = row.getCells().firstWhere(
      (cell) => cell.columnName == 'status',
      orElse: () => DataGridCell<String>(columnName: 'status', value: ''),
    );

    final sortPlanning = sortPlanningCell.value as int;
    final status = statusCell.value.toString();

    final isProducing = orderId == producingOrderId;

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    } else if (isProducing) {
      backgroundColor = Colors.orange.withOpacity(0.4);
    } else if (sortPlanning > 0 && status == "lackQty") {
      backgroundColor = Colors.red.withOpacity(0.4); // Thiếu số lượng
    } else if (sortPlanning > 0 && status == "complete") {
      backgroundColor = Colors.green.withOpacity(0.3); // Đã hoàn thành
    } else if (sortPlanning == 0) {
      backgroundColor = Colors.amberAccent.withOpacity(0.3); // Chưa sắp xếp
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                dataCell.value?.toString() ?? "",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
    );
  }
}
