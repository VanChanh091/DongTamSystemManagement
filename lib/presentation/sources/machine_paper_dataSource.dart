import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_paper_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachinePaperDatasource extends DataGridSource {
  List<PlanningPaper> planning = [];
  List<String> selectedPlanningIds = [];
  bool showGroup;
  String? producingOrderId;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  bool hasSortedInitially = false;

  MachinePaperDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    this.producingOrderId,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(
        ColumnGroup(name: 'dayStartProduction', sortGroupRows: false),
      );
    }
  }

  // create list cell for planning
  List<DataGridCell> buildPlanningCells(PlanningPaper planning) {
    return [
      DataGridCell<String>(columnName: 'orderId', value: planning.orderId),
      DataGridCell<int>(columnName: 'planningId', value: planning.planningId),
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
        columnName: "dayStartProduction",
        value:
            planning.dayStart != null
                ? formatter.format(planning.dayStart!)
                : null,
      ),
      DataGridCell<String?>(
        columnName: "dayCompletedProd",
        value:
            planning.dayCompleted != null
                ? formatter.format(planning.dayCompleted!)
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
        columnName: 'QC_box',
        value: planning.order?.QC_box ?? '',
      ),
      DataGridCell<String>(
        columnName: "HD_special",
        value: planning.order?.instructSpecial ?? '',
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
      DataGridCell<int>(
        columnName: 'child',
        value: planning.order?.numberChild ?? 0,
      ),
      DataGridCell<String>(
        columnName: 'khoCapGiay',
        value: '${planning.ghepKho} cm',
      ),
      DataGridCell<int>(
        columnName: 'quantity',
        value: planning.order?.quantityManufacture ?? 0,
      ),
      DataGridCell<int>(
        columnName: "runningPlans",
        value: planning.runningPlan,
      ),
      DataGridCell<int>(columnName: "qtyProduced", value: planning.qtyProduced),
      DataGridCell<String>(
        columnName: 'timeRunnings',
        value:
            planning.timeRunning != null
                ? PlanningPaper.formatTimeOfDay(planning.timeRunning!)
                : '',
      ),
      DataGridCell<String>(
        columnName: 'totalPrice',
        value: '${Order.formatCurrency(planning.order?.totalPrice ?? 0)} VND',
      ),
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
        columnName: 'totalWasteLoss',
        value: planning.totalLoss != 0 ? '${planning.totalLoss} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'qtyWasteNorm',
        value: planning.qtyWasteNorm != 0 ? '${planning.qtyWasteNorm} kg' : "0",
      ),
      DataGridCell<String>(
        columnName: 'shiftProduction',
        value: planning.shiftProduction,
      ),
      DataGridCell<String>(
        columnName: 'shiftManagement',
        value: planning.shiftManagement,
      ),
      DataGridCell<String>(
        columnName: "haveMadeBox",
        value: planning.order?.formatIsBox(planning.hasBox),
      ),
      DataGridCell<String>(columnName: "status", value: planning.status ?? ""),
      DataGridCell<int>(columnName: "index", value: planning.sortPlanning ?? 0),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  int extractFlute(String loaiSong) {
    //5BC => 5
    final match = RegExp(r'^\d+').firstMatch(loaiSong);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>(
              (planning) => DataGridRow(cells: buildPlanningCells(planning)),
            )
            .toList();

    notifyListeners();
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    List<PlanningPaper> selectedItems =
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

    List<PlanningPaper> selectedItems =
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
