import "package:dongtam/data/models/admin/paperCode/supplier_paper_code_model.dart";
import "package:dongtam/utils/helper/style_table.dart";
import "package:flutter/material.dart";
import "package:syncfusion_flutter_datagrid/datagrid.dart";

class SupplierPaperDataSource extends DataGridSource {
  List<SupplierPaperCodeModel> supplierPapers = [];
  List<int> selectedIds = [];

  late List<DataGridRow> supplierPapersDataGridRows;

  SupplierPaperDataSource({required this.supplierPapers, required this.selectedIds}) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: "supplierName", sortGroupRows: false));
  }

  List<DataGridCell> buildSupplierPaperCells(SupplierPaperCodeModel supplierPaper) {
    final supplier = supplierPaper.Supplier;
    final paperType = supplierPaper.PaperType;

    return [
      DataGridCell<String>(columnName: "supplierCode", value: supplier?.supplierCode ?? ""),
      DataGridCell<String>(columnName: "companyCode", value: supplierPaper.companyCode),
      DataGridCell<String>(columnName: "layerType", value: supplierPaper.layerType),
      DataGridCell<String>(columnName: "paperName", value: paperType?.paperName ?? ""),
      DataGridCell<String>(columnName: "paperCode", value: paperType?.paperCode ?? ""),
      DataGridCell<int>(columnName: "grade", value: supplier?.grade ?? 0),
      DataGridCell<String>(columnName: "supplierName", value: supplier?.supplierName ?? ""),

      // hidden field
      DataGridCell<int>(columnName: "supplierPaperId", value: supplierPaper.supplierPaperId),
      DataGridCell<int>(columnName: "supplierId", value: supplierPaper.supplierId),
    ];
  }

  @override
  List<DataGridRow> get rows => supplierPapersDataGridRows;

  void buildDataGridRows() {
    supplierPapersDataGridRows =
        supplierPapers.map<DataGridRow>((entry) {
          return DataGridRow(cells: buildSupplierPaperCells(entry));
        }).toList();
  }

  String _formatCellValue(DataGridCell dataCell) {
    final value = dataCell.value;

    return switch (dataCell.columnName) {
      'grade' => switch (value) {
        1 => 'Tốt',
        2 => 'Khá',
        3 => 'Trung bình',
        4 => 'Kém',
        _ => '',
      },
      'layerType' => switch (value) {
        'LINER' => 'Giấy Mặt',
        'FLUTE' => 'Giấy Sóng',
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
        displaySupplierName.isNotEmpty ? "📅 NCC: $displaySupplierName" : "📅 NCC: Không xác định",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final supplierPaperId =
        row.getCells().firstWhere((cell) => cell.columnName == "supplierPaperId").value;
    final isSelected = selectedIds.contains(supplierPaperId);

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      backgroundColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: backgroundColor,
      cells:
          row.getCells().asMap().entries.map<Widget>((entry) {
            final DataGridCell dataCell = entry.value;

            return formatDataTable(
              label: _formatCellValue(dataCell),
              alignment: Alignment.centerLeft,
            );
          }).toList(),
    );
  }
}
