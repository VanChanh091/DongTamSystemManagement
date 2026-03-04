import 'package:dongtam/data/models/planning/planning_box_model.dart';
import 'package:dongtam/utils/helper/style_table.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class WaitingCheckBoxDataSource extends DataGridSource {
  List<PlanningBox> planning = [];
  int? selectedPlanningBoxIds;

  late List<DataGridRow> planningDataGridRows;
  final formatter = DateFormat('dd/MM/yyyy');
  final formatterDayCompleted = DateFormat("dd/MM/yyyy HH:mm:ss");

  bool hasSortedInitially = false;

  WaitingCheckBoxDataSource({required this.planning, required this.selectedPlanningBoxIds}) {
    buildDataGridRows();
  }

  List<DataGridCell> buildPlanningCells(PlanningBox planning) {
    return [
      //14 items
      DataGridCell<String>(columnName: "orderId", value: planning.orderId),
      DataGridCell<String>(
        columnName: "customerName",
        value: planning.order?.customer?.customerName ?? "",
      ),
      DataGridCell<String>(
        columnName: "dateShipping",
        value:
            planning.order?.dateRequestShipping != null
                ? formatter.format(planning.order!.dateRequestShipping!)
                : '',
      ),
      DataGridCell<String>(columnName: "structure", value: planning.formatterStructureOrder),
      DataGridCell<String>(columnName: "flute", value: planning.order?.flute ?? ""),
      DataGridCell<String>(columnName: "QC_box", value: planning.order?.QC_box ?? ""),
      DataGridCell<String>(
        columnName: "length",
        value: planning.length > 0 ? '${planning.length} cm' : "0",
      ),
      DataGridCell<String>(columnName: "size", value: '${planning.size} cm'),
      DataGridCell<int>(columnName: 'child', value: planning.order?.numberChild ?? 0),
      DataGridCell<int>(columnName: "quantityOrd", value: planning.order?.quantityCustomer ?? 0),
      DataGridCell<int>(columnName: "qtyPaper", value: planning.qtyPaper),
      DataGridCell<int>(columnName: "inboundQty", value: planning.getTotalQtyInbound),

      ...buildChildBoxCells(planning),

      //status request
      DataGridCell<String>(columnName: "statusRequest", value: planning.statusRequest),

      //hidden field
      DataGridCell<int>(columnName: "planningBoxId", value: planning.planningBoxId),
    ];
  }

  List<DataGridCell> buildChildBoxCells(PlanningBox planning) {
    return [
      DataGridCell<int>(columnName: "inMatTruoc", value: planning.order!.box!.inMatTruoc ?? 0),
      DataGridCell<int>(columnName: "inMatSau", value: planning.order!.box!.inMatSau ?? 0),
      DataGridCell<bool>(columnName: "dan_1_Manh", value: planning.order!.box!.dan_1_Manh ?? false),
      DataGridCell<bool>(columnName: "dan_2_Manh", value: planning.order!.box!.dan_2_Manh ?? false),
      DataGridCell<bool>(
        columnName: "dongGhim1Manh",
        value: planning.order!.box!.dongGhim1Manh ?? false,
      ),
      DataGridCell<bool>(
        columnName: "dongGhim2Manh",
        value: planning.order!.box!.dongGhim2Manh ?? false,
      ),
    ];
  }

  @override
  List<DataGridRow> get rows => planningDataGridRows;

  void buildDataGridRows() {
    planningDataGridRows =
        planning.map<DataGridRow>((box) {
          final cells = buildPlanningCells(box);

          // debugPrint("Row has ${cells.length} cells");

          return DataGridRow(cells: cells);
        }).toList();

    notifyListeners();
  }

  String _formatCellValueBool(DataGridCell dataCell) {
    final value = dataCell.value;

    const boolColumns = ['dan_1_Manh', 'dan_2_Manh', 'dongGhim1Manh', 'dongGhim2Manh'];

    if (boolColumns.contains(dataCell.columnName)) {
      if (value == null) return '';
      return value == true ? '✅' : '';
    }

    if (dataCell.columnName == "statusRequest") {
      switch (value) {
        case "requested":
          return "Chờ nhập kho";
        case "reject":
          return "Từ chối";
        case "inbounded":
          return "Đã nhập kho";
        case "none":
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
    final planningBoxId =
        row.getCells().firstWhere((cell) => cell.columnName == 'planningBoxId').value;

    // Màu nền cho cả hàng
    Color? rowColor;
    if (selectedPlanningBoxIds == planningBoxId) {
      rowColor = Colors.blue.withValues(alpha: 0.3);
    } else {
      rowColor = Colors.transparent;
    }

    return DataGridRowAdapter(
      color: rowColor, // chỉ set khi tô cả hàng
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
