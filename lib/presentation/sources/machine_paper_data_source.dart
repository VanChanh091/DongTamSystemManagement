import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:dongtam/data/models/admin/admin_machine_paper_model.dart';

class MachinePaperDataSource extends DataGridSource {
  List<AdminMachinePaperModel> machinePapers = [];
  List<int> selectedPaperIds = [];

  late List<DataGridRow> machinePaperDataGridRows;

  final TextEditingController editingController = TextEditingController();

  MachinePaperDataSource({required this.machinePapers, required this.selectedPaperIds}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildMachinePaperCells(AdminMachinePaperModel machinePaper) {
    return [
      DataGridCell<num>(columnName: "changeDiffSize", value: machinePaper.timeChangeSize),
      DataGridCell<num>(columnName: "changeSameSize", value: machinePaper.timeChangeSameSize),

      DataGridCell<num>(columnName: "speed2Layer", value: machinePaper.speed2Layer),
      DataGridCell<num>(columnName: "speed3Layer", value: machinePaper.speed3Layer),
      DataGridCell<num>(columnName: "speed4Layer", value: machinePaper.speed4Layer),
      DataGridCell<num>(columnName: "speed5Layer", value: machinePaper.speed5Layer),
      DataGridCell<num>(columnName: "speed6Layer", value: machinePaper.speed6Layer),
      DataGridCell<num>(columnName: "speed7Layer", value: machinePaper.speed7Layer),
      DataGridCell<num>(columnName: "machineRollPaper", value: machinePaper.paperRollSpeed),

      DataGridCell<num>(columnName: "efficiency", value: machinePaper.machinePerformance),
      DataGridCell<String>(columnName: "machineName", value: machinePaper.machineName),
      DataGridCell<String>(columnName: "type", value: machinePaper.type),

      // hidden field
      DataGridCell<int>(columnName: "machineId", value: machinePaper.machineId),
    ];
  }

  @override
  List<DataGridRow> get rows => machinePaperDataGridRows;

  void buildDataGridRows() {
    machinePaperDataGridRows =
        machinePapers.map<DataGridRow>((entry) {
          return DataGridRow(cells: buildMachinePaperCells(entry));
        }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final machineId = row.getCells().firstWhere((cell) => cell.columnName == 'machineId').value;
    final isSelected = selectedPaperIds.contains(machineId);

    final typeCell = row.getCells().firstWhere(
      (cell) => cell.columnName == 'type',
      orElse: () => const DataGridCell(columnName: 'type', value: ''),
    );
    final String machineType = typeCell.value?.toString() ?? "";

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().map<Widget>((dataCell) {
            final dynamic rawValue = dataCell.value;
            String displayValue = rawValue?.toString() ?? "";

            if (rawValue != null) {
              if (dataCell.columnName == "changeDiffSize" ||
                  dataCell.columnName == "changeSameSize") {
                displayValue = '$rawValue Phút';
              } else if (dataCell.columnName.startsWith("speed") ||
                  dataCell.columnName == "machineRollPaper") {
                final num value = rawValue is num ? rawValue : 0;
                displayValue =
                    value > 0 ? (machineType == "M2" ? "$value m/phút" : "$value kg/phút") : "0";
              } else if (dataCell.columnName == "efficiency") {
                displayValue = '$rawValue%';
              }
            }

            Alignment alignment = (rawValue is num) ? Alignment.centerRight : Alignment.centerLeft;

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }

  // --- THÊM LOGIC 1: HIỂN THỊ TEXTFIELD KHI NGƯỜI DÙNG CLICK VÀO Ô ĐỂ SỬA ---
  @override
  Widget? buildEditWidget(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final String columnName = column.columnName;

    // Khóa không cho sửa các cột không cần thiết (như ID hoặc loại máy)
    if (columnName == 'machineId' || columnName == 'machineName' || columnName == 'type') {
      return null;
    }

    // Lấy giá trị gốc hiện tại của Cell đưa vào ô nhập liệu
    final dynamic cellValue =
        dataGridRow.getCells().firstWhere((c) => c.columnName == columnName).value;

    editingController.text = cellValue?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      child: TextField(
        controller: editingController,
        autofocus: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 12.0),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        onSubmitted: (value) {
          submitCell();
        },
      ),
    );
  }

  // --- THÊM LOGIC 2: ĐÓN DỮ LIỆU MỚI VÀ CẬP NHẬT THẲNG VÀO LIST MODEL GỐC ---
  @override
  Future<void> onCellSubmit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final String columnName = column.columnName;
    final validNewValue = editingController.text;

    // Tự lấy oldValue từ ô đang chỉnh sửa trong dataGridRow
    final dynamic oldValue =
        dataGridRow.getCells().firstWhere((c) => c.columnName == columnName).value;

    // Nếu người dùng không thay đổi gì thì bỏ qua không xử lý
    if (validNewValue == oldValue.toString()) return;

    // Xác định vị trí của hàng đang sửa trong danh sách
    final int rowIndex = machinePaperDataGridRows.indexOf(dataGridRow);
    if (rowIndex == -1) return;

    // Lấy trực tiếp Object Model đang nằm trong danh sách ra để gán lại giá trị
    final model = machinePapers[rowIndex];
    dynamic updatedRawValue;

    // Cập nhật giá trị mới dựa theo từng trường dữ liệu cụ thể
    switch (columnName) {
      case 'changeDiffSize':
        model.timeChangeSize = int.tryParse(validNewValue) ?? model.timeChangeSize;
        updatedRawValue = model.timeChangeSize;
        break;
      case 'changeSameSize':
        model.timeChangeSameSize = int.tryParse(validNewValue) ?? model.timeChangeSameSize;
        updatedRawValue = model.timeChangeSameSize;
        break;
      case 'speed2Layer':
        model.speed2Layer = int.tryParse(validNewValue) ?? model.speed2Layer;
        updatedRawValue = model.speed2Layer;
        break;
      case 'speed3Layer':
        model.speed3Layer = int.tryParse(validNewValue) ?? model.speed3Layer;
        updatedRawValue = model.speed3Layer;
        break;
      case 'speed4Layer':
        model.speed4Layer = int.tryParse(validNewValue) ?? model.speed4Layer;
        updatedRawValue = model.speed4Layer;
        break;
      case 'speed5Layer':
        model.speed5Layer = int.tryParse(validNewValue) ?? model.speed5Layer;
        updatedRawValue = model.speed5Layer;
        break;
      case 'speed6Layer':
        model.speed6Layer = int.tryParse(validNewValue) ?? model.speed6Layer;
        updatedRawValue = model.speed6Layer;
        break;
      case 'speed7Layer':
        model.speed7Layer = int.tryParse(validNewValue) ?? model.speed7Layer;
        updatedRawValue = model.speed7Layer;
        break;
      case 'machineRollPaper':
        model.paperRollSpeed = int.tryParse(validNewValue) ?? model.paperRollSpeed;
        updatedRawValue = model.paperRollSpeed;
        break;
      case 'efficiency':
        model.machinePerformance = double.tryParse(validNewValue) ?? model.machinePerformance;
        updatedRawValue = model.machinePerformance;
        break;
    }
    final cellIndex = dataGridRow.getCells().indexWhere((c) => c.columnName == columnName);
    if (cellIndex != -1) {
      dataGridRow.getCells()[cellIndex] = DataGridCell<num>(
        columnName: columnName,
        value: updatedRawValue,
      );
    }

    notifyListeners();
  }
}
