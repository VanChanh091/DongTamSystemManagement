import 'package:dongtam/data/controller/unsaved_change_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachineBoxDatasource extends DataGridSource {
  List<PlanningBox> planning = [];
  List<String> selectedPlanningIds = [];
  UnsavedChangeController? unsavedChange;
  String machine;
  bool showGroup;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");
  bool hasSortedInitially = false;

  MachineBoxDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
    required this.machine,
    this.unsavedChange,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(ColumnGroup(name: 'dayStartProduction', sortGroupRows: false));
    }
  }

  List<DataGridCell> buildPlanningCells(PlanningBox planning, String machine) {
    final boxMachineTime = planning.getBoxMachineTimeByMachine(machine);

    return [
      //14 items
      DataGridCell<String>(columnName: "orderId", value: planning.orderId),
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
        value: boxMachineTime?.dayStart != null ? formatter.format(boxMachineTime!.dayStart!) : '',
      ),
      DataGridCell<String>(
        columnName: "dayCompletedProd",
        value:
            boxMachineTime?.dayCompleted != null
                ? formatterDayCompleted.format(boxMachineTime!.dayCompleted!)
                : '',
      ),
      DataGridCell<String>(columnName: "structure", value: planning.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: planning.order?.flute ?? ""),
      DataGridCell<String>(columnName: "QC_box", value: planning.order?.QC_box ?? ""),
      DataGridCell<String>(columnName: "length", value: '${planning.length} cm'),
      DataGridCell<String>(columnName: "size", value: '${planning.size} cm'),
      DataGridCell<int>(columnName: 'child', value: planning.order?.numberChild ?? 0),
      DataGridCell<int>(columnName: "quantityOrd", value: planning.order?.quantityCustomer ?? 0),
      DataGridCell<int>(columnName: "qtyPaper", value: planning.qtyPaper),
      DataGridCell<int>(columnName: "needProd", value: boxMachineTime?.runningPlan ?? 0),
      DataGridCell<String>(
        columnName: "timeRunnings",
        value:
            boxMachineTime?.timeRunning != null
                ? PlanningBox.formatTimeOfDay(timeOfDay: boxMachineTime!.timeRunning!)
                : '',
      ),
    ];
  }

  List<DataGridCell> buildBoxCells(PlanningBox planning, String machine) {
    final boxMachineTime = planning.getBoxMachineTimeByMachine(machine);

    /// Hàm dùng chung lấy qtyProduced
    int? getQtyProduced(String machineName, {bool zeroIfMissing = false}) {
      // check boxTimes theo machine
      final bt = planning.getBoxMachineTimeByMachine(machineName);
      if (bt != null && (bt.qtyProduced ?? 0) > 0) {
        return bt.qtyProduced;
      }

      // check allBoxTimes
      final all = planning.getAllBoxMachineTime(machineName);
      if (all != null && (all.qtyProduced ?? 0) > 0) {
        return all.qtyProduced;
      }

      return zeroIfMissing ? 0 : null;
    }

    return [
      DataGridCell<int>(columnName: "qtyPrinted", value: getQtyProduced("Máy In")),
      DataGridCell<int>(columnName: "qtyCanLan", value: getQtyProduced("Máy Cấn Lằn")),
      DataGridCell<int>(columnName: "qtyCanMang", value: getQtyProduced("Máy Cán Màng")),
      DataGridCell<int>(columnName: "qtyXa", value: getQtyProduced("Máy Xả")),
      DataGridCell<int>(columnName: "qtyCatKhe", value: getQtyProduced("Máy Cắt Khe")),
      DataGridCell<int>(columnName: "qtyBe", value: getQtyProduced("Máy Bế")),
      DataGridCell<int>(columnName: "qtyDan", value: getQtyProduced("Máy Dán")),
      DataGridCell<int>(columnName: "qtyDongGhim", value: getQtyProduced("Máy Đóng Ghim")),

      ...buildChildBoxCells(planning, machine),

      DataGridCell<String>(
        columnName: "dmWasteLoss",
        value: (boxMachineTime?.wasteBox ?? 0) > 0 ? '${boxMachineTime!.wasteBox} Cái' : "0",
      ),
      DataGridCell<String>(
        columnName: "wasteActually",
        value: (boxMachineTime?.rpWasteLoss ?? 0) > 0 ? '${boxMachineTime!.rpWasteLoss} Cái' : "0",
      ),
      DataGridCell<String>(
        columnName: "shiftManager",
        value: boxMachineTime?.shiftManagement ?? "",
      ),

      // hidden
      DataGridCell<String>(columnName: "status", value: boxMachineTime?.status),
      DataGridCell<int>(columnName: "index", value: boxMachineTime?.sortPlanning ?? 0),
      DataGridCell<int>(columnName: "planningBoxId", value: planning.planningBoxId),
    ];
  }

  List<DataGridCell> buildChildBoxCells(PlanningBox planning, String machine) {
    return [
      DataGridCell<int>(
        columnName: "inMatTruoc",
        value: machine == "Máy In" ? (planning.order!.box!.inMatTruoc ?? 0) : null,
      ),
      DataGridCell<int>(
        columnName: "inMatSau",
        value: machine == "Máy In" ? planning.order!.box!.inMatSau ?? 0 : null,
      ),
      DataGridCell<bool>(
        columnName: "dan_1_Manh",
        value: machine == "Máy Dán" ? planning.order!.box!.dan_1_Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dan_2_Manh",
        value: machine == "Máy Dán" ? planning.order!.box!.dan_2_Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dongGhim1Manh",
        value: machine == "Máy Đóng Ghim" ? planning.order!.box!.dongGhim1Manh : false,
      ),
      DataGridCell<bool>(
        columnName: "dongGhim2Manh",
        value: machine == "Máy Đóng Ghim" ? planning.order!.box!.dongGhim2Manh : false,
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  void buildDataGridRows() {
    planningDataGridRows =
        planning
            .map<DataGridRow>(
              (planning) => DataGridRow(
                cells: [
                  ...buildPlanningCells(planning, machine),
                  ...buildBoxCells(planning, machine),
                ],
              ),
            )
            .toList();

    notifyListeners();
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    unsavedChange?.setUnsavedChanges(value: true);

    List<PlanningBox> selectedItems =
        planning.where((p) => idsToMove.contains(p.planningBoxId.toString())).toList();

    selectedItems.sort((a, b) => planning.indexOf(a).compareTo(planning.indexOf(b)));

    int minCurrentIndex = planning.length;
    for (var item in selectedItems) {
      int index = planning.indexOf(item);
      if (index != -1 && index < minCurrentIndex) {
        minCurrentIndex = index;
      }
    }

    if (minCurrentIndex == 0) return;

    List<PlanningBox> itemsToRemove = [...selectedItems];
    itemsToRemove.sort((a, b) => planning.indexOf(b).compareTo(planning.indexOf(a)));
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

    unsavedChange?.setUnsavedChanges(value: true);

    List<PlanningBox> selectedItems =
        planning.where((p) => idsToMove.contains(p.planningBoxId.toString())).toList();

    selectedItems.sort((a, b) => planning.indexOf(a).compareTo(planning.indexOf(b)));

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
    itemsToRemove.sort((a, b) => planning.indexOf(b).compareTo(planning.indexOf(a)));
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

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ['dan_1_Manh', 'dan_2_Manh', 'dongGhim1Manh', 'dongGhim2Manh'];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
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
    final planningBoxId =
        row.getCells().firstWhere((cell) => cell.columnName == 'planningBoxId').value.toString();

    final isSelected = selectedPlanningIds.contains(planningBoxId);

    // Lấy giá trị các cột cần check
    final sortPlanning = getCellValue<int>(row, 'index', 0);
    final status = getCellValue<String>(row, 'status', "");
    final dmWasteLoss = getCellValue<String>(row, 'dmWasteLoss', "0");
    final wasteActually = getCellValue<String>(row, 'wasteActually', "0");
    final needProd = getCellValue<int>(row, 'needProd', 0);

    final Map<String, String> machineColumnMap = {
      'qtyPrinted': "Máy In",
      'qtyCanLan': "Máy Cấn Lằn",
      'qtyCanMang': "Máy Cán Màng",
      'qtyXa': "Máy Xả",
      'qtyCatKhe': "Máy Cắt Khe",
      'qtyBe': "Máy Bế",
      'qtyDan': "Máy Dán",
      'qtyDongGhim': "Máy Đóng Ghim",
    };

    //Chuyển từ "10 cái" -> 10
    final totalDmWasteLoss = double.tryParse(dmWasteLoss.replaceAll(' Cái', '')) ?? 0;
    final totalWasteActually = double.tryParse(wasteActually.replaceAll(' Cái', '')) ?? 0;

    // Màu nền cho cả hàng
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
      color: rowColor, // chỉ set khi tô cả hàng
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
            //tô màu cho waste loss
            if (dataCell.columnName == 'wasteActually' && totalWasteActually > totalDmWasteLoss) {
              cellColor = Colors.red.withValues(alpha: 0.5);
            }

            // Kiểm tra cột máy dựa vào map
            final machineColumnName = machineColumnMap[dataCell.columnName];

            if (machineColumnName != null && machineColumnName == machine && status != "complete") {
              final qty = (dataCell.value is int) ? dataCell.value as int : 0;
              if (qty < needProd) {
                cellColor = Colors.red.withValues(alpha: 0.5);
              }
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
