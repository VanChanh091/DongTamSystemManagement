import 'package:dongtam/data/models/order/order_model.dart';
import 'package:dongtam/data/models/planning/planning_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class MachineDatasource extends DataGridSource {
  List<Planning> planning = [];
  List<String> selectedPlanningIds = [];
  bool showGroup;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  bool hasSortedInitially = false;

  MachineDatasource({
    required this.planning,
    required this.selectedPlanningIds,
    required this.showGroup,
  }) {
    buildDataGridRows();

    if (showGroup) {
      addColumnGroup(
        ColumnGroup(name: 'dayStartProduction', sortGroupRows: false),
      );
    }
  }

  // create list cell for planning
  List<DataGridCell> buildPlanningCells(Planning planning) {
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
      DataGridCell<String>(
        columnName: 'structure',
        value:
            planning.step == "paper"
                ? planning.formatterStructureOrder
                : "Làm Thùng",
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
      DataGridCell<String>(
        columnName: 'khoCapGiay',
        value: '${planning.ghepKho} cm',
      ),
      DataGridCell<int>(
        columnName: 'quantity',
        value: planning.order?.quantityCustomer ?? 0,
      ),
      DataGridCell<int>(
        columnName: "runningPlanProd",
        value: planning.runningPlan,
      ),
      DataGridCell<String>(
        columnName: 'timeRunningProd',
        value:
            planning.timeRunning != null
                ? Planning.formatTimeOfDay(planning.timeRunning!)
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
    ];
  }

  // create list cell for box
  List<DataGridCell> buildBoxCell(Planning planning) {
    final isBoxStep = planning.step == 'box' && planning.order?.box != null;
    final box = planning.order?.box;

    return [
      DataGridCell<int>(
        columnName: 'inMatTruoc',
        value: isBoxStep ? box!.inMatTruoc ?? 0 : 0,
      ),
      DataGridCell<int>(
        columnName: 'inMatSau',
        value: isBoxStep ? box!.inMatSau ?? 0 : 0,
      ),
      DataGridCell<bool>(
        columnName: 'canMang',
        value: isBoxStep ? box!.canMang ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'xa',
        value: isBoxStep ? box!.Xa ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'catKhe',
        value: isBoxStep ? box!.catKhe ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'be',
        value: isBoxStep ? box!.be ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'dan_1_Manh',
        value: isBoxStep ? box!.dan_1_Manh ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'dan_2_Manh',
        value: isBoxStep ? box!.dan_2_Manh ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhimMotManh',
        value: isBoxStep ? box!.dongGhim1Manh ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'dongGhimHaiManh',
        value: isBoxStep ? box!.dongGhim2Manh ?? false : false,
      ),
      DataGridCell<bool>(
        columnName: 'chongTham',
        value: isBoxStep ? box!.chongTham ?? false : false,
      ),
      DataGridCell<String>(
        columnName: 'dongGoi',
        value: isBoxStep ? box!.dongGoi ?? '' : '',
      ),
      DataGridCell<int>(columnName: 'index', value: planning.sortPlanning ?? 0),
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
              (planning) => DataGridRow(
                cells: [
                  ...buildPlanningCells(planning),
                  ...buildBoxCell(planning),
                ],
              ),
            )
            .toList();

    notifyListeners();
  }

  // Di chuyển hàng lên
  void moveRowUp(List<String> idsToMove) {
    if (idsToMove.isEmpty) return;

    List<Planning> selectedItems =
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

    List<Planning> itemsToRemove = [...selectedItems];
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

    List<Planning> selectedItems =
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

    Planning? elementAfterBlock;
    if (maxCurrentIndex + 1 < planning.length) {
      elementAfterBlock = planning[maxCurrentIndex + 1];
    } else {
      return;
    }

    List<Planning> itemsToRemove = [...selectedItems];
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

  String formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      'canMang',
      'xa',
      'catKhe',
      'be',
      'dan_1_Manh',
      'dan_2_Manh',
      'dongGhimMotManh',
      'dongGhimHaiManh',
      'chongTham',
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? 'Có' : '';
    }

    return value?.toString() ?? '';
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final orderId = row.getCells()[0].value.toString();

    final isSelected = selectedPlanningIds.contains(orderId);

    final sortPlanningCell = row.getCells().firstWhere(
      (cell) => cell.columnName == 'index',
      orElse: () => DataGridCell<int>(columnName: 'index', value: 0),
    );

    final sortPlanning = sortPlanningCell.value as int;

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withOpacity(0.3);
    } else {
      switch (sortPlanning) {
        case 0:
          backgroundColor = Colors.amberAccent.withOpacity(0.4);
          break;
        default:
          backgroundColor = Colors.transparent;
      }
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
                formatCellValueBool(dataCell),
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
