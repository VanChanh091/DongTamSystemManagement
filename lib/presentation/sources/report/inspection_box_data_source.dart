// ignore_for_file: deprecated_member_use

import "package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_box_model.dart";
import "package:dongtam/presentation/components/headerTable/report/header_table_inspection_box.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class InspectionBoxDataSource extends DataGridSource {
  List<QcInspectionBoxModel> inspectionBoxes = [];
  List<int> selectedBoxIds;
  String machine;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatter = DateFormat("dd/MM/yyyy");
  final formatterDay = DateFormat("dd/MM/yyyy HH:mm:ss");

  InspectionBoxDataSource({
    required this.inspectionBoxes,
    required this.selectedBoxIds,
    required this.machine,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
  }

  List<DataGridCell> buildInspectionBoxCells(QcInspectionBoxModel inspectionBox, int index) {
    final boxtime = inspectionBox.boxTime;
    final box = boxtime?.planningBox;
    final order = box?.order;

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: box?.orderId ?? ""),
      DataGridCell<String>(columnName: "customerName", value: order?.customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),

      DataGridCell<String>(columnName: "structure", value: box?.formatterStructureOrder ?? ""),
      DataGridCell<double>(columnName: "sizePaper", value: box?.size ?? 0),
      DataGridCell<double>(columnName: "lengthPaper", value: box?.length ?? 0),
      DataGridCell<int>(columnName: "runningPlan", value: boxtime?.runningPlan ?? 0),
      DataGridCell<String>(columnName: "qcBox", value: order?.QC_box ?? ""),

      //checklist
      ...buildChecklistCells(inspectionBox, machine),
      DataGridCell<String>(columnName: "checkedBy", value: inspectionBox.checkedBy),

      //hidden fields
      DataGridCell<int>(columnName: "inspecBoxId", value: inspectionBox.inspecBoxId),
      DataGridCell<String>(
        columnName: "timeInspecDate",
        value: formatterDay.format(inspectionBox.timeInspection),
      ),
    ];
  }

  List<DataGridCell> buildChecklistCells(QcInspectionBoxModel inspectionBox, String machine) {
    final checklist = inspectionBox.checkList;

    return inspectionBoxColumns
        .where((item) => item.containsKey("dataKey") && isColumnVisibleForMachine(item, machine))
        .map(
          (item) => DataGridCell<bool>(
            columnName: item["key"] as String,
            value: checklist[item["dataKey"]] ?? false,
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        inspectionBoxes.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildInspectionBoxCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      "boxDimension",
      "colorCount",
      "colorMatch",
      "colorRegistration",
      "fluteCrushing",
      "glueAdhesion",
      "glueViscosity",
      "imagePosition",
      "jointGap",
      "jointMisalignment",
      "paperSurface",
      "printContent",
      "printSharpness",
      "scoringLine",
      "stitchCount",
      "stitchHolding",
      "stitchPitch",
      "stitchPosition",
      "tabOverlap",
      "trimLineBurr",
    ];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return "";
      return value == true ? "" : "❌";
    }

    return value?.toString() ?? "";
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt ngày và số item, không phân biệt hoa thường
    final regex = RegExp(r"^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$", caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displayDate = "";

    if (match != null) {
      displayDate = match.group(1) ?? "";
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displayDate.isNotEmpty ? "📅 Ngày kiểm: $displayDate" : "📅 Ngày kiểm: Không xác định",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final inspecBoxId = row.getCells().firstWhere((cell) => cell.columnName == "inspecBoxId").value;
    final isSelected = selectedBoxIds.contains(inspecBoxId);

    Color backgroundColor;
    if (isSelected == true) {
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
            } else if (cellText == "❌") {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
