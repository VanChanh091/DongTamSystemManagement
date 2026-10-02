import "package:dongtam/data/models/qualityControl/qcInspection/qc_inspection_paper_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class InspectionPaperDataSource extends DataGridSource {
  final BuildContext context;
  List<QcInspectionPaperModel> inspectionPapers = [];
  int? selectedPaperIds;
  int currentPage;
  int pageSize;

  late List<DataGridRow> reportDataGridRows;
  final formatterDay = DateFormat("dd/MM/yyyy");
  final formatterDateTime = DateFormat("dd/MM/yyyy HH:mm:ss");

  InspectionPaperDataSource({
    required this.context,
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
      DataGridCell<bool>(columnName: "result", value: inspecPaper.result),

      //checking
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

      //info order
      DataGridCell<String>(columnName: "orderId", value: paper.orderId),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(columnName: "productName", value: order?.product?.productName ?? ""),
      DataGridCell<bool>(columnName: "isFSC", value: order?.isFSC ?? false),

      DataGridCell<String>(columnName: "structure", value: paper.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: order?.flute ?? ""),

      DataGridCell<double>(columnName: "sizePaper", value: paper.sizePaperPLaning),
      DataGridCell<double>(columnName: "lengthPaper", value: paper.lengthPaperPlanning),
      DataGridCell<int>(columnName: "runningPlan", value: paper.runningPlan),

      DataGridCell<String>(columnName: "note", value: inspecPaper.note),
      DataGridCell<String>(columnName: "imgError", value: inspecPaper.imgError),

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
      DataGridCell<bool?>(columnName: "wrongScoringSpec", value: checklist["WRONG_SCORING_SPEC"]),
      DataGridCell<bool?>(columnName: "poorScoring", value: checklist["POOR_SCORING"]),
      DataGridCell<bool?>(columnName: "drityLiner", value: checklist["DIRTY_LINER"]),
      DataGridCell<bool?>(columnName: "losseLiner", value: checklist["LOSSE_LINER"]),
      DataGridCell<bool?>(columnName: "earDefect", value: checklist["EAR_DEFECT"]),
      DataGridCell<bool?>(columnName: "skewedFlute", value: checklist["SKEWED_FLUTE"]),
      DataGridCell<bool?>(columnName: "warppage", value: checklist["WARPPAGE"]),
      DataGridCell<bool?>(columnName: "wrongStructure", value: checklist["WRONG_STRUCTURE"]),
      DataGridCell<bool?>(columnName: "waveHeight", value: checklist["WAVEHEIGHT"]),
      DataGridCell<bool?>(columnName: "poorTrim", value: checklist["POOR_TRIM"]),
      DataGridCell<bool?>(columnName: "misalignment", value: checklist["MISALIGNMENT"]),
      DataGridCell<bool?>(columnName: "glueDripping", value: checklist["GLUE_DRIPPING"]),
      DataGridCell<bool?>(columnName: "trimScrap", value: checklist["TRIM_SCRAP"]),
      DataGridCell<bool?>(columnName: "poorBundling", value: checklist["POOR_BUNDLING"]),
      DataGridCell<bool?>(columnName: "totalWidthErr", value: checklist["TOTAL_WIDTH_ERR"]),
      DataGridCell<bool?>(columnName: "wrongProductInfo", value: checklist["WRONG_PRODUCT_INFO"]),
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

  Widget _buildImageCell(String imageUrl) {
    final hasImage = imageUrl.isNotEmpty && imageUrl != "Không có ảnh";

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child:
          hasImage
              ? TextButton(
                onPressed: () => _showImageDialog(imageUrl),
                child: const Text(
                  "Xem ảnh",
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              )
              : const Text("Không có ảnh"),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Scaffold(
              backgroundColor: Colors.black54,
              body: Center(
                child: GestureDetector(
                  onTap: () {}, // Ngăn đóng dialog khi bấm trúng ảnh
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 850,
                      height: 850,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, _, _) => Container(
                              width: 300,
                              height: 300,
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Text("Lỗi ảnh", style: TextStyle(color: Colors.black)),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = {
      "result",
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

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return "";
      return value == true ? "" : "❌";
    }

    const checkColumns = ["isFSC"];
    if (checkColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
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
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((dataCell) {
            final cellText = _formatCellValueBool(dataCell);

            // Xử lý cột ảnh
            if (dataCell.columnName == "imgError") {
              return _buildImageCell(dataCell.value?.toString() ?? "");
            }

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else if (cellText == "❌" || cellText == "✅") {
              alignment = Alignment.center;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: cellText, alignment: alignment);
          }).toList(),
    );
  }
}
