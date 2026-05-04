import 'package:dongtam/data/controller/user_controller.dart';
import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/utils/helper/build_color_row.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SyntheticBoxDetail extends DataGridSource {
  List<PlanningBox> boxes;
  int? selectedBoxId;

  late List<DataGridRow> orderDataGridRows;

  final userController = Get.find<UserController>();

  SyntheticBoxDetail({required this.boxes, this.selectedBoxId}) {
    buildDataCell();
  }

  List<DataGridCell> buildOrderCells(PlanningBox box) {
    /// Hàm dùng chung lấy qtyProduced
    int? getQtyProduced(String machineName, {bool zeroIfMissing = false}) {
      // check boxTimes theo machine
      final bt = box.getBoxMachineTimeByMachine(machineName);
      if (bt != null && (bt.qtyProduced ?? 0) > 0) {
        return bt.qtyProduced;
      }

      // check allBoxTimes
      final all = box.getAllBoxMachineTime(machineName);
      if (all != null && (all.qtyProduced ?? 0) > 0) {
        return all.qtyProduced;
      }

      return zeroIfMissing ? 0 : null;
    }

    return [
      DataGridCell<int>(columnName: 'qtyPrinted', value: getQtyProduced("Máy In")),
      DataGridCell<int>(columnName: 'qtyCanLan', value: getQtyProduced("Máy Cắt Lăn")),
      DataGridCell<int>(columnName: 'qtyCanMang', value: getQtyProduced("Máy Cắt Mang")),
      DataGridCell<int>(columnName: 'qtyXa', value: getQtyProduced("Máy Xà")),
      DataGridCell<int>(columnName: 'qtyCatKhe', value: getQtyProduced("Máy Cắt Khe")),
      DataGridCell<int>(columnName: 'qtyBe', value: getQtyProduced("Máy Bé")),
      DataGridCell<int>(columnName: 'qtyDan', value: getQtyProduced("Máy Dán")),
      DataGridCell<int>(columnName: 'qtyDongGhim', value: getQtyProduced("Máy Đóng Ghim")),

      //hidden
      DataGridCell<int>(columnName: 'planningBoxId', value: box.planningBoxId),
    ];
  }

  @override
  List<DataGridRow> get rows => orderDataGridRows;

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ["isBox"];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    return value?.toString() ?? '';
  }

  void buildDataCell() {
    orderDataGridRows =
        boxes.map<DataGridRow>((box) {
          return DataGridRow(cells: buildOrderCells(box));
        }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final planningBoxId = getCellValue<int>(row, 'planningBoxId', 0);

    //get value cell
    final statusCell = getCellValue<String>(row, 'status', "");
    final status = statusCell.toString().toLowerCase();

    // Chọn màu nền theo status
    Color backgroundColor;
    if (selectedBoxId == planningBoxId) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      switch (status) {
        case 'từ chối':
          backgroundColor = Colors.red.withValues(alpha: 0.4);
          break;
        case 'đã lên kế hoạch':
          backgroundColor = Colors.white;
          break;
        default:
          backgroundColor = Colors.transparent;
      }
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
