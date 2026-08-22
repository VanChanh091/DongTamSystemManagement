import 'package:dongtam/data/models/planning/requirements/paper_requirement_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PaperRequirementsDataSource extends DataGridSource {
  List<PaperRequirementModel> requirements = [];
  int currentPage;
  int pageSize;

  late List<DataGridRow> paperDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');

  PaperRequirementsDataSource({
    required this.requirements,
    required this.currentPage,
    required this.pageSize,
  }) {
    buildDataGridRows();
    addColumnGroup(ColumnGroup(name: 'dayStart', sortGroupRows: false));
  }

  List<DataGridCell> buildRequirementCells(PaperRequirementModel requirement, int index) {
    final planning = requirement.planningPaper;
    final order = planning?.order;
    final customer = order?.customer;

    return [
      DataGridCell<int>(columnName: 'index', value: index + 1),
      DataGridCell<String>(columnName: "orderId", value: planning?.orderId ?? ""),
      DataGridCell<String>(columnName: "customerName", value: customer?.customerName ?? ""),
      DataGridCell<String>(
        columnName: "dateRequestShipping",
        value:
            order?.dateRequestShipping != null ? formatter.format(order!.dateRequestShipping!) : "",
      ),

      DataGridCell<String>(columnName: 'structure', value: planning?.formatterStructureOrder ?? ""),
      DataGridCell<String>(columnName: "flute", value: planning?.order?.flute ?? ""),
      DataGridCell<int>(columnName: "ghepKho", value: planning?.ghepKho ?? 0),
      DataGridCell<double>(columnName: "sizePaper", value: planning?.sizePaperPLaning ?? 0),
      DataGridCell<double>(columnName: "lengthPaper", value: planning?.lengthPaperPlanning ?? 0),
      DataGridCell<int>(columnName: "runningPlan", value: planning?.runningPlan ?? 0),
      DataGridCell<double>(columnName: "totalRequiredQty", value: requirement.totalRequiredQty),
      DataGridCell<String>(
        columnName: "dayStart",
        value: planning?.dayStart != null ? formatter.format(planning!.dayStart!) : null,
      ),
      DataGridCell<String>(columnName: "chooseMachine", value: planning?.chooseMachine ?? ""),
      DataGridCell<String>(columnName: "inventoryStatus", value: requirement.inventoryStatus),

      //hide
      DataGridCell<int>(columnName: "requirementId", value: requirement.requirementId),
    ];
  }

  @override
  List<DataGridRow> get rows => paperDataGridRows;

  void buildDataGridRows() {
    final int offset = (currentPage - 1) * pageSize;

    paperDataGridRows =
        requirements.asMap().entries.map<DataGridRow>((entry) {
          int globalIndex = offset + entry.key;

          return DataGridRow(cells: buildRequirementCells(entry.value, globalIndex));
        }).toList();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    if (dataCell.columnName == "inventoryStatus") {
      switch (value) {
        case "ENOUGH":
          return "Đủ Giấy";
        case "SHORTAGE":
          return "Thiếu Giấy";
        case "WARNING":
          return "Cảnh Báo";
        default:
          return "";
      }
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
    return DataGridRowAdapter(
      cells:
          row.getCells().asMap().entries.map<Widget>((entry) {
            final DataGridCell dataCell = entry.value;

            Alignment alignment;
            if (dataCell.value is num) {
              alignment = Alignment.centerRight;
            } else {
              alignment = Alignment.centerLeft;
            }

            return formatDataTable(label: _formatCellValueBool(dataCell), alignment: alignment);
          }).toList(),
    );
  }
}
