// ignore_for_file: deprecated_member_use

import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_paper_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

const Set<String> _boolColumns = {
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
};

class InspectionPaperDataSource extends DataGridSource {
  List<QcInspectionPaperModel> inspectionPapers = [];
  int? selectedPaperIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatterDay = DateFormat("dd/MM/yyyy");
  final formatterDateTime = DateFormat("dd/MM/yyyy HH:mm:ss");

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
      DataGridCell<String>(
        columnName: "timeInspection",
        value: formatterDateTime.format(inspecPaper.timeInspection),
      ),
      DataGridCell<String>(columnName: "checkedBy", value: inspecPaper.checkedBy),

      DataGridCell<String>(columnName: "orderId", value: paper.orderId),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),
      DataGridCell<bool>(columnName: "isFSC", value: order?.isFSC ?? false),

      DataGridCell<String>(columnName: "structure", value: paper.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: order?.flute ?? ""),

      DataGridCell<double>(columnName: "sizePaper", value: paper.sizePaperPLaning),
      DataGridCell<double>(columnName: "lengthPaper", value: paper.lengthPaperPlanning),
      DataGridCell<int>(columnName: "runningPlan", value: paper.runningPlan),

      DataGridCell<double>(columnName: "moisture", value: inspecPaper.moisture),
      DataGridCell<double>(columnName: "steamPressure", value: inspecPaper.steamPressure),
      DataGridCell<double>(columnName: "preheaterTemp", value: inspecPaper.preheaterTemp),
      DataGridCell<double>(columnName: "fctValue", value: inspecPaper.fctValue),
      DataGridCell<String>(
        columnName: "patValue",
        value: inspecPaper.patValue == 1 ? "Đạt" : "Không đạt",
      ),

      //checklist
      ...buildChecklistCells(inspecPaper),

      DataGridCell<String>(columnName: "note", value: inspecPaper.note),

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
      DataGridCell<bool?>(columnName: "blishter", value: checklist["BLISHTER"]),
      DataGridCell<bool?>(columnName: "wrongWidth", value: checklist["WRONG_WIDTH"]),
      DataGridCell<bool?>(columnName: "wrongLength", value: checklist["WRONG_LENGTH"]),
      DataGridCell<bool?>(
        columnName: "wrongScoringSpec",
        value: checklist["WRONG_SCORING_SPEC"],
      ),
      DataGridCell<bool?>(columnName: "poorScoring", value: checklist["POOR_SCORING"]),
      DataGridCell<bool?>(columnName: "drityLiner", value: checklist["DIRTY_LINER"]),
      DataGridCell<bool?>(columnName: "losseLiner", value: checklist["LOSSE_LINER"]),
      DataGridCell<bool?>(columnName: "earDefect", value: checklist["EAR_DEFECT"]),
      DataGridCell<bool?>(columnName: "skewedFlute", value: checklist["SKEWED_FLUTE"]),
      DataGridCell<bool?>(columnName: "warppage", value: checklist["WARPPAGE"]),
      DataGridCell<bool?>(
        columnName: "wrongStructure",
        value: checklist["WRONG_STRUCTURE"],
      ),
      DataGridCell<bool?>(columnName: "waveHeight", value: checklist["WAVEHEIGHT"]),
      DataGridCell<bool?>(columnName: "poorTrim", value: checklist["POOR_TRIM"]),
      DataGridCell<bool?>(columnName: "misalignment", value: checklist["MISALIGNMENT"]),
      DataGridCell<bool?>(columnName: "glueDripping", value: checklist["GLUE_DRIPPING"]),
      DataGridCell<bool?>(columnName: "trimScrap", value: checklist["TRIM_SCRAP"]),
      DataGridCell<bool?>(columnName: "poorBundling", value: checklist["POOR_BUNDLING"]),
      DataGridCell<bool?>(columnName: "totalWidthErr", value: checklist["TOTAL_WIDTH_ERR"]),
      DataGridCell<bool?>(
        columnName: "wrongProductInfo",
        value: checklist["WRONG_PRODUCT_INFO"],
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
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final value = dataCell.value;
            final colName = dataCell.columnName;

            final String displayValue;
            final Alignment alignment;

            if (value is num) {
              alignment = Alignment.centerRight;
              displayValue = value == 0 ? "-" : OrderModel.formatCurrency(value.toDouble());
            } else if (_boolColumns.contains(colName)) {
              alignment = Alignment.center;
              displayValue = value == false ? "❌" : "";
            } else if (colName == "isFSC") {
              alignment = Alignment.center;
              displayValue = value == true ? "✅" : "";
            } else {
              alignment = Alignment.centerLeft;
              displayValue = value?.toString() ?? "";
            }

            return formatDataTable(label: displayValue, alignment: alignment);
          }).toList(),
    );
  }
}
