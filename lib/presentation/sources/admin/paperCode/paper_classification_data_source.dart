import "package:dongtam/data/models/admin/paperCode/paper_classification_model.dart";
import "package:dongtam/data/models/order/order_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class PaperClassificationDataSource extends DataGridSource {
  List<PaperClassificationModel> classifications = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> paperClassificationsDataGridRows;

  PaperClassificationDataSource({
    required this.classifications,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: "supplierName", sortGroupRows: false));
  }

  List<DataGridCell> buildPaperClassificationCells(PaperClassificationModel classification) {
    final basisWeight = classification.basisWeight;
    final supplierPaper = classification.supplierPaper;
    final supplier = supplierPaper?.Supplier;
    final paperType = supplierPaper?.PaperType;

    return [
      DataGridCell<String>(columnName: "paperCode", value: classification.paperCode),
      DataGridCell<String>(columnName: "weightCategory", value: classification.weightCategory),
      DataGridCell<String>(columnName: "paperCodeType", value: paperType?.paperCode ?? ""),
      DataGridCell<String>(columnName: "paperName", value: paperType?.paperName ?? ""),

      DataGridCell<String>(columnName: "supplierName", value: supplier?.supplierName ?? ""),
      DataGridCell<String>(columnName: "supplierCode", value: supplier?.supplierCode ?? ""),
      DataGridCell<String>(columnName: "companyCode", value: supplierPaper?.companyCode ?? ""),
      DataGridCell<int>(columnName: "grade", value: paperType?.grade ?? 0),
      DataGridCell<int>(columnName: "basisWeight", value: basisWeight?.basisWeight ?? 0),

      DataGridCell<double>(columnName: "burstRatio", value: classification.burstRatio ?? 0),
      DataGridCell<double>(columnName: "burstStrength", value: classification.burstStrength ?? 0),
      DataGridCell<double>(columnName: "ringCrush", value: classification.ringCrush ?? 0),
      DataGridCell<String>(
        columnName: "pricePaper",
        value: OrderModel.formatCurrency(classification.pricePaper ?? 0),
      ),

      // hidden field
      DataGridCell<int>(columnName: "classificationId", value: classification.classificationId),
    ];
  }

  @override
  List<DataGridRow> get rows => paperClassificationsDataGridRows;

  void buildDataGridRows() {
    paperClassificationsDataGridRows =
        classifications.map<DataGridRow>((entry) {
          return DataGridRow(cells: buildPaperClassificationCells(entry));
        }).toList();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    return switch (dataCell.columnName) {
      'grade' => switch (value) {
        1 => 'Tốt',
        2 => 'Khá',
        3 => 'Trung bình',
        4 => 'Kém',
        _ => '',
      },
      _ => value?.toString() ?? '',
    };
  }

  @override
  Widget? buildGroupCaptionCellWidget(RowColumnIndex rowColumnIndex, String summaryValue) {
    // Bắt tên nhà cung cấp, không phân biệt hoa thường
    final regex = RegExp(r"^.*?:\s*(.*?)\s*-\s*(\d+)\s*items?$", caseSensitive: false);
    final match = regex.firstMatch(summaryValue);

    String displaySupplierName = "";

    if (match != null) {
      displaySupplierName = match.group(1) ?? "";
    }

    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Text(
        displaySupplierName.isNotEmpty
            ? "📅 Nhà cung cấp: $displaySupplierName"
            : "📅 Nhà cung cấp: Không xác định",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().asMap().entries.map<Widget>((entry) {
            final DataGridCell dataCell = entry.value;

            return formatDataTable(
              label: _formatCellValueBool(dataCell),
              alignment: Alignment.centerLeft,
            );
          }).toList(),
    );
  }
}
