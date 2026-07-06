import "package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_paper_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class InspectionPaperDataSource extends DataGridSource {
  List<QcInspectionPaperModel> inspectionPapers = [];
  List<int> selectedPaperIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatterDay = DateFormat("dd/MM/yyyy");
  final formatterDayTime = DateFormat("dd/MM/yyyy HH:mm:ss");

  InspectionPaperDataSource({
    required this.inspectionPapers,
    required this.selectedPaperIds,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: "timeInspecDate", sortGroupRows: false));
  }

  List<DataGridCell> buildInspectionPaperCells(QcInspectionPaperModel inspecPaper, int index) {
    final paper = inspecPaper.paper!;
    final order = paper.order;
    final customer = order?.customer;

    return [
      DataGridCell<int>(columnName: "index", value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: paper.orderId),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),

      DataGridCell<String>(columnName: "structure", value: paper.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: order?.flute ?? ""),
      DataGridCell<double>(columnName: "sizePaper", value: paper.sizePaperPLaning),
      DataGridCell<String>(
        columnName: "lengthPaper",
        value: paper.lengthPaperPlanning > 0 ? "${paper.lengthPaperPlanning}" : "0",
      ),
      DataGridCell<int>(columnName: "runningPlan", value: paper.runningPlan),

      DataGridCell<String>(
        columnName: "timeInspection",
        value: formatterDayTime.format(inspecPaper.timeInspection),
      ),
      DataGridCell<int>(columnName: "numberPallet", value: inspecPaper.numberPallet),
      DataGridCell<int>(columnName: "machineSpeed", value: inspecPaper.machineSpeed),
      DataGridCell<double>(columnName: "moisture", value: inspecPaper.moisture),
      DataGridCell<double>(columnName: "steamPressure", value: inspecPaper.steamPressure),
      DataGridCell<double>(columnName: "preheaterTemp", value: inspecPaper.preheaterTemp),
      DataGridCell<double>(columnName: "fctValue", value: inspecPaper.fctValue),
      DataGridCell<double>(columnName: "patValue", value: inspecPaper.patValue),

      //checklist
      ...buildChecklistCells(inspecPaper),
      DataGridCell<String>(columnName: "checkedBy", value: inspecPaper.checkedBy),

      //hidden fields
      DataGridCell<int>(columnName: "inspecPaperId", value: inspecPaper.inspecPaperId),
      DataGridCell<String>(
        columnName: "timeInspecDate",
        value: formatterDay.format(inspecPaper.timeInspection),
      ),
    ];
  }

  List<DataGridCell> buildChecklistCells(QcInspectionPaperModel inspecPaper) {
    final checklist = inspecPaper.checkList;

    return [
      DataGridCell<bool>(columnName: "blishter", value: checklist["BLISHTER"] ?? false),
      DataGridCell<bool>(columnName: "wrongWidth", value: checklist["WRONG_WIDTH"] ?? false),
      DataGridCell<bool>(columnName: "wrongLength", value: checklist["WRONG_LENGTH"] ?? false),
      DataGridCell<bool>(
        columnName: "wrongScoringSpec",
        value: checklist["WRONG_SCORING_SPEC"] ?? false,
      ),
      DataGridCell<bool>(columnName: "poorScoring", value: checklist["POOR_SCORING"] ?? false),
      DataGridCell<bool>(columnName: "drityLiner", value: checklist["DIRTY_LINER"] ?? false),
      DataGridCell<bool>(columnName: "losseLiner", value: checklist["LOSSE_LINER"] ?? false),
      DataGridCell<bool>(columnName: "earDefect", value: checklist["EAR_DEFECT"] ?? false),
      DataGridCell<bool>(columnName: "skewedFlute", value: checklist["SKEWED_FLUTE"] ?? false),
      DataGridCell<bool>(columnName: "warppage", value: checklist["WARPPAGE"] ?? false),
      DataGridCell<bool>(
        columnName: "wrongStructure",
        value: checklist["WRONG_STRUCTURE"] ?? false,
      ),
      DataGridCell<bool>(columnName: "waveHeight", value: checklist["WAVEHEIGHT"] ?? false),
      DataGridCell<bool>(columnName: "poorTrim", value: checklist["POOR_TRIM"] ?? false),
      DataGridCell<bool>(columnName: "misalignment", value: checklist["MISALIGNMENT"] ?? false),
      DataGridCell<bool>(columnName: "glueDripping", value: checklist["GLUE_DRIPPING"] ?? false),
      DataGridCell<bool>(columnName: "trimScrap", value: checklist["TRIM_SCRAP"] ?? false),
      DataGridCell<bool>(columnName: "poorBundling", value: checklist["POOR_BUNDLING"] ?? false),
      DataGridCell<bool>(columnName: "totalWidthErr", value: checklist["TOTAL_WIDTH_ERR"] ?? false),
      DataGridCell<bool>(
        columnName: "wrongProductInfo",
        value: checklist["WRONG_PRODUCT_INFO"] ?? false,
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => reportDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    reportDataGridRows =
        inspectionPapers.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildInspectionPaperCells(entry.value, globalIndex));
        }).toList();

    notifyListeners();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = [
      "blishter",
      "wrongWidth",
      "wrongLength",
      "wrongScoringSpec",
      "poorScoring",
      "drityLiner",
      "losseLiner",
      "earDefect",
      "skewedFlute",
      "warppage",
      "wrongStructure",
      "waveHeight",
      "poorTrim",
      "misalignment",
      "glueDripping",
      "trimScrap",
      "poorBundling",
      "totalWidthErr",
      "wrongProductInfo",
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
    final inspecPaperId =
        row.getCells().firstWhere((cell) => cell.columnName == "inspecPaperId").value;
    final isSelected = selectedPaperIds.contains(inspecPaperId);

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
