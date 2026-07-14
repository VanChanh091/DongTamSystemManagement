// ignore_for_file: deprecated_member_use

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
  List<PlanningPaperModel> planning = [];
  List<String> selectedPlanningIds = [];
  UnsavedChangeController? unsavedChange;
  bool showGroup;
  String page;
  Function(PlanningPaperModel)? onRowTap;

  Map<String, int> orderIdCounts = {};

  late List<DataGridRow> planningDataGridRows;
  late List<String> visibleColumns;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  MachinePaperDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    required this.page,
    this.unsavedChange,
    this.onRowTap,
  }) {
    _calculateOrderIdCounts();
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(ColumnGroup(name: 'dayStartProduction', sortGroupRows: false));
    }
  }

  // create list cell for planning
  List<DataGridCell> buildPlanningInfoCells(PlanningPaperModel planning) {
    DataGridCell<String> buildCurrencyCell(String columnName, num value) {
      return DataGridCell<String>(columnName: columnName, value: (value) > 0 ? '$value' : "0");
    }

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

      DataGridCell<String>(
        columnName: 'customerName',
        value: planning.order?.customer?.customerName ?? '',
      ),
      DataGridCell<String>(columnName: 'structure', value: planning.formatterStructureOrder),
      DataGridCell<String>(columnName: 'flute', value: planning.order?.flute ?? ''),
      DataGridCell<String>(columnName: 'khoCapGiay', value: '${planning.ghepKho} cm'),

      buildCurrencyCell('size', planning.sizePaperPLaning),
      buildCurrencyCell('length', planning.lengthPaperPlanning),

      DataGridCell<String>(columnName: 'note', value: planning.note ?? ""),
      DataGridCell<String>(columnName: 'qcBox', value: planning.order?.QC_box ?? ""),
      DataGridCell<String>(columnName: 'canLan', value: planning.order?.canLan ?? ''),
      DataGridCell<String>(columnName: 'daoXa', value: planning.order?.daoXa ?? ''),
      DataGridCell<int>(columnName: 'child', value: planning.numberChild),
      DataGridCell<String>(
        columnName: "instructSpecial",
        value: planning.order?.instructSpecial ?? '',
      ),
      DataGridCell<bool>(columnName: 'chongTham', value: planning.order!.chongTham),
      DataGridCell<bool>(columnName: 'haveMadeBox', value: planning.order!.isBox),

      if (page == 'planning') ...[
        DataGridCell<int>(
          columnName: 'quantityOrd',
          value: planning.order?.quantityManufacture ?? 0,
        ),
      ],
      DataGridCell<int>(columnName: "qtyProduced", value: planning.qtyProduced),
      DataGridCell<int>(columnName: "runningPlanProd", value: planning.remainRunningPlan),
      DataGridCell<String>(columnName: "dvt", value: planning.order?.dvt),

      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            planning.timeRunning != null
                ? PlanningPaperModel.formatTimeOfDay(timeOfDay: planning.timeRunning!)
                : '',
      ),
      if (page == "planning") ...[
        DataGridCell<String>(
          columnName: 'totalPrice',
          value:
              (planning.totalPrice ?? 0) > 0
                  ? OrderModel.formatCurrency(planning.totalPrice!)
                  : "0",
        ),
      ],

      //waste norm
      ...buildWasteNormCell(planning),

      //status request
      DataGridCell<String>(columnName: "statusRequest", value: planning.statusRequest),
      if (page == "production") ...[DataGridCell<String>(columnName: "action", value: "Hành Động")],

      // hidden technical fields
      DataGridCell<String>(columnName: "status", value: planning.status),
      DataGridCell<int>(columnName: "index", value: planning.sortPlanning ?? 0),
      DataGridCell<int>(columnName: 'planningId', value: planning.planningId),
      DataGridCell<String>(columnName: 'statusCheck', value: planning.statusCheck ?? ""),
    ];
  }

  List<DataGridCell> buildWasteNormCell(PlanningPaperModel planning) {
    DataGridCell<String> buildWasteCell({required String columnName, required double value}) {
      return DataGridCell<String>(columnName: columnName, value: value != 0 ? '$value' : '0');
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

      DataGridCell<String>(columnName: 'shiftProduct', value: planning.shiftProduction),
      if (page == "planning") ...[
        DataGridCell<String>(columnName: 'shiftManager', value: planning.shiftManagement),
      ],

      DataGridCell<String?>(
        columnName: "dayStartProduction",
        value: planning.dayStart != null ? formatter.format(planning.dayStart!) : null,
      ),

      if (page == 'planning') ...[
        DataGridCell<String?>(
          columnName: "dayCompletedProd",
          value:
              planning.dayCompleted != null
                  ? formatterDayCompleted.format(planning.dayCompleted!)
                  : null,
        ),
      ],
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>((planning) => DataGridRow(cells: buildPlanningInfoCells(planning)))
            .toList();

    notifyListeners();
  }

  void _calculateOrderIdCounts() {
    orderIdCounts.clear();
    for (var p in planning) {
      final id = p.orderId;
      orderIdCounts[id] = (orderIdCounts[id] ?? 0) + 1;
    }
  }

  int extractFlute(String loaiSong) {
    //5BC => 5
    final match = RegExp(r'^\d+').firstMatch(loaiSong);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    PlanningListHelper.moveRows<PlanningPaperModel>(
      list: planning,
      idsToMove: idsToMove,
      getId: (p) => p.planningId.toString(),
      moveUp: true,
      onUpdate: buildDataGridRows,
      unsavedChangeController: unsavedChange,
    );
    notifyListeners();
  }

  // Di chuyển hàng xuống
  void moveRowDown(List<String> idsToMove) {
    PlanningListHelper.moveRows<PlanningPaperModel>(
      list: planning,
      idsToMove: idsToMove,
      getId: (item) => item.planningId.toString(),
      moveUp: false,
      unsavedChangeController: unsavedChange,
      onUpdate: buildDataGridRows,
    );
    notifyListeners();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["chongTham", "haveMadeBox"];

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

  Widget? buildCellLeading(
    DataGridCell dataCell,
    bool? isKhoTransition,
    Color? transitionColor,
    bool isDuplicateOrder,
  ) {
    // check ghepKho
    if (dataCell.columnName == 'khoCapGiay' && isKhoTransition == true) {
      return Icon(Icons.warning_amber_rounded, size: 16, color: transitionColor);
    }

    // check orderId
    if (dataCell.columnName == 'orderId' && isDuplicateOrder) {
      return const Icon(Icons.copy_rounded, size: 14, color: Colors.redAccent);
    }

    return null;
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r'^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$', caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = '';
    String itemCount = '';
    String totalPriceStr = '';

    if (match != null) {
      displayDate = match.group(1) ?? '';
      final count = match.group(2) ?? '0';
      itemCount = '$count đơn hàng';

      if (page == 'planning' && displayDate.isNotEmpty) {
        double totalGroupPrice = planning
            .where((p) => p.dayStart != null && formatter.format(p.dayStart!) == displayDate)
            .fold(0, (sum, p) => sum + (p.totalPrice ?? 0));

        if (totalGroupPrice > 0) {
          totalPriceStr = ' – Tổng: ${OrderModel.formatCurrency(totalGroupPrice)} VNĐ';
        }
      }
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty
            ? '📅 Ngày sản xuất: $displayDate – $itemCount$totalPriceStr'
            : '📅 Ngày sản xuất: Không xác định',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // ===== Index row =====
    final int rowIndex = planningDataGridRows.indexOf(row);
    final currentPlanning = planning[rowIndex];

    final String? currentKho = getKhoAtRow(rowIndex);
    final String? prevKho = getKhoAtRow(rowIndex - 1);

    // print("Row $rowIndex: currentKho = $currentKho, prevKho = $prevKho");

    // ===== chuyển khổ =====
    final bool isKhoTransition =
        rowIndex > 0 && currentKho != null && prevKho != null && currentKho != prevKho;

    // ===== check trùng orderId =====
    final String currentOrderId =
        row.getCells().firstWhere((c) => c.columnName == 'orderId').value.toString();
    final bool isDuplicateOrder = (orderIdCounts[currentOrderId] ?? 0) > 1;

    // ===== select and row color =====
    final planningId =
        row.getCells().firstWhere((c) => c.columnName == 'planningId').value.toString();
    final isSelected = selectedPlanningIds.contains(planningId);

    final sortPlanning = getCellValue<int>(row, 'index', 0);
    final runningPlan = getCellValue<int>(row, 'runningPlanProd', 0);
    final qtyProduced = getCellValue<int>(row, 'qtyProduced', 0);
    final totalLoss = getCellValue<String>(row, 'totalLoss', "0");
    final qtyWastes = getCellValue<String>(row, 'qtyWastes', "0");

    //status
    final status = getCellValue<String>(row, 'status', "");
    final statusCheck = getCellValue<String>(row, 'statusCheck', "");

    final totalWasteLossVal = double.tryParse(totalLoss.replaceAll(' kg', '')) ?? 0;
    final qtyWastesVal = double.tryParse(qtyWastes.replaceAll(' kg', '')) ?? 0;

    Color? rowColor;
    if (isSelected) {
      rowColor = Colors.blue.withValues(alpha: 0.3);
    } else if (sortPlanning > 0 && status == "requested") {
      rowColor = Colors.teal.withValues(alpha: 0.4);
    } else if (sortPlanning > 0 && statusCheck == "failed") {
      rowColor = Colors.red.withValues(alpha: 0.4);
    } else if (sortPlanning > 0 && statusCheck == "fixed") {
      rowColor = Colors.green.withValues(alpha: 0.3);
    } else if (sortPlanning > 0 && status == "producing") {
      rowColor = Colors.orange.withValues(alpha: 0.4);
    } else if (sortPlanning == 0) {
      rowColor = Colors.amberAccent.withValues(alpha: 0.3);
    }

    // ===== color warning change ghepKho =====
    final Color? transitionColor = isKhoTransition ? Colors.orange : null;

    // ===== Build cells =====
    final widgets =
        row.getCells().asMap().entries.map<Widget>((entry) {
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

          TextStyle? customTextStyle;
          if (page == 'planning' && dataCell.columnName == 'dateShipping') {
            final DateTime? shipDate = currentPlanning.order?.dateRequestShipping;
            if (shipDate != null) {
              final now = DateTime.now();

              // Reset về 0h 0p 0s để so sánh ngày
              final today = DateTime(now.year, now.month, now.day);
              final compareDate = DateTime(shipDate.year, shipDate.month, shipDate.day);

              if (today.isAfter(compareDate)) {
                customTextStyle = TextStyle(
                  color: Colors.redAccent.shade400,
                  fontWeight: FontWeight.bold,
                );
              } else if (today.isAtSameMomentAs(compareDate)) {
                customTextStyle = TextStyle(
                  color: Colors.orangeAccent.shade400,
                  fontWeight: FontWeight.bold,
                );
              }
            }
          }

          Color cellColor = Colors.transparent;
          if (dataCell.columnName == "qtyProduced" && qtyProduced < runningPlan) {
            cellColor = Colors.red.withValues(alpha: 0.5);
          } else if (dataCell.columnName == "qtyWastes" && qtyWastesVal > totalWasteLossVal) {
            cellColor = Colors.red.withValues(alpha: 0.5);
          }

          if (dataCell.columnName == 'action') {
            return IconButton(
              icon: const Icon(Icons.fact_check, color: Colors.blueAccent, size: 20),
              onPressed: () {
                onRowTap?.call(currentPlanning); //click để mở dialog
              },
            );
          }

          return formatDataTable(
            label: cellText,
            alignment: alignment,
            cellColor: cellColor,
            textStyle: customTextStyle,
            leading: buildCellLeading(dataCell, isKhoTransition, transitionColor, isDuplicateOrder),
          );
        }).toList();

    return DataGridRowAdapter(color: rowColor, cells: widgets);
  }
}
